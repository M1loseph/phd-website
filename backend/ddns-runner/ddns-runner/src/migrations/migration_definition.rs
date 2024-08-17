use log::info;
use std::{cmp::Ordering, fs::DirEntry, path::PathBuf};

use super::{errors::MigrationError, semantic_version::SemanticVersion};

#[derive(Eq, PartialEq, Clone)]
pub struct MigrationDefinition {
    pub name: String,
    pub version: SemanticVersion,
    pub script: String,
}

pub trait MigrationDefinitionFactory {
    fn create_migrations(&self) -> Result<Vec<MigrationDefinition>, MigrationError>;
}

pub struct FileMigrationDefinitionFactory {
    pub migration_files_directory: PathBuf,
    pub file_name_separator: String,
}

impl FileMigrationDefinitionFactory {
    fn create_migration(&self, source: &DirEntry) -> Result<MigrationDefinition, MigrationError> {
        let file_name = source.file_name();

        let file_name = file_name
            .to_str()
            .ok_or(MigrationError::UnparsableFileName {
                file_name: file_name.clone(),
            })?;
        info!("Reading migration file {file_name}");
        let script = std::fs::read_to_string(source.path())?;
        match file_name.split_once(&self.file_name_separator) {
            Some((semantic_version, migration_name_with_file_extension)) => {
                let semantic_version = SemanticVersion::try_from(semantic_version)?;
                let migration_name = migration_name_with_file_extension
                    .find('.')
                    .map(|file_extension_index| {
                        &migration_name_with_file_extension[..file_extension_index]
                    })
                    .unwrap_or(migration_name_with_file_extension);
                Ok(MigrationDefinition {
                    name: migration_name.to_string(),
                    version: semantic_version,
                    script,
                })
            }
            None => Err(MigrationError::IncorrectFileName {
                file_name: String::from(file_name),
            }),
        }
    }
}

impl MigrationDefinitionFactory for FileMigrationDefinitionFactory {
    fn create_migrations(&self) -> Result<Vec<MigrationDefinition>, MigrationError> {
        let mut migration_files = std::fs::read_dir(&self.migration_files_directory)?
            .map(|entry| -> Result<MigrationDefinition, MigrationError> {
                let entry = entry?;
                let path = entry.path();
                if path.is_dir() {
                    return Err(MigrationError::FolderInsideMigrationsFolder);
                }
                self.create_migration(&entry)
            })
            .collect::<Result<Vec<MigrationDefinition>, MigrationError>>()?;
        migration_files.sort();
        Ok(migration_files)
    }
}

impl PartialOrd for MigrationDefinition {
    fn partial_cmp(&self, other: &Self) -> Option<Ordering> {
        Some(self.cmp(other))
    }
}

impl Ord for MigrationDefinition {
    fn cmp(&self, other: &Self) -> std::cmp::Ordering {
        self.version.cmp(&other.version)
    }
}
