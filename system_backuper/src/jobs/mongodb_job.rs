use std::sync::Arc;

use log::{error, info};

use crate::{backup_metadata::BackupType, mongodb::MongoDBBackuppingService};

use super::cron_jobs::Task;

pub struct MongoDBScheduledBackupJob {
    mongodb_backup_service: Arc<MongoDBBackuppingService>,
}

impl MongoDBScheduledBackupJob {
    pub fn new(mongodb_backup_service: Arc<MongoDBBackuppingService>) -> Self {
        Self {
            mongodb_backup_service,
        }
    }
}

impl Task for MongoDBScheduledBackupJob {
    fn run_task(&self) {
        info!("Starting a scheduled mongodb full backup task");
        match self
            .mongodb_backup_service
            .create_mongodb_backup(BackupType::Scheduled)
        {
            Ok(backup) => {
                info!(
                    "Created new scheduled backup. Backup id: {}",
                    backup.backup_id
                );
            }
            Err(err) => {
                error!(
                    "An error has occurred when creating a scheduled backup:\n{:?}",
                    err
                );
            }
        }
    }
}
