use super::errors::MigrationError;
use super::migration_definition::{
    FileMigrationDefinitionFactory, MigrationDefinition, MigrationDefinitionFactory,
};
use super::migration_entity::{MigrationEntity, MigrationEntityRepository};
use log::info;
use std::cmp::Ordering;
use std::iter;
use std::path::PathBuf;
use std::str::FromStr;

pub type Result<T> = std::result::Result<T, Box<dyn std::error::Error>>;

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

pub struct MigrationRunner<'a> {
    migration_definitions_source: Box<dyn MigrationDefinitionFactory>,
    migration_entity_repository: MigrationEntityRepository<'a>,
    client: &'a tokio_postgres::Client,
}

impl<'a> MigrationRunner<'a> {
    pub async fn new(
        config: MigrationRunnerConfiguration,
        client: &'a tokio_postgres::Client,
    ) -> Result<Self> {
        let source = Box::new(FileMigrationDefinitionFactory {
            migration_files_directory: config.migrations_files_directory,
            file_name_separator: config.file_name_separator,
        });
        let repository =
            MigrationEntityRepository::new(config.migrations_meta_data_table_name, &client).await?;
        let runner = MigrationRunner {
            migration_definitions_source: source,
            migration_entity_repository: repository,
            client,
        };
        Ok(runner)
    }

    pub async fn run_migrations(&self) -> Result<()> {
        let migration_definitions = self.migration_definitions_source.create_migrations()?;
        let already_existing_migrations =
            self.migration_entity_repository.find_all_sorted().await?;

        let found_migrations_len = migration_definitions.len();
        let ran_migrations_len = already_existing_migrations.len();
        let newest_version = already_existing_migrations.last().map(|me| me.version);

        info!("Found {found_migrations_len} migration files, {ran_migrations_len} migration has already been run");

        let iterator = match found_migrations_len.cmp(&ran_migrations_len) {
            Ordering::Less => Err(MigrationError::MissingMigrationDefinitions {
                found: u64::try_from(found_migrations_len).unwrap(),
                existing: u64::try_from(ran_migrations_len).unwrap(),
            }),
            Ordering::Equal | Ordering::Greater => Ok(migration_definitions.into_iter().zip(
                already_existing_migrations
                    .into_iter()
                    .map(|def| Some(def))
                    .chain(iter::repeat(None)),
            )),
        }?;

        for (migration_definition, ran_migration) in iterator {
            if let Some(ran_migration) = ran_migration {
                if migration_definition.version != ran_migration.version {
                    return Err(Box::new(MigrationError::MigrationFileNotRun {
                        newest_version: newest_version.unwrap(),
                        found_version: migration_definition.version,
                    }));
                }
                if migration_definition.name != ran_migration.name {
                    return Err(Box::new(MigrationError::MigrationNameChanged {
                        version: migration_definition.version,
                        expected: ran_migration.name,
                        found: migration_definition.name,
                    }));
                }
                if !ran_migration.script_matches_checksum(&migration_definition.script) {
                    return Err(Box::new(
                        MigrationError::MigrationDefinitionContentHasChanges {
                            version: migration_definition.version,
                        },
                    ));
                }
                info!(
                    "Migration {} {} has already been run, skipping it",
                    migration_definition.version, migration_definition.name
                );
                continue;
            }
            info!(
                "Executing migration {} - {}",
                migration_definition.version, migration_definition.name
            );
            self.run_migration_script(&migration_definition).await?;
            self.migration_entity_repository
                .save_migration(MigrationEntity::from(&migration_definition))
                .await?;
        }
        Ok(())
    }

    async fn run_migration_script(&self, migration: &MigrationDefinition) -> Result<()> {
        self.client.execute(&migration.script, &[]).await?;
        Ok(())
    }
}
