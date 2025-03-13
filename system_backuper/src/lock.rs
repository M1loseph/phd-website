use crate::backup_metadata::BackupTarget;
use chrono::Local;
use log::error;
use std::error::Error as StdError;
use std::fmt::Display;
use std::fs::File;
use std::io::{ErrorKind, Write};
use std::path::{Path, PathBuf};
use std::{fmt, fs};

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

impl Display for LockError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            LockError::InvalidLocksDirectory { path, cause: _ } => writeln!(
                f,
                "Failed to create directory to store locks: {}",
                path.display()
            ),
            LockError::LockAlreadyExists(path) => writeln!(
                f,
                "Lock on the given path already exists: {}",
                path.display()
            ),
            LockError::UnexpectedError(_) => {
                writeln!(f, "Unexpected error ocurred when creating a lock")
            }
        }
    }
}

impl StdError for LockError {
    fn source(&self) -> Option<&(dyn StdError + 'static)> {
        match self {
            LockError::InvalidLocksDirectory { path: _, cause } => Some(cause),
            LockError::LockAlreadyExists(_) => None,
            LockError::UnexpectedError(error) => Some(error),
        }
    }
}

impl LockManager {
    pub fn new(locks_directory: String) -> Result<Self, LockError> {
        let locks_directory = Path::new(&locks_directory).to_path_buf();
        fs::create_dir_all(&locks_directory).map_err(|err| LockError::InvalidLocksDirectory {
            path: locks_directory.clone(),
            cause: err,
        })?;
        Ok(Self { locks_directory })
    }

    pub fn lock(&self, backup_target: BackupTarget) -> Result<Lock, LockError> {
        let lock_file_name = match backup_target {
            BackupTarget::MongoDB => MONGODB_LOCK_FILE,
            BackupTarget::Postgres => POSTGRES_LOCK_FILE,
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
