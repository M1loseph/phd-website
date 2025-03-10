use iron::{prelude::*, status, Handler};
use log::warn;
use router::Router;
use std::sync::Arc;

use crate::mongodb::MongoDBBackuppingService;

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
