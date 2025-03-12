use std::{
    collections::HashMap,
    fs,
    fs::File,
    io::{ErrorKind, Write},
    path::Path,
    str::FromStr,
    sync::{Mutex, MutexGuard},
};

use crate::backup_metadata::{
    Backup, BackupId, BackupMetadata, BackupMetadataRepository, BackupRepository, BackupTarget,
    BackupType, RepositoryError, RepositoryResult,
};
use log::info;
use rusqlite::{params, Connection, ErrorCode, Row};

static ARCHIVE_EXTENSION: &str = "gz";
static DELIMETER: &str = "_";
static MONGODB_DIR: &str = "mongodb";
static POSTGRES_DIR: &str = "postgres";

impl<'a> TryFrom<&Row<'a>> for BackupMetadata {
    type Error = RepositoryError;

    fn try_from(row: &Row<'a>) -> Result<Self, Self::Error> {
        let metadata = Self {
            backup_id: row.get::<usize, String>(0)?.parse::<u64>()?,
            host: row.get(1)?,
            created_at: row.get(2)?,
            backup_size_bytes: row.get::<usize, String>(3)?.parse::<u64>()?,
            backup_target: BackupTarget::from_str(&row.get::<usize, String>(4)?)?,
            backup_type: BackupType::from_str(&row.get::<usize, String>(5)?)?,
        };
        Ok(metadata)
    }
}

pub struct SQLiteBackupMetadataRepository {
    connection_pool: HashMap<u32, Mutex<Connection>>,
}

impl SQLiteBackupMetadataRepository {
    pub fn new(sqlite_path: String, connection_pool: u32) -> RepositoryResult<Self> {
        let sqlite_path = Path::new(&sqlite_path);
        if let Some(parent) = sqlite_path.parent() {
            fs::create_dir_all(parent).map_err(|err| RepositoryError::Unknown {
                cause: Box::new(err),
            })?;
        }
        let connections = (0..connection_pool)
            .into_iter()
            .map(|_| Connection::open(&sqlite_path).map_err(|e| RepositoryError::from(e)))
            .collect::<RepositoryResult<Vec<Connection>>>()?;

        let pool = connections
            .into_iter()
            .enumerate()
            .map(|(i, conn)| (i as u32, Mutex::new(conn)))
            .collect();

        Ok(Self {
            connection_pool: pool,
        })
    }

    fn get_pool_connection(&self) -> MutexGuard<Connection> {
        // Unwrapping here seems ok. It is said on reddit and rust forum that accessing poisoned data should
        // lead to panick.
        //
        // https://users.rust-lang.org/t/should-i-unwrap-a-mutex-lock/61519
        // https://www.reddit.com/r/rust/comments/xy2rkl/whats_the_best_way_to_avoid_an_unwrap_of_a_mutex/
        let index = rand::random::<u32>() % self.connection_pool.len() as u32;
        self.connection_pool[&index].lock().unwrap()
    }
}

impl BackupMetadataRepository for SQLiteBackupMetadataRepository {
    fn save(&self, backup_metadata: &BackupMetadata) -> RepositoryResult<()> {
        let query = r#"
            INSERT INTO "backup_metadata"("backup_id", "host", "created_at", "backup_size_bytes", "backup_target", "backup_type")
            VALUES (?1, ?2, ?3, ?4, ?5, ?6)
        "#;
        let connection = self.get_pool_connection();
        let mut statement = connection.prepare(query)?;

        let query_result = statement.execute(params![
            backup_metadata.backup_id.to_string(),
            backup_metadata.host,
            backup_metadata.created_at,
            backup_metadata.backup_size_bytes.to_string(),
            <&BackupTarget as Into<&str>>::into(&backup_metadata.backup_target),
            <&BackupType as Into<&str>>::into(&backup_metadata.backup_type),
        ]);
        query_result.map(|_| ()).map_err(|err| {
            if let Some(code) = err.sqlite_error_code() {
                if code == ErrorCode::ConstraintViolation {
                    return RepositoryError::IdAlreadyExists {
                        id: backup_metadata.backup_id,
                    };
                }
            }
            RepositoryError::from(err)
        })
    }

    fn find_by_id(&self, id: BackupId) -> RepositoryResult<Option<BackupMetadata>> {
        let query = r#"
            SELECT "backup_id", "host", "created_at", "backup_size_bytes", "backup_target", "backup_type"
            FROM "backup_metadata"
            WHERE "backup_id" = ?1
        "#;
        let connection = self.get_pool_connection();
        let mut statement = connection.prepare(query)?;
        let mut query_result = statement.query(params![id.to_string()])?;
        let backup_metadata = query_result
            .next()?
            .map(|row| BackupMetadata::try_from(row));
        match backup_metadata {
            None => Ok(None),
            Some(backup_metadata) => backup_metadata.map(|result| Some(result)),
        }
    }

    fn find_all(&self) -> RepositoryResult<Vec<BackupMetadata>> {
        let query = r#"
            SELECT "backup_id", "host", "created_at", "backup_size_bytes", "backup_target", "backup_type"
            FROM "backup_metadata"
        "#;
        let connection = self.get_pool_connection();
        let mut connection = connection.prepare(query)?;
        let rows = connection.query([])?;
        rows.and_then(|row| BackupMetadata::try_from(row)).collect()
    }

    fn delete_by_id(&self, id: BackupId) -> RepositoryResult<bool> {
        let query = r#"
            DELETE FROM "backup_metadata"
            WHERE "backup_id" = ?1
        "#;
        let connection = self.get_pool_connection();
        let mut statement = connection.prepare(query)?;
        let affected_rows = statement.execute(params![id.to_string()])?;
        return Ok(affected_rows == 1);
    }
}

pub struct FileSystemBackupRepository {
    target_directory: String,
}

impl FileSystemBackupRepository {
    pub fn new(target_directory: String) -> Self {
        Self { target_directory }
    }

    fn generate_file_name(&self, backup_metadata: &BackupMetadata) -> String {
        let timestmap_as_str = backup_metadata.created_at.to_rfc3339();
        let id = backup_metadata.backup_id.to_string();
        let host = &backup_metadata.host;
        let file_name = vec![id.as_str(), host, timestmap_as_str.as_str()].join(DELIMETER);
        format!("{file_name}.{ARCHIVE_EXTENSION}")
    }

    fn backup_directory(&self, backup_target: &BackupTarget) -> &str {
        match backup_target {
            BackupTarget::MongoDB => MONGODB_DIR,
            BackupTarget::Postgres => POSTGRES_DIR,
        }
    }
}

impl BackupRepository for FileSystemBackupRepository {
    fn save(&self, backup_metadata: &BackupMetadata, backup: Backup) -> RepositoryResult<()> {
        let output_dir = Path::new(&self.target_directory)
            .join(self.backup_directory(&backup_metadata.backup_target))
            .join(self.generate_file_name(&backup_metadata));

        info!(
            "Saving {} backup in {:?}...",
            backup_metadata.backup_target, output_dir
        );

        if let Some(parent) = output_dir.parent() {
            fs::create_dir_all(parent)?;
        }

        let mut output_file = File::create(output_dir)?;
        output_file.write_all(&backup)?;
        output_file.flush()?;
        Ok(())
    }

    fn find_by_metadata(
        &self,
        backup_location: &BackupMetadata,
    ) -> RepositoryResult<Option<Backup>> {
        let path = Path::new(&self.target_directory)
            .join(self.backup_directory(&backup_location.backup_target))
            .join(self.generate_file_name(&backup_location));

        info!("Loading backup from file {:?}...", path);
        match std::fs::read(path) {
            Ok(file_content) => Ok(Some(file_content)),
            Err(err) => {
                if err.kind() == ErrorKind::NotFound {
                    return Ok(None);
                }
                return Err(RepositoryError::from(err))?;
            }
        }
    }
}

impl From<rusqlite::Error> for RepositoryError {
    fn from(value: rusqlite::Error) -> Self {
        Self::new(value)
    }
}

impl From<std::num::ParseIntError> for RepositoryError {
    fn from(value: std::num::ParseIntError) -> Self {
        Self::new(value)
    }
}

impl From<std::io::Error> for RepositoryError {
    fn from(value: std::io::Error) -> Self {
        Self::new(value)
    }
}

impl From<strum::ParseError> for RepositoryError {
    fn from(value: strum::ParseError) -> Self {
        Self::new(value)
    }
}
