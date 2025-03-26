use std::sync::Arc;

use iron::{prelude::*, status, Handler};
use log::{error, info};
use router::Router;

use crate::{
    endpoints::api::{ApiError, ErrorCode},
    model::BackupType,
    services::{BackupCreateError, BackuppingService},
};

use super::api::{json_response, ArchiveBackupResponse};

pub struct CreateBackupEndpoint {
    backupping_service: Arc<BackuppingService>,
}

impl CreateBackupEndpoint {
    pub fn new(backupping_service: Arc<BackuppingService>) -> Self {
        Self { backupping_service }
    }
}

impl Handler for CreateBackupEndpoint {
    fn handle(&self, req: &mut Request) -> IronResult<Response> {
        let router = req.extensions.get::<Router>().unwrap();
        let target_name = router.find("target_name").unwrap(); 
        match self
            .backupping_service
            .create_backup(target_name, BackupType::Manual)
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
                BackupCreateError::BackupTargetNotFound(_) => {
                    info!("Abandoning mongodb backup - did not find the target");
                    let response = ApiError {
                        error_code: ErrorCode::BackupTargetNotFound,
                        message: format!("{}", err),
                    };
                    Ok(json_response(status::NotFound, response))
                }
                BackupCreateError::Unknown(_) => {
                    error!("Abandoning mongodb backup. Error:\n{:?}", err);
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
