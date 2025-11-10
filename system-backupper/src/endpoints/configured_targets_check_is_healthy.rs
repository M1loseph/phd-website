use crate::endpoints::api::{ApiError, ErrorCode};
use crate::services::BackuppingService;
use crate::{endpoints::api::BackupHealthCheckResponse, services::BackupHealthCheckError};
use axum::{
    extract::{Path, State},
    Json,
};
use std::sync::Arc;

pub async fn configured_targets_check_is_healthy(
    State(backupping_service): State<Arc<dyn BackuppingService>>,
    Path(target_name): Path<String>,
) -> Result<Json<BackupHealthCheckResponse>, Json<ApiError>> {
    match backupping_service.check_if_target_is_healthy(&target_name) {
        Ok(is_healthy) => Ok(Json(BackupHealthCheckResponse { is_healthy })),
        Err(err) => match err {
            BackupHealthCheckError::BackupTargetNotFound { .. } => {
                let error = ApiError {
                    error_code: ErrorCode::BackupTargetNotFound,
                    message: format!("{}", err),
                };
                Err(Json(error))
            }
            BackupHealthCheckError::Unknown(_) => {
                let error = ApiError {
                    error_code: ErrorCode::InternalError,
                    message: format!("{}", err),
                };
                Err(Json(error))
            }
            BackupHealthCheckError::BackupTargetLocked { name: _, cause } => {
                let error = ApiError {
                    error_code: ErrorCode::BackupTargetLocked,
                    message: format!("{}", cause),
                };
                Err(Json(error))
            }
        },
    }
}
