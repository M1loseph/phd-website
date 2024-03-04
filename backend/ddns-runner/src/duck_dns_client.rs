use std::str::from_utf8;

use http_body_util::{BodyExt, Empty};
use hyper::body::{Buf, Bytes};
use hyper_tls::HttpsConnector;
use hyper_util::{
    client::legacy::{connect::HttpConnector, Client},
    rt::TokioExecutor,
};

pub struct DuckDnsConfig {
    pub domain: String,
    pub token: String,
}

type HttpsClient = Client<HttpsConnector<HttpConnector>, Empty<Bytes>>;

pub struct DuckDnsClient {
    config: DuckDnsConfig,
    client: HttpsClient,
}

impl DuckDnsClient {
    pub fn new(config: DuckDnsConfig) -> Self {
        let https = HttpsConnector::new();
        let client: HttpsClient = Client::builder(TokioExecutor::new()).build::<_, Empty<Bytes>>(https);
        DuckDnsClient { config, client }
    }

    pub async fn update_ip(&self) -> Result<String, Box<dyn std::error::Error>> {
        let url = format!(
            "https://www.duckdns.org/update?domains={}&token={}&verbose=true",
            self.config.domain, self.config.token
        );
        let res = self.client.get(url.parse()?).await?;
        let body = res.collect().await?.aggregate();
        let body_content = from_utf8(body.chunk())?;
        Ok(body_content.to_string())
    }
}
