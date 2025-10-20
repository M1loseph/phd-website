use std::sync::Arc;

use axum::extract::State;
use axum::http::{header, HeaderMap, HeaderValue, StatusCode};
use log::error;
use prometheus::TextEncoder;

pub struct AppState {
    pub registry: prometheus::Registry,
}

pub async fn prometheus_handler(
    State(state): State<Arc<AppState>>,
) -> Result<(HeaderMap, String), (StatusCode, &'static str)> {
    let encoder = TextEncoder::new();
    let metric_families = state.registry.gather();
    let response = match encoder.encode_to_string(&metric_families) {
        Ok(v) => v,
        Err(e) => {
            error!("Error occurred while encoding metrics to string: {}", e);
            return Err((
                StatusCode::INTERNAL_SERVER_ERROR,
                "Error occurred while encoding metrics",
            ));
        }
    };

    let mut headers = HeaderMap::new();
    headers.insert(
        header::CONTENT_TYPE,
        HeaderValue::from_static("text/plain; version=0.0.4"),
    );
    Ok((headers, response))
}
