use std::{fs, process::Command};

struct PostgresBackuppingService {}

impl PostgresBackuppingService {
    pub fn create_postgres_backup() {
        Command::new("pg_dump")
            .args([
                "-U",
                "admin",
                "-p",
                "5432",
                "-h",
                "localhost",
                "-f",
                "local/backup.tar.gz",
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