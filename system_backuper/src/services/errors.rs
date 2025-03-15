use crate::{
    backup_metadata::{BackupFormat, BackupId, BackupTarget},
    errorstack::to_error_stack,
};
use std::{
    error::Error as StdError,
    fmt::{self, Debug, Display},
};

pub enum MongoDBBackuppingServiceInitializationError {
    InvalidMonogoDBUri(String, Box<dyn StdError>),
    FailedToCreateConfigurationFile(Box<dyn StdError>),
}

impl StdError for MongoDBBackuppingServiceInitializationError {
    fn source(&self) -> Option<&(dyn StdError + 'static)> {
        match self {
            MongoDBBackuppingServiceInitializationError::InvalidMonogoDBUri(_, error) => Some(error.as_ref()),
            MongoDBBackuppingServiceInitializationError::FailedToCreateConfigurationFile(error) => Some(error.as_ref()),
        }
    }
}

impl Debug for MongoDBBackuppingServiceInitializationError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        to_error_stack(f, self)
    }
}

impl Display for MongoDBBackuppingServiceInitializationError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            MongoDBBackuppingServiceInitializationError::InvalidMonogoDBUri(uri, _) => {
                write!(f, "Failed to parse MongoDB URI {}", uri)
            }
            MongoDBBackuppingServiceInitializationError::FailedToCreateConfigurationFile(_) => {
                write!(f, "Failed to create configuration file")
            }
        }
    }
}

pub enum PorstgresBackuppingServiceInitializationError {
    InvalidMonogoDBUri(String, Box<dyn StdError>),
    FailedToCreateConfigurationFile(Box<dyn StdError>),
}

pub enum BackupCreateError {
    BackupTargetLocked(BackupTarget),
    Unknown(Box<dyn StdError>),
}

impl StdError for BackupCreateError {
    fn source(&self) -> Option<&(dyn StdError + 'static)> {
        match self {
            BackupCreateError::BackupTargetLocked(_) => None,
            BackupCreateError::Unknown(error) => Some(error.as_ref()),
        }
    }
}

impl Debug for BackupCreateError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        to_error_stack(f, self)
    }
}

impl Display for BackupCreateError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            BackupCreateError::BackupTargetLocked(backup_target) => write!(
                f,
                "Backup target {backup_target} is undegoing another opearation."
            ),
            BackupCreateError::Unknown(_) => write!(f, "An unknown error has occurred."),
        }
    }
}

pub enum BackupRestoreError {
    BackupTargetLocked(BackupTarget),
    BackupDoesNotExist(BackupId),
    InconsistantData(BackupId),
    UnsupportedFormat(BackupFormat),
    Unknown(Box<dyn StdError>),
}

impl StdError for BackupRestoreError {
    fn source(&self) -> Option<&(dyn StdError + 'static)> {
        match self {
            BackupRestoreError::BackupTargetLocked(_) => None,
            BackupRestoreError::BackupDoesNotExist(_) => None,
            BackupRestoreError::InconsistantData(_) => None,
            BackupRestoreError::UnsupportedFormat(_) => None,
            BackupRestoreError::Unknown(error) => Some(error.as_ref()),
        }
    }
}

impl Debug for BackupRestoreError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        to_error_stack(f, self)
    }
}

impl Display for BackupRestoreError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            BackupRestoreError::BackupTargetLocked(backup_target) => write!(
                f,
                "Backup target {} is undergoing another operation.",
                backup_target
            ),
            BackupRestoreError::BackupDoesNotExist(id) => {
                write!(f, "Did not find backup with id {}.", id)
            }
            BackupRestoreError::Unknown(_) => write!(f, "An unexpected error occurred."),
            BackupRestoreError::InconsistantData(backup_id) => {
                write!(f, "Missing backup binary for backup_id {}", backup_id)
            }
            BackupRestoreError::UnsupportedFormat(backup_format) => {
                write!(f, "Can't restore backup with format {backup_format}")
            }
        }
    }
}

pub enum BackupFindError {
    Unknown(Box<dyn StdError>),
}

impl StdError for BackupFindError {
    fn source(&self) -> Option<&(dyn StdError + 'static)> {
        match self {
            BackupFindError::Unknown(error) => Some(error.as_ref()),
        }
    }
}

impl Display for BackupFindError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            BackupFindError::Unknown(_) => write!(f, "An unexpected error occurred."),
        }
    }
}

impl Debug for BackupFindError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        to_error_stack(f, self)
    }
}
