use std::sync::Arc;

use log::{error, info};

use crate::{model::BackupType, services::BackuppingService};

use super::cron_jobs::Task;

pub struct ScheduledBackupJob {
    backup_target_name: String,
    backupping_service: Arc<BackuppingService>,
}

impl ScheduledBackupJob {
    pub fn new(backup_target_name: String, backupping_service: Arc<BackuppingService>) -> Self {
        Self {
            backup_target_name,
            backupping_service,
        }
    }
}

impl Task for ScheduledBackupJob {
    fn run_task(&self) {
        info!("Starting a scheduled mongodb full backup task");
        match self
            .backupping_service
            .create_backup(&self.backup_target_name, BackupType::Scheduled)
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
