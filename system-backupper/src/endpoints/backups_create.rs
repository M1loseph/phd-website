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
    State(backupping_service): State<Arc<dyn BackuppingService>>,
    Path(target_name): Path<String>,
) -> Result<(StatusCode, Json<ArchiveBackupResponse>), (StatusCode, Json<ApiError>)> {
    match backupping_service.create_backup(&target_name, BackupType::Manual) {
        Ok(backup) => {
            let response = ArchiveBackupResponse::from(backup);
            Ok((StatusCode::CREATED, Json(response)))
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

    use std::str::FromStr;

    use super::*;
    use crate::{
        model::{
            BackupFormat, BackupMetadata, BackupTarget, BackupTargetKind, ConfiguredBackupTarget,
        },
        services::BackupFindError,
    };
    use axum::{routing::post, Router};
    use axum_test::TestServer;
    use chrono::DateTime;
    use serde_json::json;

    struct BackuppingServiceMock {
        create_backup_result_provider: fn(&str) -> Result<BackupMetadata, BackupCreateError>,
    }

    #[allow(unused_variables)]
    impl BackuppingService for BackuppingServiceMock {
        fn create_backup(
            &self,
            target_name: &str,
            backup_type: BackupType,
        ) -> Result<BackupMetadata, BackupCreateError> {
            assert_eq!(backup_type, BackupType::Manual);
            (self.create_backup_result_provider)(target_name)
        }

        fn read_all_backups(&self) -> Result<Vec<BackupMetadata>, BackupFindError> {
            unimplemented!()
        }

        fn restore_backup(
            &self,
            target_name: &str,
            backup_id: u64,
            drop: bool,
        ) -> Result<(), crate::services::BackupRestoreError> {
            unimplemented!()
        }

        fn read_all_configured_targets(&self) -> &Vec<ConfiguredBackupTarget> {
            unimplemented!()
        }
    }

    #[tokio::test]
    async fn should_return_backup_metadata_when_backup_was_created() {
        // given
        let service = Arc::new(BackuppingServiceMock {
            create_backup_result_provider: |target_name| {
                assert_eq!(target_name, "testTarget");
                Ok(BackupMetadata {
                    backup_id: 1,
                    created_at: DateTime::from_str("2023-03-15T12:00:00Z").unwrap(),
                    backup_size_bytes: 1024,
                    backup_target: BackupTarget {
                        kind: BackupTargetKind::MongoDB,
                        name: "test".into(),
                    },
                    backup_type: BackupType::Manual,
                    backup_format: BackupFormat::ArchiveGz,
                })
            },
        });
        let app = Router::new()
            .route("/api/v1/backups/{target_name}", post(backups_create))
            .with_state(service);

        let test_server = TestServer::new(app).unwrap();

        // when
        let response = test_server.post("/api/v1/backups/testTarget").await;

        // then
        response.assert_status(StatusCode::CREATED);
        response.assert_header("content-type", "application/json");
        response.assert_json(&json!({
            "backup_id": 1,
            "created_at": "2023-03-15T12:00:00Z",
            "backup_size_bytes": 1024,
            "backup_target": {
                "kind": "MONGODB",
                "name": "test"
            },
            "backup_type": "MANUAL",
            "backup_format": "ARCHIVE_GZ"
        }));
    }

    #[tokio::test]
    async fn should_return_423_when_backup_is_in_progress() {
        // given
        let service = Arc::new(BackuppingServiceMock {
            create_backup_result_provider: |target_name| {
                Err(BackupCreateError::BackupTargetLocked(
                    target_name.to_string(),
                ))
            },
        });
        let app = Router::new()
            .route("/api/v1/backups/{target_name}", post(backups_create))
            .with_state(service);

        let test_server = TestServer::new(app).unwrap();

        // when
        let response = test_server.post("/api/v1/backups/testTarget").await;

        // then
        response.assert_status(StatusCode::LOCKED);
        response.assert_header("content-type", "application/json");
        response.assert_json(&json!({
            "error_code": "BACKUP_TARGET_LOCKED",
            "message": "Backup target testTarget is undergoing another operation."
        }));
    }
}
