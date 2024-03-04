mod config;
mod duck_dns_client;
mod prometheus_exporter;

use std::{net::SocketAddr, time::Duration};

use hyper::server::conn::http1;
use prometheus_exporter::PrometheusExporter;
use dotenv::dotenv;
use duck_dns_client::{DuckDnsClient, DuckDnsConfig};
use hyper_util::rt::TokioIo;
use log::{error, info, trace};
use prometheus::IntCounterVec;
use tokio::{net::TcpListener, time::sleep};

async fn update_dns_record_task(client: DuckDnsClient, successful_updates_counter: IntCounterVec) {
    info!("Starting update_dns_record_task");
    loop {
        match client.update_ip().await {
            Ok(response) => {
                info!("Got response from Duck DNS: \n{}", response);
                successful_updates_counter
                    .with_label_values(&["success"])
                    .inc();
            }
            Err(e) => {
                error!("Got error from Duck DNS: \n{}", e);
                successful_updates_counter
                    .with_label_values(&["failure"])
                    .inc();
            }
        };
        sleep(Duration::from_secs(60 * 5)).await;
    }
}

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    dotenv().ok();
    env_logger::init();

    let ddns_request_counter = IntCounterVec::new(
        prometheus::Opts::new(
            "ddnsrunner_ddns_requests",
            "Number of successful updates in duck dns.",
        ),
        &["result"],
    )?;
    let registry = prometheus::Registry::new();
    registry.register(Box::new(ddns_request_counter.clone()))?;

    let config = config::read_config_with_default()?;
    let client = duck_dns_client::DuckDnsClient::new(DuckDnsConfig {
        domain: config.domain,
        token: config.token,
    });

    tokio::spawn(async move {
        update_dns_record_task(client, ddns_request_counter).await;
    });

    let exporter = PrometheusExporter::new(registry);
    let addr = SocketAddr::from(([0, 0, 0, 0], config.server_port));
    let listener = TcpListener::bind(addr).await?;

    loop {
        let (stream, remote) = listener.accept().await?;
        trace!("Received request from: {:?}", remote.ip());
        let io = TokioIo::new(stream);
        let exporter_clone = exporter.clone();
        tokio::task::spawn(async move {
            if let Err(err) = http1::Builder::new()
                .serve_connection(io, exporter_clone)
                .await
            {
                error!("Error serving connection: {}", err);
            }
        });
    }
}
