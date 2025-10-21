use super::api::ArchiveBackupResponse;
use crate::{
    endpoints::api::{ApiError, ErrorCode},
    services::BackuppingService,
};
use axum::{extract::State, http::StatusCode, Json};
use log::{error, info};
use std::sync::Arc;

pub async fn backups_read_all(
    State(backupping_service): State<Arc<dyn BackuppingService>>,
) -> Result<Json<Vec<ArchiveBackupResponse>>, (StatusCode, Json<ApiError>)> {
    info!("Got request to list all backups");
    match backupping_service.read_all_backups() {
        Ok(mongo_backups) => {
            let response: Vec<ArchiveBackupResponse> = mongo_backups
                .into_iter()
                .map(|backup| ArchiveBackupResponse::from(backup))
                .collect();
            Ok(Json(response))
        }
        Err(err) => {
            error!(
                "An error has occurred when listing backups.\n{:?}",
                err
            );
            let response_body = ApiError {
                error_code: ErrorCode::InternalError,
                message: format!("{}", err),
            };
            Err((StatusCode::INTERNAL_SERVER_ERROR, Json(response_body)))
        }
    }
}
