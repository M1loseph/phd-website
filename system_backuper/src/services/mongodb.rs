use crate::backup_metadata::{
    BackupFormat, BackupId, BackupMetadata, BackupMetadataRepository, BackupRepository,
    BackupTarget, BackupType, RandomId, RepositoryError,
};
use crate::lock::{LockError, LockManager};
use crate::process::{IntoResult, ProcessOutputError};
use chrono::Local;
use log::info;
use std::fs;
use std::io::Write;
use std::path::Path;
use std::process::{Command, Stdio};
use std::result::Result;
use std::sync::Arc;
use url::Url;

use super::errors::{BackupCreateError, BackupFindError, BackupRestoreError, MongoDBBackuppingServiceInitializationError};

static MONGO_CONFIG_FILE_NAME: &str = "mongo.yml";
static METADATA_SAVE_RETRIES: u8 = 3;

pub struct MongoDBBackuppingService {
    mongodump_config_file_path: String,
    mongo_uri: Url,
    lock_manager: Arc<LockManager>,
    backup_repository: Arc<dyn BackupRepository + Sync>,
    backup_metadata_repository: Arc<dyn BackupMetadataRepository + Sync>,
}

impl MongoDBBackuppingService {
    pub fn new(
        mongodump_config_file_folder: String,
        mongo_uri: String,
        lock_manager: Arc<LockManager>,
        backup_repository: Arc<dyn BackupRepository>,
        backup_metadata_repository: Arc<dyn BackupMetadataRepository>,
    ) -> Result<Self, MongoDBBackuppingServiceInitializationError> {
        let mongodump_config_file_path =
            Self::create_config_file(&mongodump_config_file_folder, &mongo_uri)?;
        let mongo_uri = Url::parse(&mongo_uri)
            .map_err(|err| MongoDBBackuppingServiceInitializationError::InvalidMonogoDBUri(mongo_uri, Box::new(err)))?;

        Ok(Self {
            mongodump_config_file_path,
            mongo_uri,
            lock_manager,
            backup_repository,
            backup_metadata_repository,
        })
    }

    fn create_config_file(
        mongodump_config_file_folder: &str,
        uri: &String,
    ) -> Result<String, MongoDBBackuppingServiceInitializationError> {
        fs::create_dir_all(mongodump_config_file_folder)
            .map_err(|err| MongoDBBackuppingServiceInitializationError::FailedToCreateConfigurationFile(Box::new(err)))?;
        let mongodump_config_file_path =
            Path::new(mongodump_config_file_folder).join(MONGO_CONFIG_FILE_NAME);
        let file_content = format!("uri: {uri}");

        fs::write(&mongodump_config_file_path, file_content)
            .map_err(|err| MongoDBBackuppingServiceInitializationError::FailedToCreateConfigurationFile(Box::new(err)))?;
        Ok(mongodump_config_file_path.to_str().unwrap().to_string())
    }

    pub fn create_mongodb_backup(&self, backup_type: BackupType) -> Result<BackupMetadata, BackupCreateError> {
        info!("Starting backing up mongo at {}", Local::now());

        let _lock = self.lock_manager.lock(BackupTarget::MongoDB)?;

        let output = Command::new("mongodump")
            .args([
                "--config",
                &self.mongodump_config_file_path,
                "--gzip",
                "--archive",
            ])
            .output()
            .map_err(|err| BackupCreateError::Unknown(Box::new(err)))?
            .into_result()?;

        let blob = output.stdout;
        let blob_size = blob.len() as u64;

        let backup_metadata: BackupMetadata = (|| -> Result<BackupMetadata, BackupCreateError> {
            let mut i = 1;
            loop {
                let backup_metadata = BackupMetadata {
                    backup_id: BackupId::random(),
                    host: self.mongo_uri.host().unwrap().to_string(),
                    created_at: Local::now().fixed_offset(),
                    backup_size_bytes: blob_size,
                    backup_target: BackupTarget::MongoDB,
                    backup_type: backup_type.clone(),
                    backup_format: BackupFormat::ArchiveGz,
                };

                match self.backup_metadata_repository.save(&backup_metadata) {
                    Ok(_) => return Ok(backup_metadata),
                    Err(err) => {
                        match err {
                            RepositoryError::IdAlreadyExists { id } => {
                                if i == METADATA_SAVE_RETRIES {
                                    return Err(BackupCreateError::from(err));
                                } else {
                                    info!("Creating backup failed - id {id} already exists. Retrying...");
                                }
                            }
                            _ => return Err(BackupCreateError::from(err)),
                        }
                    }
                };
                i += 1;
            }
        })()?;
        if let Err(err) = self.backup_repository.save(&backup_metadata, blob) {
            self.backup_metadata_repository
                .delete_by_id(backup_metadata.backup_id)?;
            return Err(BackupCreateError::from(err));
        }

        Ok(backup_metadata)
    }

    pub fn read_all_mongodb_backups(&self) -> Result<Vec<BackupMetadata>, BackupFindError> {
        let backups = self.backup_metadata_repository.find_by_backup_target(BackupTarget::MongoDB)?;
        Ok(backups)
    }

    pub fn restore_backup(&self, backup_id: u64, drop: bool) -> Result<(), BackupRestoreError> {
        let _lock = self.lock_manager.lock(BackupTarget::MongoDB)?;

        let backup_metada = self
            .backup_metadata_repository
            .find_by_id(backup_id)?
            .ok_or(BackupRestoreError::BackupDoesNotExist(backup_id))?;
        
        if backup_metada.backup_format != BackupFormat::ArchiveGz {
            return Err(BackupRestoreError::UnsupportedFormat(backup_metada.backup_format));
        }

        // if backup_metada.backup_target != BackupTarget::MongoDB {
        //     return Err(BackupRestoreError::UnsupportedFormat(backup_metada.backup_format));
        // }

        let backup = self
            .backup_repository
            .find_by_metadata(&backup_metada)?
            .ok_or_else(|| BackupRestoreError::InconsistantData(backup_id))?;
        let mut args = vec![
            "--config",
            &self.mongodump_config_file_path,
            "--gzip",
            "--archive",
        ];
        if drop {
            args.push("--drop");
        }

        let mut child = Command::new("mongorestore")
            .args(args)
            .stdin(Stdio::piped())
            .stdout(Stdio::piped())
            .spawn()?;

        child.stdin.take().unwrap().write_all(&backup)?;

        let _ = child.wait_with_output()?.into_result()?;
        Ok(())
    }
}

impl From<LockError> for BackupCreateError {
    fn from(lock_error: LockError) -> Self {
        match &lock_error {
            LockError::LockAlreadyExists(_) => Self::BackupTargetLocked(BackupTarget::MongoDB),
            _ => Self::Unknown(Box::new(lock_error)),
        }
    }
}

impl From<RepositoryError> for BackupCreateError {
    fn from(err: RepositoryError) -> Self {
        Self::Unknown(Box::new(err))
    }
}

impl From<LockError> for BackupRestoreError {
    fn from(lock_error: LockError) -> Self {
        match &lock_error {
            LockError::LockAlreadyExists(_) => Self::BackupTargetLocked(BackupTarget::MongoDB),
            _ => Self::Unknown(Box::new(lock_error)),
        }
    }
}

impl From<RepositoryError> for BackupRestoreError {
    fn from(err: RepositoryError) -> Self {
        Self::Unknown(Box::new(err))
    }
}

impl From<ProcessOutputError> for BackupCreateError {
    fn from(value: ProcessOutputError) -> Self {
        Self::Unknown(Box::new(value))
    }
}

impl From<RepositoryError> for BackupFindError {
    fn from(value: RepositoryError) -> Self {
        Self::Unknown(Box::new(value))
    }
}

impl From<std::io::Error> for BackupRestoreError {
    fn from(value: std::io::Error) -> Self {
        Self::Unknown(Box::new(value))
    }
}

impl From<ProcessOutputError> for BackupRestoreError {
    fn from(value: ProcessOutputError) -> Self {
        Self::Unknown(Box::new(value))
    }
}
