use iron::{prelude::*, status, Handler};
use log::{error, info, warn};
use params::Params;
use router::Router;
use std::sync::Arc;

use crate::{
    endpoints::api::{json_response, ApiError, ErrorCode},
    services::{BackupRestoreError, MongoDBBackuppingService},
};

pub struct MongoRestoreBackupEndpoint {
    backupping_service: Arc<MongoDBBackuppingService>,
}

impl MongoRestoreBackupEndpoint {
    pub fn new(backupping_service: Arc<MongoDBBackuppingService>) -> Self {
        Self { backupping_service }
    }
}

impl Handler for MongoRestoreBackupEndpoint {
    fn handle(&self, req: &mut Request) -> IronResult<Response> {
        let query_params = req.get::<Params>().unwrap();
        let params = req.extensions.get::<Router>().unwrap();

        let backup_id = match params.find("backup_id") {
            Some(backup_id) => backup_id,
            None => {
                warn!("Missing backup_id in the path");
                return Ok(Response::with(status::BadRequest));
            }
        };
        let backup_id = match backup_id.parse::<u64>() {
            Ok(parsed_id) => parsed_id,
            Err(err) => {
                warn!(
                    "Error parsing id from the request '{backup_id}'. Cause: {}",
                    err
                );
                return Ok(Response::with(status::BadRequest));
            }
        };
        let drop = match query_params.find(&["drop"]) {
            Some(value) => match value {
                params::Value::String(drop) => {
                    let drop = drop == "true";
                    if drop {
                        warn!(
                            r#""drop" parameter is present and set to true - restoring backup will perform drop operation"#
                        )
                    }
                    drop
                }
                _ => false,
            },
            None => false,
        };
        info!("Starting backup procedure. Backup ID = {backup_id}");
        match self.backupping_service.restore_backup(backup_id, drop) {
            Ok(()) => Ok(Response::with(status::Ok)),
            Err(err) => match &err {
                BackupRestoreError::BackupTargetLocked(backup_target) => {
                    warn!("Backup target {} is locked", backup_target);
                    let response_body = ApiError {
                        error_code: ErrorCode::BackupTargetLocked,
                        message: format!("{}", err),
                    };
                    Ok(json_response(status::Locked, response_body))
                }
                BackupRestoreError::BackupDoesNotExist(_) => {
                    warn!("Backup doeos not exist. Backup ID = {}", backup_id);
                    let response_body = ApiError {
                        error_code: ErrorCode::BackupNotFound,
                        message: format!("{}", err),
                    };
                    Ok(json_response(status::NotFound, response_body))
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
                    Ok(json_response(status::InternalServerError, response_body))
                }
            },
        }
    }
}
