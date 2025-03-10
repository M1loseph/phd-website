use crate::{
    backup_metadata::BackupMetadata,
    mongodb::{BackupError, MongoDBBackuppingService},
};
use crate::backup_metadata;
use chrono::{DateTime, FixedOffset};
use iron::{
    headers::ContentType,
    mime::{Mime, SubLevel, TopLevel},
    modifiers::Header,
    prelude::*,
    status::{self, Status},
    Handler,
};
use log::{info, warn};
use router::Router;
use serde::Serialize;
use std::sync::Arc;

impl From<BackupMetadata> for ArchiveBackupResponse {
    fn from(value: BackupMetadata) -> Self {
        Self {
            backup_id: value.backup_id,
            host: value.host,
            created_at: value.created_at,
            backup_size_bytes: value.backup_size_bytes,
            backup_target: value.backup_target.into(),
            backup_type: value.backup_type.into(),
        }
    }
}


pub struct MongoDBReadAllBackups {
    backupping_service: Arc<MongoDBBackuppingService>,
}

impl MongoDBReadAllBackups {
    pub fn new(backupping_service: Arc<MongoDBBackuppingService>) -> Self {
        Self { backupping_service }
    }
}

impl Handler for MongoDBReadAllBackups {
    fn handle(&self, _: &mut Request) -> IronResult<Response> {
        let mongo_backups = self.backupping_service.read_all_mongodb_backups().unwrap();
        let response: Vec<ArchiveBackupResponse> = mongo_backups
            .into_iter()
            .map(|backup| ArchiveBackupResponse::from(backup))
            .collect();
        Ok(json_response(status::Ok, response))
    }
}

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
        let backup_id = req
            .extensions
            .get::<Router>()
            .unwrap()
            .find("backup_id")
            .unwrap();
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
        Ok(Response::with(status::Ok))
    }
}
