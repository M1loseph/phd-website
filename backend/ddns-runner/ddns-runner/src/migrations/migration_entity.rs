use super::errors::MigrationError;
use super::{migration_definition::MigrationDefinition, semantic_version::SemanticVersion};
use log::error;
use regex::Regex;
use sha2::{Digest, Sha256};
use tokio_postgres::Row;

fn hash_function(script: &str) -> Vec<u8> {
    let mut hasher = Sha256::new();
    hasher.update(script);
    hasher.finalize().to_vec()
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

impl From<Row> for MigrationEntity {
    fn from(value: Row) -> Self {
        let version_string: String = value.get("version");
        MigrationEntity {
            id: value.get("id"),
            name: value.get("name"),
            version: SemanticVersion::try_from(version_string.as_str()).unwrap(),
            script_checksum: value.get("script_checksum"),
        }
    }
}

pub struct MigrationEntityRepository<'a> {
    table_name: String,
    client: &'a tokio_postgres::Client,
}

impl<'a> MigrationEntityRepository<'a> {
    pub async fn new(
        table_name: String,
        client: &'a tokio_postgres::Client,
    ) -> Result<Self, MigrationError> {
        let correct_table_name = Regex::new("[_a-zA-Z]+[_a-zA-Z0-9]{5, 25}").unwrap();
        if !correct_table_name.is_match(&table_name) {
            error!("Incorrect table name {table_name}");
            return Err(MigrationError::IncorrectMigrationTableName);
        }
        let repository = MigrationEntityRepository { table_name, client };
        repository.initialize_table().await?;
        Ok(repository)
    }

    async fn initialize_table(&self) -> Result<(), MigrationError> {
        let sql = format!(
            r#"
        CREATE TABLE IF NOT EXISTS "{}" (
            "id" BIGSERIAL PRIMARY KEY,
            "name" VARCHAR(255) NOT NULL,
            "version" VARCHAR(50) NOT NULL,
            "script_checksum" BYTEA NOT NULL
        )"#,
            self.table_name
        );
        self.client.execute(&sql, &[]).await?;
        Ok(())
    }

    pub async fn save_migration(&self, migration: MigrationEntity) -> Result<(), MigrationError> {
        let sql = format!(
            r#"INSERT INTO "{}"(name, version, script_checksum) VALUES ($1, $2, $3)"#,
            self.table_name
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

    pub async fn find_all_sorted(&self) -> Result<Vec<MigrationEntity>, MigrationError> {
        let sql = format!(
            r#"SELECT "id", "name", "version", "script_checksum" FROM "{}""#,
            self.table_name
        );
        let rows = self.client.query(&sql, &[]).await?;
        let mut rows: Vec<MigrationEntity> = rows
            .into_iter()
            .map(|row| MigrationEntity::from(row))
            .collect();
        rows.sort();
        Ok(rows)
    }
}
