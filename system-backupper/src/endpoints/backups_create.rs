use super::api::ArchiveBackupResponse;
use crate::{
    endpoints::api::{ApiError, ErrorCode},
    model::BackupType,
    services::{BackupCreateError, BackuppingService},
};
use axum::{
    extract::{Path, State},
    http::StatusCode,
    Json,
};
use log::{error, info};
use std::sync::Arc;

pub async fn backups_create(
    State(backupping_service): State<Arc<BackuppingService>>,
    Path(target_name): Path<String>,
) -> Result<Json<ArchiveBackupResponse>, (StatusCode, Json<ApiError>)> {
    match backupping_service.create_backup(&target_name, BackupType::Manual) {
        Ok(backup) => {
            let response = ArchiveBackupResponse::from(backup);
            Ok(Json(response))
        }
        Err(err) => match err {
            BackupCreateError::BackupTargetLocked(_) => {
                info!("Abandoning backup - the target is locked");
                let response = ApiError {
                    error_code: ErrorCode::BackupTargetLocked,
                    message: format!("{}", err),
                };
                Err((StatusCode::LOCKED, Json(response)))
            }
            BackupCreateError::BackupTargetNotFound(_) => {
                info!("Abandoning backup - did not find the target");
                let response = ApiError {
                    error_code: ErrorCode::BackupTargetNotFound,
                    message: format!("{}", err),
                };
                Err((StatusCode::NOT_FOUND, Json(response)))
            }
            BackupCreateError::Unknown(_) => {
                error!("Abandoning backup. Error:\n{:?}", err);
                let response = ApiError {
                    error_code: ErrorCode::InternalError,
                    message: format!("{}", err),
                };
                Err((StatusCode::INTERNAL_SERVER_ERROR, Json(response)))
            }
        },
    }
}


#[cfg(test)]
mod tests {

}