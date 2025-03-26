use std::sync::Arc;

use iron::{prelude::*, status, Handler};
use url::Url;

use crate::services::BackuppingService;

use super::api::{json_response, BackupTargetResponse};

pub struct ConfiguredTargetsReadAllEndpoint {
    backupping_service: Arc<BackuppingService>,
}

impl ConfiguredTargetsReadAllEndpoint {
    pub fn new(backupping_service: Arc<BackuppingService>) -> Self {
        Self { backupping_service }
    }
}

impl Handler for ConfiguredTargetsReadAllEndpoint {
    fn handle(&self, _: &mut Request) -> IronResult<Response> {
        let targets = self.backupping_service.read_all_configured_targets();
        let response_body: Vec<BackupTargetResponse> = targets
            .iter()
            .map(|target| {
                let host = Url::parse(&target.connection_string)
                    .ok()
                    .map(|uri| uri.host_str().map(|host| host.to_string()))
                    .flatten();
                BackupTargetResponse {
                    host,
                    name: target.target_name.clone(),
                    kind: target.target_kind.clone().into(),
                }
            })
            .collect();

        Ok(json_response(status::Ok, response_body))
    }
}
