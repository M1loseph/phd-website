use anyhow::{anyhow, bail, Error, Result};
use log::info;
use std::{cmp::Ordering, fs::DirEntry, path::PathBuf};

use super::semantic_version::SemanticVersion;

#[derive(Eq, PartialEq, Clone)]
pub struct MigrationDefinition {
    pub name: String,
    pub version: SemanticVersion,
    pub script: String,
}

pub struct FileMigrationDefinitionLoader {
    pub migration_files_directory: PathBuf,
    pub file_name_separator: String,
}

impl FileMigrationDefinitionLoader {
    fn create_migration_definition_from_file(
        &self,
        source: &DirEntry,
    ) -> Result<MigrationDefinition> {
        let file_name = source.file_name();

        let file_name = file_name.to_str().ok_or(anyhow!(
            "File with name `{:?}` is not a valid utf8 string",
            file_name
        ))?;
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
            None => Err(anyhow!("File {file_name} does not have two expected parts")),
        }
    }

    pub fn find_all_migrations(&self) -> Result<Vec<MigrationDefinition>> {
        let mut migration_files = std::fs::read_dir(&self.migration_files_directory)?
            .map(|entry| -> Result<MigrationDefinition> {
                let entry = entry?;
                let path = entry.path();
                if path.is_dir() {
                    bail!("There is a folder inside the migrations folder which is strictly forbidden.");
                }
                self.create_migration_definition_from_file(&entry)
            })
            .collect::<Result<Vec<MigrationDefinition>, Error>>()?;
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
