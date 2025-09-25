use std::future::Future;

use super::{migration_definition::MigrationDefinition, semantic_version::SemanticVersion};
use anyhow::{bail, Result};
use regex::Regex;
use sha2::{Digest, Sha256};

pub trait SqlClientAdapter {
    fn validate_table_name(&self, table_name: &str) -> Result<()>;

    fn initialize_migrations_table(&self, table_name: &str) -> impl Future<Output = Result<()>>;

    fn execute(&self, migration: &str) -> impl Future<Output = Result<()>>;

    fn save(
        &self,
        table_name: &str,
        migration: MigrationEntity,
    ) -> impl Future<Output = Result<()>>;

    fn find_all_sorted(
        &self,
        table_name: &str,
    ) -> impl Future<Output = Result<Vec<MigrationEntity>>>;
}

fn hash_function(script: &str) -> Vec<u8> {
    let mut hasher = Sha256::new();
    hasher.update(script);
    hasher.finalize().to_vec()
}

fn check_table_name_with_regex(table_name: &str) -> Result<()> {
    let correct_table_name = Regex::new("[_a-zA-Z]+[_a-zA-Z0-9]{5, 25}").unwrap();
    if !correct_table_name.is_match(&table_name) {
        bail!("Provided table name {table_name} is invalid")
    }
    Ok(())
}

#[derive(PartialEq, Eq, Clone)]
pub struct MigrationEntity {
    id: Option<i64>,
    pub name: String,
    pub version: SemanticVersion,
    script_checksum: Vec<u8>,
}

impl MigrationEntity {
    pub fn script_matches_checksum(&self, script: &str) -> bool {
        let script_hash = hash_function(script);
        self.script_checksum == script_hash
    }
}

impl PartialOrd for MigrationEntity {
    fn partial_cmp(&self, other: &Self) -> Option<std::cmp::Ordering> {
        self.version.partial_cmp(&other.version)
    }
}

impl Ord for MigrationEntity {
    fn cmp(&self, other: &Self) -> std::cmp::Ordering {
        self.version.cmp(&other.version)
    }
}

impl From<&MigrationDefinition> for MigrationEntity {
    fn from(value: &MigrationDefinition) -> Self {
        MigrationEntity {
            id: None,
            name: value.name.clone(),
            version: value.version.clone(),
            script_checksum: hash_function(&value.script),
        }
    }
}

#[cfg(feature = "postgres")]
pub mod postgres {
    use super::{check_table_name_with_regex, SqlClientAdapter};
    use anyhow::{Error, Result};
    use tokio_postgres::Row;

    use crate::semantic_version::SemanticVersion;

    use super::MigrationEntity;

    impl TryFrom<Row> for MigrationEntity {
        type Error = Error;

        fn try_from(value: Row) -> Result<Self> {
            let version_string: String = value.try_get("version")?;
            let entity = MigrationEntity {
                id: value.try_get("id")?,
                name: value.try_get("name")?,
                version: SemanticVersion::try_from(version_string.as_str())?,
                script_checksum: value.try_get("script_checksum")?,
            };
            Ok(entity)
        }
    }

    pub struct PostgresSQLClientAdapter<'a> {
        client: &'a tokio_postgres::Client,
    }

    impl<'a> PostgresSQLClientAdapter<'a> {
        pub fn new(client: &'a tokio_postgres::Client) -> Self {
            PostgresSQLClientAdapter { client }
        }
    }

    impl<'a> SqlClientAdapter for PostgresSQLClientAdapter<'a> {
        fn validate_table_name(&self, table_name: &str) -> Result<()> {
            check_table_name_with_regex(table_name)
        }

        async fn initialize_migrations_table(&self, table_name: &str) -> Result<()> {
            let sql = format!(
                r#"
                CREATE TABLE IF NOT EXISTS "{}" (
                    "id" BIGSERIAL PRIMARY KEY,
                    "name" VARCHAR(255) NOT NULL,
                    "version" VARCHAR(50) NOT NULL,
                    "script_checksum" BYTEA NOT NULL
                )"#,
                table_name
            );
            self.client.execute(&sql, &[]).await?;
            Ok(())
        }

        async fn save(&self, table_name: &str, migration: MigrationEntity) -> Result<()> {
            let sql = format!(
                r#"INSERT INTO "{}"(name, version, script_checksum) VALUES ($1, $2, $3)"#,
                table_name
            );
            self.client
                .execute(
                    &sql,
                    &[
                        &migration.name,
                        &String::from(&migration.version),
                        &migration.script_checksum,
                    ],
                )
                .await?;
            Ok(())
        }

        async fn find_all_sorted(&self, table_name: &str) -> Result<Vec<MigrationEntity>> {
            let sql = format!(
                r#"SELECT "id", "name", "version", "script_checksum" FROM "{}""#,
                table_name
            );
            let rows = self.client.query(&sql, &[]).await?;
            let mut rows = rows
                .into_iter()
                .map(|row| MigrationEntity::try_from(row))
                .collect::<Result<Vec<MigrationEntity>>>()?;
            rows.sort();
            Ok(rows)
        }

        async fn execute(&self, migration: &str) -> Result<()> {
            self.client.batch_execute(migration).await?;
            Ok(())
        }
    }
}

#[cfg(feature = "sqlite")]
pub mod sqlite {
    use super::{check_table_name_with_regex, SqlClientAdapter};
    use anyhow::{Error, Result};
    use rusqlite::{params, Row};

    use crate::semantic_version::SemanticVersion;

    use super::MigrationEntity;

    impl<'a> TryFrom<&Row<'a>> for MigrationEntity {
        type Error = Error;
        fn try_from(value: &Row) -> Result<Self> {
            let version_string: String = value.get("version")?;
            let entity = MigrationEntity {
                id: value.get("id")?,
                name: value.get("name")?,
                version: SemanticVersion::try_from(version_string.as_str())?,
                script_checksum: value.get("script_checksum")?,
            };
            Ok(entity)
        }
    }

    pub struct SqliteClientAdapter<'a> {
        client: &'a rusqlite::Connection,
    }

    impl<'a> SqliteClientAdapter<'a> {
        pub fn new(client: &'a rusqlite::Connection) -> Self {
            SqliteClientAdapter { client }
        }
    }

    impl<'a> SqlClientAdapter for SqliteClientAdapter<'a> {
        fn validate_table_name(&self, table_name: &str) -> Result<()> {
            check_table_name_with_regex(table_name)
        }

        async fn initialize_migrations_table(&self, table_name: &str) -> Result<()> {
            let sql = format!(
                r#"
                CREATE TABLE IF NOT EXISTS "{}" (
                    "id" INTEGER PRIMARY KEY AUTOINCREMENT,
                    "name" TEXT NOT NULL,
                    "version" TEXT NOT NULL,
                    "script_checksum" BLOB NOT NULL
                )"#,
                table_name
            );
            self.client.execute(&sql, params![])?;
            Ok(())
        }
        async fn save(&self, table_name: &str, migration: MigrationEntity) -> Result<()> {
            let sql = format!(
                r#"INSERT INTO "{}"("name", "version", "script_checksum") VALUES ($1, $2, $3)"#,
                table_name
            );
            self.client.execute(
                &sql,
                params![
                    &migration.name,
                    &String::from(&migration.version),
                    &migration.script_checksum,
                ],
            )?;
            Ok(())
        }

        async fn find_all_sorted(&self, table_name: &str) -> Result<Vec<MigrationEntity>> {
            let sql = format!(
                r#"SELECT "id", "name", "version", "script_checksum" FROM "{}""#,
                table_name
            );
            let mut statement = self.client.prepare(&sql)?;
            let rows = statement.query(params![])?;
            let mut rows: Vec<MigrationEntity> = rows
                .and_then(|row| MigrationEntity::try_from(row))
                .collect::<Result<_>>()?;
            rows.sort();
            Ok(rows)
        }

        async fn execute(&self, migration: &str) -> Result<()> {
            self.client.execute(migration, params![])?;
            Ok(())
        }
    }
}
