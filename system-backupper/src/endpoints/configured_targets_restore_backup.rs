use crate::{
    endpoints::api::{ApiError, ErrorCode},
    services::{BackupRestoreError, BackuppingService},
};
use axum::{
    extract::{Path, Query, State},
    http::StatusCode,
    Json,
};
use log::{error, info, warn};
use std::{collections::HashMap, sync::Arc};

pub async fn configured_targets_restore_backup(
    State(backupping_service): State<Arc<BackuppingService>>,
    Path((target_name, backup_id)): Path<(String, u64)>,
    Query(query_params): Query<HashMap<String, String>>,
) -> Result<StatusCode, (StatusCode, Json<ApiError>)> {
    let drop = query_params
        .get("drop")
        .and_then(|v| v.parse::<bool>().ok())
        .unwrap_or(false);
    if drop {
        warn!(
            r#""drop" parameter is present and set to true - restoring backup will perform drop operation"#
        );
    }
    info!("Starting backup procedure. Backup ID = {backup_id}");
    match backupping_service.restore_backup(&target_name, backup_id, drop) {
        Ok(()) => Ok(StatusCode::OK),
        Err(err) => match &err {
            BackupRestoreError::BackupTargetLocked { name } => {
                warn!("Backup target {} is locked", name);
                let response_body = ApiError {
                    error_code: ErrorCode::BackupTargetLocked,
                    message: format!("{}", err),
                };
                Err((StatusCode::LOCKED, Json(response_body)))
            }
            BackupRestoreError::BackupTargetNotFound { name: _ } => {
                warn!("{}", err);
                let response_body = ApiError {
                    error_code: ErrorCode::BackupTargetNotFound,
                    message: format!("{}", err),
                };
                Err((StatusCode::NOT_FOUND, Json(response_body)))
            }
            BackupRestoreError::BackupDoesNotExist(_) => {
                warn!("Backup does not exist. Backup ID = {}", backup_id);
                let response_body = ApiError {
                    error_code: ErrorCode::BackupNotFound,
                    message: format!("{}", err),
                };
                Err((StatusCode::NOT_FOUND, Json(response_body)))
            }
            _ => {
                error!(
                    "Unexpected error has occurred when restoring the backup.\n{:?}",
                    err
                );
                let response_body = ApiError {
                    error_code: ErrorCode::InternalError,
                    message: format!("{}", err),
                };
                Err((StatusCode::INTERNAL_SERVER_ERROR, Json(response_body)))
            }
        },
    }
}
