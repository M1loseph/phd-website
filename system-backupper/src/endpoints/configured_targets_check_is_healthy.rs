use crate::{
    endpoints::api::{ApiError, BackupHealthCheckResponse, ErrorCode},
    services::{BackupHealthCheckError, BackuppingService},
};
use axum::{
    extract::{Path, State},
    http::StatusCode,
    Json,
};
use std::sync::Arc;

pub async fn configured_targets_check_is_healthy(
    State(backupping_service): State<Arc<dyn BackuppingService>>,
    Path(target_name): Path<String>,
) -> Result<Json<BackupHealthCheckResponse>, (StatusCode, Json<ApiError>)> {
    match backupping_service.check_if_target_is_healthy(&target_name) {
        Ok(is_healthy) => Ok(Json(BackupHealthCheckResponse { is_healthy })),
        Err(err) => match &err {
            BackupHealthCheckError::BackupTargetNotFound { .. } => {
                let error = ApiError {
                    error_code: ErrorCode::BackupTargetNotFound,
                    message: format!("{}", err),
                };
                Err((StatusCode::NOT_FOUND, Json(error)))
            }
            BackupHealthCheckError::Unknown(_) => {
                let error = ApiError {
                    error_code: ErrorCode::InternalError,
                    message: format!("{}", err),
                };
                Err((StatusCode::INTERNAL_SERVER_ERROR, Json(error)))
            }
            BackupHealthCheckError::BackupTargetLocked { .. } => {
                let error = ApiError {
                    error_code: ErrorCode::BackupTargetLocked,
                    message: format!("{}", err),
                };
                Err((StatusCode::LOCKED, Json(error)))
            }
        },
    }
}

#[cfg(test)]
mod tests {
    use crate::{
        endpoints::configured_targets_check_is_healthy,
        services::{BackupHealthCheckError, BackuppingService},
    };
    use axum::{http::StatusCode, routing::post, Router};
    use axum_test::TestServer;
    use serde_json::json;
    use std::sync::Arc;

    #[allow(unused_variables)]
    struct BackuppingServiceMock {
        response: fn() -> Result<bool, BackupHealthCheckError>,
    }

    impl BackuppingService for BackuppingServiceMock {
        fn check_if_target_is_healthy(
            &self,
            _target_name: &str,
        ) -> Result<bool, BackupHealthCheckError> {
            (self.response)()
        }

        fn create_backup(
            &self,
            _target_name: &str,
            _backup_type: crate::model::BackupType,
        ) -> Result<crate::model::BackupMetadata, crate::services::BackupCreateError> {
            unimplemented!()
        }

        fn read_all_backups(
            &self,
        ) -> Result<Vec<crate::model::BackupMetadata>, crate::services::BackupFindError> {
            unimplemented!()
        }

        fn restore_backup(
            &self,
            _target_name: &str,
            _backup_id: u64,
            _drop: bool,
        ) -> Result<(), crate::services::BackupRestoreError> {
            unimplemented!()
        }

        fn read_all_configured_targets(&self) -> &Vec<crate::model::ConfiguredBackupTarget> {
            unimplemented!()
        }
    }

    #[tokio::test]
    async fn should_return_health_response() {
        // given
        let backupping_service_mock = BackuppingServiceMock {
            response: || Ok(true),
        };

        let router = Router::new()
            .route(
                "/api/v1/targets/{target_name}/health",
                post(configured_targets_check_is_healthy),
            )
            .with_state(Arc::new(backupping_service_mock));

        let server = TestServer::new(router).unwrap();

        // when
        let response = server.post("/api/v1/targets/testTarget/health").await;

        // then
        response.assert_status(StatusCode::OK);
        response.assert_json(&json!({
            "is_healthy": true
        }));
    }

    #[tokio::test]
    async fn should_return_lock_status_code_when_target_is_locked() {
        // given
        let backupping_service_mock = BackuppingServiceMock {
            response: || {
                Err(BackupHealthCheckError::BackupTargetLocked {
                    name: "testTarget".into(),
                    cause: crate::lock::LockError::LockAlreadyExists("testTarget".into()),
                })
            },
        };

        let router = Router::new()
            .route(
                "/api/v1/targets/{target_name}/health",
                post(configured_targets_check_is_healthy),
            )
            .with_state(Arc::new(backupping_service_mock));

        let server = TestServer::new(router).unwrap();

        // when
        let response = server.post("/api/v1/targets/testTarget/health").await;

        // then
        response.assert_status(StatusCode::LOCKED);
        response.assert_json(&json!({
            "error_code": "BACKUP_TARGET_LOCKED",
            "message": "Backup target testTarget is undergoing another operation."
        }));
    }
}
