use std::sync::Arc;

use iron::{prelude::*, status, Handler};
use log::{error, info};

use crate::{
    endpoints::api::{ApiError, ErrorCode},
    mongodb::{BackupError, MongoDBBackuppingService},
};

use super::api::{json_response, ArchiveBackupResponse};

pub struct MongoDBCreateBackupEndpoint {
    backupping_service: Arc<MongoDBBackuppingService>,
}

impl MongoDBCreateBackupEndpoint {
    pub fn new(backupping_service: Arc<MongoDBBackuppingService>) -> Self {
        Self { backupping_service }
    }
}

impl Handler for MongoDBCreateBackupEndpoint {
    fn handle(&self, _: &mut Request) -> IronResult<Response> {
        match self.backupping_service.create_mongodb_backup() {
            Ok(backup) => {
                let response = ArchiveBackupResponse::from(backup);
                Ok(json_response(status::Ok, response))
            }
            Err(err) => match err {
                BackupError::BackupTargetLocked(_) => {
                    info!("Abandoning mongodb backup - the target is locked");
                    let response = ApiError {
                        error_code: ErrorCode::BackupTargetLocked,
                        message: format!("{}", err),
                    };
                    Ok(json_response(status::Locked, response))
                }
                _ => {
                    error!(
                        "Abandoning mongodb backup - an unknown error has occurred\n{:?}", err
                    );
                    let response = ApiError {
                        error_code: ErrorCode::InternalError,
                        message: format!("{}", err),
                    };
                    Ok(json_response(status::InternalServerError, response))
                }
            },
        }
    }
}
