use std::sync::Arc;

use crate::{endpoints::api::{ApiError, ErrorCode}, services::BackuppingService};
use log::{info, error};
use iron::{prelude::*, status, Handler};

use super::api::{json_response, ArchiveBackupResponse};

pub struct MongoDBReadAllBackups {
    backupping_service: Arc<BackuppingService>,
}

impl MongoDBReadAllBackups {
    pub fn new(backupping_service: Arc<BackuppingService>) -> Self {
        Self { backupping_service }
    }
}

impl Handler for MongoDBReadAllBackups {
    fn handle(&self, _: &mut Request) -> IronResult<Response> {
        info!("Got request to list all MongoDB backups");
        match self.backupping_service.read_all_mongodb_backups() {
            Ok(mongo_backups) => {
                let response: Vec<ArchiveBackupResponse> = mongo_backups
                    .into_iter()
                    .map(|backup| ArchiveBackupResponse::from(backup))
                    .collect();
                Ok(json_response(status::Ok, response))
            }
            Err(err) => {
                error!("An error has ocurred when listing MongoDB backups.\n{:?}", err);
                let response_body = ApiError {
                    error_code: ErrorCode::InternalError,
                    message: format!("{}", err)
                };
                Ok(json_response(status::InternalServerError, response_body))
            },
        }
    }
}
