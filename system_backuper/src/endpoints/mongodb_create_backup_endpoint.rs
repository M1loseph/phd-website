use std::sync::Arc;

use iron::{prelude::*, status, Handler};
use log::{error, info};

use crate::{
    backup_metadata::BackupType,
    endpoints::api::{ApiError, ErrorCode},
    services::{BackupCreateError, MongoDBBackuppingService},
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
        match self
            .backupping_service
            .create_mongodb_backup(BackupType::Manual)
        {
            Ok(backup) => {
                let response = ArchiveBackupResponse::from(backup);
                Ok(json_response(status::Ok, response))
            }
            Err(err) => match err {
                BackupCreateError::BackupTargetLocked(_) => {
                    info!("Abandoning mongodb backup - the target is locked");
                    let response = ApiError {
                        error_code: ErrorCode::BackupTargetLocked,
                        message: format!("{}", err),
                    };
                    Ok(json_response(status::Locked, response))
                }
                BackupCreateError::Unknown(_) => {
                    error!(
                        "Abandoning mongodb backup. Error:\n{:?}", err
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
