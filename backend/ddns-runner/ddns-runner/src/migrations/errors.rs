use log::error;
use std::error::Error;
use std::ffi::OsString;
use std::fmt::Display;

use super::semantic_version::SemanticVersion;

#[derive(Debug, PartialEq, Eq)]
pub enum MigrationError {
    IOError,
    DatabaseError,
    IncorrectMigrationTableName,
    FolderInsideMigrationsFolder,
    UnparsableFileName {
        file_name: OsString,
    },
    IncorrectFileName {
        file_name: String,
    },
    IncorrectSemanticVersion {
        sem_ver: String,
    },
    UnableToCreateMigrationTable,
    MissingMigrationDefinitions {
        found: u64,
        existing: u64,
    },
    MigrationNameChanged {
        version: SemanticVersion,
        expected: String,
        found: String,
    },
    MigrationFileNotRun {
        newest_version: SemanticVersion,
        found_version: SemanticVersion,
    },
    MigrationDefinitionContentHasChanges {
        version: SemanticVersion,
    },
}

impl Error for MigrationError {}

impl Display for MigrationError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            MigrationError::UnableToCreateMigrationTable => {
                write!(f, "Unable to create the migration table")
            }
            MigrationError::FolderInsideMigrationsFolder => write!(
                f,
                "There is a folder inside folder with migration files which is not allowed"
            ),
            MigrationError::UnparsableFileName { file_name } => {
                write!(f, "Migration file has incorrect name: {:?}", file_name)
            }
            MigrationError::IncorrectSemanticVersion { sem_ver } => {
                write!(f, "Semantic version '{}' is not correct", sem_ver)
            }
            MigrationError::IncorrectFileName { file_name } => {
                write!(f, "Migration file has incorrect name {}", file_name)
            }
            MigrationError::IOError => write!(f, "IOError has occurred"),
            MigrationError::IncorrectMigrationTableName => {
                write!(f, "Migration table can't be named like that")
            }
            MigrationError::DatabaseError => {
                write!(f, "Some error occurred when communicating with database")
            }
            MigrationError::MissingMigrationDefinitions { found, existing } => write!(
                f,
                "Found {found} migration definitions while there were {existing} already run"
            ),
            MigrationError::MigrationNameChanged {
                version,
                expected,
                found,
            } => write!(f, "Migration name does not match for version {}. Ran migration with name {}, but definition is named {}", version, expected, found),
            MigrationError::MigrationFileNotRun {
                newest_version,
                found_version 
            } => write!(f, "Found migration with version {}, but the newest migration has version {}", found_version, newest_version),
            MigrationError::MigrationDefinitionContentHasChanges {
                 version 
            } => write!(f, "Content of migration definition with version {} has changed (some other script has been already run)", version)
        }
    }
}

impl From<std::io::Error> for MigrationError {
    fn from(value: std::io::Error) -> Self {
        error!("IOError has occurred in migration module {}", value);
        MigrationError::IOError
    }
}

impl From<tokio_postgres::Error> for MigrationError {
    fn from(value: tokio_postgres::Error) -> Self {
        error!(
            "Some error occurred when communicating with database {}",
            value
        );
        MigrationError::DatabaseError
    }
}
