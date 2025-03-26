use crate::migration_entity::SqlClientAdapter;

use super::migration_definition::FileMigrationDefinitionLoader;
use super::migration_entity::MigrationEntity;
use anyhow::{bail, Result};
use log::info;
use std::path::PathBuf;
use std::str::FromStr;

pub struct MigrationRunnerConfiguration {
    pub migrations_meta_data_table_name: String,
    pub file_name_separator: String,
    pub migrations_files_directory: PathBuf,
}

impl Default for MigrationRunnerConfiguration {
    fn default() -> Self {
        Self {
            migrations_meta_data_table_name: "MigrationsMetaData".to_string(),
            migrations_files_directory: PathBuf::from_str("./migrations").unwrap(),
            file_name_separator: "--".to_string(),
        }
    }
}

pub struct MigrationRunner<T>
where
    T: SqlClientAdapter,
{
    migration_table: String,
    loader: FileMigrationDefinitionLoader,
    client_adapter: T,
}

impl<T: SqlClientAdapter> MigrationRunner<T> {
    pub fn new(config: MigrationRunnerConfiguration, client_adapter: T) -> Self {
        let loader = FileMigrationDefinitionLoader {
            migration_files_directory: config.migrations_files_directory,
            file_name_separator: config.file_name_separator,
        };
        Self {
            migration_table: config.migrations_meta_data_table_name,
            loader,
            client_adapter,
        }
    }

    pub async fn run_migrations(&self) -> Result<()> {
        self.client_adapter
            .validate_table_name(&self.migration_table)?;
        self.client_adapter
            .initialize_migrations_table(&self.migration_table)
            .await?;

        let migration_definitions = self.loader.find_all_migrations()?;
        let applied_migrations = self
            .client_adapter
            .find_all_sorted(&self.migration_table)
            .await?;
        let latest_applied = applied_migrations.last();

        let (older_definitions, new_definitions): (Vec<_>, Vec<_>) =
            migration_definitions.iter().partition(|def| {
                if let Some(latest) = latest_applied {
                    return def.version <= latest.version;
                }
                false
            });

        for applied in &applied_migrations {
            let definition = migration_definitions
                .iter()
                .filter(|def| def.version == applied.version)
                .next();
            let definition = match definition {
                Some(definition) => definition,
                None => {
                    bail!("Migration {} was applied to the database but it is not present in the migration definitions", applied.version)
                }
            };
            if definition.name != applied.name {
                bail!(
                    "Migration {} name was changed from {} to {}",
                    definition.version,
                    applied.name,
                    definition.name
                );
            }
            if !applied.script_matches_checksum(&definition.script) {
                bail!(
                    "Migration {} content was changed - the checksum is not equal",
                    definition.version,
                );
            }
        }

        for definition in &older_definitions {
            if !applied_migrations
                .iter()
                .any(|applied| applied.version == definition.version)
            {
                // TODO: after changeds we panic here
                let latest_version = latest_applied.unwrap().version;
                bail!(
                    "Found migration definition with version {} while newer versions (like {}) have already been applied.",
                    definition.version, latest_version
                );
            }
        }

        for definition in new_definitions {
            info!(
                "Executing migration {} - {}",
                definition.version, definition.name
            );
            self.client_adapter.execute(&definition.script).await?;
            self.client_adapter
                .save(&self.migration_table, MigrationEntity::from(definition))
                .await?;
        }
        Ok(())
    }
}
