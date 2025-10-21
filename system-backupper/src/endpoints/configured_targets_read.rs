use crate::endpoints::api::BackupTargetResponse;
use crate::services::BackuppingService;
use axum::{extract::State, Json};
use std::sync::Arc;
use url::Url;

pub async fn configured_targets_read_all(
    State(backupping_service): State<Arc<BackuppingService>>,
) -> Json<Vec<BackupTargetResponse>> {
    let targets = backupping_service.read_all_configured_targets();
    let response_body: Vec<BackupTargetResponse> = targets
        .iter()
        .map(|target| {
            let host = Url::parse(&target.connection_string)
                .ok()
                .map(|uri| uri.host_str().map(|host| host.to_string()))
                .flatten();
            BackupTargetResponse {
                host,
                name: target.target_name.clone(),
                kind: target.target_kind.clone().into(),
            }
        })
        .collect();

    Json(response_body)
}
