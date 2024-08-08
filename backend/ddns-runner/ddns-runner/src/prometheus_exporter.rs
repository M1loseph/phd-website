use iron::status;
use iron::{Handler, IronResult, Request, Response};
use prometheus::{Encoder, TextEncoder};

pub struct PrometheusExporter {
    registry: prometheus::Registry,
}

impl PrometheusExporter {
    pub fn new(registry: prometheus::Registry) -> Self {
        PrometheusExporter { registry }
    }
}

impl Handler for PrometheusExporter {
    fn handle(&self, _: &mut Request) -> IronResult<Response> {
        let mut buffer = vec![];
        let encoder = TextEncoder::new();
        let metric_families = self.registry.gather();
        // TODO: don't unwrap
        encoder.encode(&metric_families, &mut buffer).unwrap();
        let text_response = String::from_utf8(buffer).unwrap();
        Ok(Response::with((status::Ok, text_response)))
    }
}
