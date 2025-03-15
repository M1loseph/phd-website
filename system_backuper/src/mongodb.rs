use crate::backup_metadata::{
    BackupId, BackupMetadata, BackupMetadataRepository, BackupRepository, BackupTarget, BackupType,
    RandomId, RepositoryError,
};
use crate::errorstack::to_error_stack;
use crate::lock::{LockError, LockManager};
use crate::process::IntoResult;
use chrono::Local;
use log::info;
use std::error::Error as StdError;
use std::fmt::{Debug, Display};
use std::io::Write;
use std::path::Path;
use std::process::{Command, Stdio};
use std::sync::Arc;
use std::{fmt, fs};
use url::Url;

static MONGO_CONFIG_FILE_NAME: &str = "mongo.yml";
static METADATA_SAVE_RETRIES: u8 = 3;

pub enum BackupError {
    InitializationError(String, Box<dyn StdError>),
    BackupTargetLocked(BackupTarget),
    BackupDoesNotExist(BackupId),
    Unknown(Option<String>, Option<Box<dyn StdError>>),
}

impl StdError for BackupError {
    fn source(&self) -> Option<&(dyn StdError + 'static)> {
        match self {
            BackupError::InitializationError(_, error) => Some(error.as_ref()),
            BackupError::BackupTargetLocked(_) => None,
            BackupError::BackupDoesNotExist(_) => None,
            BackupError::Unknown(_, error) => match error {
                Some(err) => Some(err.as_ref()),
                None => None,
            },
        }
    }
}

impl Debug for BackupError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        to_error_stack(f, self)
    }
}

impl BackupError {
    fn unknown_with_cause(err: impl StdError + 'static) -> Self {
        BackupError::Unknown(None, Some(Box::new(err)))
    }

    fn unknown_without_cause(description: String) -> Self {
        BackupError::Unknown(Some(description), None)
    }
}

impl Display for BackupError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            BackupError::InitializationError(user_message, _) => write!(f, "{}", user_message),
            BackupError::BackupTargetLocked(backup_target) => write!(
                f,
                "Backup target {} is undergoing another operation. Retry later.",
                backup_target
            ),
            BackupError::BackupDoesNotExist(id) => write!(f, "Did not find backup with id {}.", id),
            BackupError::Unknown(err_message, _) => {
                write!(f, "An unexpected error ocurred.")?;
                if let Some(err_message) = err_message {
                    write!(f, " {}", err_message)?;
                }
                Ok(())
            }
        }
    }
}

impl From<LockError> for BackupError {
    fn from(lock_error: LockError) -> Self {
        match &lock_error {
            LockError::LockAlreadyExists(_) => Self::BackupTargetLocked(BackupTarget::MongoDB),
            _ => Self::unknown_with_cause(lock_error),
        }
    }
}

type BackupResult<T> = std::result::Result<T, BackupError>;

pub struct MongoDBBackuppingService {
    mongodump_config_file_path: String,
    mongo_uri: Url,
    lock_manager: Arc<LockManager>,
    backup_repository: Arc<dyn BackupRepository + Sync>,
    backup_metadata_repository: Arc<dyn BackupMetadataRepository + Sync>,
}

impl From<RepositoryError> for BackupError {
    fn from(err: RepositoryError) -> Self {
        Self::unknown_with_cause(err)
    }
}

impl MongoDBBackuppingService {
    pub fn new(
        mongodump_config_file_folder: String,
        mongo_uri: String,
        lock_manager: Arc<LockManager>,
        backup_repository: Arc<dyn BackupRepository>,
        backup_metadata_repository: Arc<dyn BackupMetadataRepository>,
    ) -> BackupResult<Self> {
        let mongodump_config_file_path =
            Self::create_config_file(&mongodump_config_file_folder, &mongo_uri)?;
        let mongo_uri = Url::parse(&mongo_uri).map_err(|err| {
            BackupError::InitializationError(
                format!("Failed to parse mongodb URI: {}", mongo_uri),
                Box::new(err),
            )
        })?;

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
    ) -> BackupResult<String> {
        fs::create_dir_all(mongodump_config_file_folder).map_err(|err| {
            BackupError::InitializationError(
                "Failed to create configuration file folder structure".to_string(),
                Box::new(err),
            )
        })?;
        let mongodump_config_file_path =
            Path::new(mongodump_config_file_folder).join(MONGO_CONFIG_FILE_NAME);
        let file_content = format!("uri: {uri}");

        fs::write(&mongodump_config_file_path, file_content).map_err(|err| {
            BackupError::InitializationError(
                "Failed to create configuration file".to_string(),
                Box::new(err),
            )
        })?;
        Ok(mongodump_config_file_path.to_str().unwrap().to_string())
    }

    pub fn create_mongodb_backup(&self, backup_type: BackupType) -> BackupResult<BackupMetadata> {
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
            .map_err(|err| BackupError::unknown_with_cause(err))?
            .into_result()
            .map_err(|err| BackupError::unknown_with_cause(err))?;

        let blob = output.stdout;
        let blob_size = blob.len() as u64;

        let backup_metadata: BackupMetadata = (|| -> BackupResult<BackupMetadata> {
            let mut i = 1;
            loop {
                let backup_metadata = BackupMetadata {
                    backup_id: BackupId::random(),
                    host: self.mongo_uri.host().unwrap().to_string(),
                    created_at: Local::now().fixed_offset(),
                    backup_size_bytes: blob_size,
                    backup_target: BackupTarget::MongoDB,
                    backup_type: backup_type.clone(),
                };

                match self.backup_metadata_repository.save(&backup_metadata) {
                    Ok(_) => return Ok(backup_metadata),
                    Err(err) => {
                        match err {
                            RepositoryError::IdAlreadyExists { id } => {
                                if i == METADATA_SAVE_RETRIES {
                                    return Err(BackupError::from(err));
                                } else {
                                    info!("Creating backup failed - id {id} already exists. Retrying...");
                                }
                            }
                            _ => return Err(BackupError::from(err)),
                        }
                    }
                };
                i += 1;
            }
        })()?;
        if let Err(err) = self.backup_repository.save(&backup_metadata, blob) {
            self.backup_metadata_repository
                .delete_by_id(backup_metadata.backup_id)?;
            return Err(BackupError::from(err));
        }

        Ok(backup_metadata)
    }

    pub fn read_all_mongodb_backups(&self) -> BackupResult<Vec<BackupMetadata>> {
        let backups = self.backup_metadata_repository.find_all()?;
        Ok(backups)
    }

    pub fn restore_backup(&self, backup_id: u64, drop: bool) -> BackupResult<()> {
        let _lock = self.lock_manager.lock(BackupTarget::MongoDB)?;

        let backup_metada = self
            .backup_metadata_repository
            .find_by_id(backup_id)?
            .ok_or(BackupError::BackupDoesNotExist(backup_id))?;

        let backup = self
            .backup_repository
            .find_by_metadata(&backup_metada)?
            .ok_or_else(|| {
                BackupError::unknown_without_cause(
                    format!("There is metadata for backup with id {backup_id}, but there is no backup binary.")
                )
            })?;
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
            .spawn()
            .map_err(|err| BackupError::unknown_with_cause(err))?;

        child
            .stdin
            .take()
            .unwrap()
            .write_all(&backup)
            .map_err(|err| BackupError::unknown_with_cause(err))?;

        let exit_code = child
            .wait()
            .map_err(|err| BackupError::unknown_with_cause(err))?;
        if exit_code.success() {
            Ok(())
        } else {
            Err(BackupError::unknown_without_cause(format!(
                "Running mongorestore failed. Exist code: {exit_code}"
            )))
        }
    }
}
