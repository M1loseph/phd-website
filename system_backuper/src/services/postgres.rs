use std::{fs, process::Command, sync::Arc};

use crate::backup_metadata::{BackupMetadataRepository, BackupRepository};


struct PgAdminOptions {
    password: String,
    username: String,
    port: u32,
    host: String,
    database: String
}

pub struct PostgresBackuppingService {
    backup_metadata_repository: Arc<dyn BackupMetadataRepository>,
    backup_repository: Arc<dyn BackupRepository>,
}

impl PostgresBackuppingService {
    pub fn new(
        backup_metadata_repository: Arc<dyn BackupMetadataRepository>,
        backup_repository: Arc<dyn BackupRepository>,
    ) -> Self {
        Self {
            backup_metadata_repository,
            backup_repository,
        }
    }
}

impl PostgresBackuppingService {
    pub fn create_postgres_backup() {
        // TODO: capture tar output, gzip it and save to file
        Command::new("pg_dump")
            .args([
                "-U",
                "admin",
                "-p",
                "5432",
                "-h",
                "localhost",
                "--format",
                "t",
                "admin",
            ])
            .env("PGPASSWORD", "admin")
            .status()
            .unwrap();
        fs::rename("local/backup.tar.gz", "local/backup-final.tar.gz").unwrap();
    }
}
