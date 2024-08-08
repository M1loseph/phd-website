mod config;
mod duck_dns_client;
mod prometheus_exporter;

use std::time::Duration;

use dotenv::dotenv;
use duck_dns_client::client::{DuckDnsClient, DuckDnsConfig};
use iron::Iron;
use log::{error, info};
use prometheus::IntCounterVec;
use prometheus_exporter::PrometheusExporter;
use router::Router;
use tokio::time::sleep;

async fn update_dns_record_task(
    client: DuckDnsClient,
    successful_updates_counter: IntCounterVec,
    sleep_time: Duration,
) {
    info!("Starting update_dns_record_task");
    loop {
        match client.update_ip().await {
            Ok(response) => {
                info!("Got response from Duck DNS: {:?}", response);
                successful_updates_counter
                    .with_label_values(&["success"])
                    .inc();
            }
            Err(e) => {
                error!("Got error from Duck DNS: {:?}", e);
                successful_updates_counter
                    .with_label_values(&["failure"])
                    .inc();
            }
        };
        sleep(sleep_time).await;
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
    let client = DuckDnsClient::new(DuckDnsConfig {
        domain_to_update: config.domain_to_update,
        duck_dns_address: config.duck_dns_address,
        token: config.token,
    });
    let sleep_time = config.ip_update_interval;

    tokio::spawn(async move {
        update_dns_record_task(client, ddns_request_counter, sleep_time).await;
    });

    let exporter = PrometheusExporter::new(registry);
    let addr = format!("0.0.0.0:{}", config.server_port);

    let mut router = Router::new();
    router.get("/internal/status/prometheus", exporter, "prometheus");
    let _ = Iron::new(router).http(addr);
    Ok(())
}
