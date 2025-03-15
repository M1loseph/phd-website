use core::fmt;
use std::{error::Error as StdError, fmt::Debug};

use super::{model::{Backup, BackupId, BackupMetadata}, BackupTarget};
use crate::errorstack::to_error_stack;

pub enum RepositoryError {
    IdAlreadyExists { id: u64 },
    Unknown { cause: Box<dyn StdError> },
}

impl Debug for RepositoryError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        to_error_stack(f, self)
    }
}

impl RepositoryError {
    pub fn new_unknown(cause: impl StdError + 'static) -> Self {
        Self::Unknown {
            cause: Box::new(cause),
        }
    }
}

impl StdError for RepositoryError {
    fn source(&self) -> Option<&(dyn StdError + 'static)> {
        match self {
            RepositoryError::IdAlreadyExists { id: _ } => None,
            RepositoryError::Unknown { cause } => Some(cause.as_ref()),
        }
    }
}

impl fmt::Display for RepositoryError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            RepositoryError::IdAlreadyExists { id } => write!(f, "Id {id} is already in use."),
            RepositoryError::Unknown { cause } => {
                write!(f, "An unknown error has occurred.")
            }
        }
    }
}

pub type RepositoryResult<T> = std::result::Result<T, RepositoryError>;

pub trait BackupMetadataRepository: Send + Sync {
    fn save(&self, backup_metadata: &BackupMetadata) -> RepositoryResult<()>;

    fn find_by_id(&self, id: BackupId) -> RepositoryResult<Option<BackupMetadata>>;

    fn delete_by_id(&self, id: BackupId) -> RepositoryResult<bool>;

    fn find_by_backup_target(&self, backup_target: BackupTarget) -> RepositoryResult<Vec<BackupMetadata>>;
}

pub trait BackupRepository: Send + Sync {
    fn save(&self, backup_metadata: &BackupMetadata, blob: Backup) -> RepositoryResult<()>;

    fn find_by_metadata(
        &self,
        backup_metadata: &BackupMetadata,
    ) -> RepositoryResult<Option<Backup>>;
}
