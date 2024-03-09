use std::{future::Future, pin::Pin};

use http_body_util::Full;
use hyper::{body::Bytes, service::Service, Request, Response};
use prometheus::{Encoder, TextEncoder};

#[derive(Clone)]
pub struct PrometheusExporter {
    registry: prometheus::Registry,
}

impl PrometheusExporter {
    pub fn new(registry: prometheus::Registry) -> Self {
        PrometheusExporter { registry }
    }
}

impl Service<Request<hyper::body::Incoming>> for PrometheusExporter {
    type Response = Response<Full<Bytes>>;
    type Error = hyper::Error;
    type Future = Pin<Box<dyn Future<Output = Result<Self::Response, Self::Error>> + Send>>;

    fn call(&self, req: Request<hyper::body::Incoming>) -> Self::Future {
        match req.uri().path() {
            "/internal/status/prometheus" => {
                let mut buffer = vec![];
                let encoder = TextEncoder::new();
                let metric_families = self.registry.gather();
                encoder.encode(&metric_families, &mut buffer).unwrap();
                Box::pin(async { Ok(Response::new(Full::new(Bytes::from(buffer)))) })
            }
            _ => Box::pin(async {
                Ok(Response::builder()
                    .status(404)
                    .body(Full::new(Bytes::from("Not Found")))
                    .unwrap())
            }),
        }
    }
}
