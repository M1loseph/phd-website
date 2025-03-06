use crate::{backup_metadata::BackupMetadata, mongodb::MongoDBBackuppingService};
use chrono::{DateTime, FixedOffset};
use iron::{
    modifiers::Header,
    headers::ContentType,
    mime::{Mime, SubLevel, TopLevel},
    prelude::*,
    status::{self, Status},
    Handler,
};
use log::warn;
use router::Router;
use serde::{Deserialize, Serialize};
use std::sync::Arc;

#[derive(Serialize, Deserialize)]
struct ArchiveBackupResponse {
    backup_id: u64,
    host: String,
    created_at: DateTime<FixedOffset>,
    backup_size_bytes: u64,
    backup_target: &'static str,
    backup_type: &'static str,
}

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

pub struct MongoDBFullBackupEndpoint {
    backupping_service: Arc<MongoDBBackuppingService>,
}

impl MongoDBFullBackupEndpoint {
    pub fn new(backupping_service: Arc<MongoDBBackuppingService>) -> Self {
        Self { backupping_service }
    }
}

impl Handler for MongoDBFullBackupEndpoint {
    fn handle(&self, _: &mut Request) -> IronResult<Response> {
        // TODO: handle unwrap like a champ
        let mongo_backup = self.backupping_service.create_mongodb_backup().unwrap();
        let response = ArchiveBackupResponse::from(mongo_backup);
        Ok(json_response(status::Ok, response))
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

fn json_response<T>(status: Status, response_body: T) -> Response
where
    T: Sized + Serialize,
{
    let response_body = serde_json::to_string(&response_body).unwrap();

    let header = Header(ContentType(Mime(
        TopLevel::Application,
        SubLevel::Json,
        vec![],
    )));

    Response::with((status, response_body, header))
}
