use crate::backup_metadata::BackupTarget;
use chrono::Local;
use log::error;
use std::fs;
use std::fs::File;
use std::io::{ErrorKind, Write};
use std::path::{Path, PathBuf};

static MONGODB_LOCK_FILE: &str = "mongodb.lock";
static POSTGRES_LOCK_FILE: &str = "postgres.lock";

pub struct LockManager {
    locks_directory: PathBuf,
}

#[derive(Debug)]
pub enum LockError {
    InvalidLocksDirectory {
        path: PathBuf,
        cause: std::io::Error,
    },
    LockAlreadyExists(PathBuf),
    UnexpectedError(std::io::Error),
}

impl LockManager {
    pub fn new(locks_directory: String) -> Result<Self, LockError> {
        let locks_directory = Path::new(&locks_directory).to_path_buf();
        fs::create_dir_all(&locks_directory)?;
        Ok(Self { locks_directory })
    }

    pub fn lock(&self, backup_target: BackupTarget) -> Result<Lock, LockError> {
        let lock_file_name = match backup_target {
            BackupTarget::MONGODB => MONGODB_LOCK_FILE,
            BackupTarget::POSTGRES => POSTGRES_LOCK_FILE,
        };
        let lock_file_path = self.locks_directory.join(lock_file_name);
        let lock_creation_time = Local::now();
        Lock::new(&lock_creation_time.to_rfc3339(), lock_file_path)
    }
}

pub struct Lock {
    lock_path: PathBuf,
}

impl Lock {
    fn new(file_content: &str, lock_path: PathBuf) -> Result<Self, LockError> {
        match File::create_new(&lock_path) {
            Ok(mut lock_file) => {
                lock_file.write_all(file_content.as_bytes())?;
                Ok(Lock { lock_path })
            }
            Err(err) => {
                return if err.kind() == ErrorKind::AlreadyExists {
                    Err(LockError::LockAlreadyExists(lock_path))
                } else {
                    Err(LockError::from(err))
                }
            }
        }
    }
}

impl Drop for Lock {
    fn drop(&mut self) {
        match fs::remove_file(&self.lock_path) {
            Ok(_) => (),
            Err(err) => error!("Failed to remove the lock file. Cause: {:?}", err),
        }
    }
}

impl From<std::io::Error> for LockError {
    fn from(err: std::io::Error) -> Self {
        LockError::UnexpectedError(err)
    }
}
