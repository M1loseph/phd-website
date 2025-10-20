use std::sync::Arc;

use axum::extract::State;
use axum::http::{header, HeaderMap};
use prometheus::TextEncoder;

pub struct AppState {
    pub registry: prometheus::Registry,
}

pub async fn prometheus_handler(State(state): State<Arc<AppState>>) -> (HeaderMap, String) {
    let encoder = TextEncoder::new();
    let metric_families = state.registry.gather();
    let response = encoder.encode_to_string(&metric_families).unwrap();

    let mut headers = HeaderMap::new();
    headers.insert(
        header::CONTENT_TYPE,
        "text/plain; version=0.0.4".parse().unwrap(),
    );
    (headers, response)
}
