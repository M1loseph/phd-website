use crate::errorstack::to_error_stack;
use std::path::Path;
use std::process::Stdio;
use std::{fs, process::Command};

use crate::model::{BackupMetadataRepository, BackupRepository};

use crate::process::IntoResult;
use crate::{model::Backup, process::ProcessOutputError};
use std::error::Error as StdError;
use std::fmt::{Debug, Display};
use std::io::{Error as IOError, Write};

pub struct StrategyError(Box<dyn StdError>);

impl StdError for StrategyError {
    fn cause(&self) -> Option<&dyn StdError> {
        Some(self.0.as_ref())
    }
}

impl Display for StrategyError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "An internal error has occurred.")
    }
}

impl Debug for StrategyError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        to_error_stack(f, self)
    }
}

pub trait BackupStrategy: Send + Sync {
    fn create_backup(&self, connection_string: &str) -> Result<Backup, StrategyError>;

    fn restore_backup(
        &self,
        connection_string: &str,
        drop: bool,
        backup: Backup,
    ) -> Result<(), StrategyError>;
}

static FILE_NAME_CHARACTERS: u32 = 16;

pub struct MongoDBCompressedBackupStrategy {
    mongodump_config_file_folder: String,
}

struct ConfigFileRAII {
    path: String,
}

impl Drop for ConfigFileRAII {
    fn drop(&mut self) {
        let _ = fs::remove_file(&self.path);
    }
}

impl MongoDBCompressedBackupStrategy {
    pub fn new(mongodump_config_file_folder: String) -> Result<Self, StrategyError> {
        fs::create_dir_all(&mongodump_config_file_folder)?;
        Ok(MongoDBCompressedBackupStrategy {
            mongodump_config_file_folder,
        })
    }

    fn create_config_file(&self, connection_string: &str) -> Result<ConfigFileRAII, StrategyError> {
        let file_name = self.random_file_name();
        let mongodump_config_file_path =
            Path::new(&self.mongodump_config_file_folder).join(file_name);
        let file_content = format!("uri: {connection_string}");

        fs::write(&mongodump_config_file_path, file_content)?;

        let config_file = ConfigFileRAII {
            path: mongodump_config_file_path.to_str().unwrap().to_string(),
        };
        Ok(config_file)
    }

    fn random_file_name(&self) -> String {
        let file_name = (0..FILE_NAME_CHARACTERS)
            .into_iter()
            .map(|_| rand::random::<char>())
            .collect::<String>();
        format!("{file_name}.yaml")
    }
}

impl BackupStrategy for MongoDBCompressedBackupStrategy {
    fn create_backup(&self, connection_string: &str) -> Result<Backup, StrategyError> {
        let config_file = self.create_config_file(connection_string)?;
        let output = Command::new("mongodump")
            .args(["--config", &config_file.path, "--gzip", "--archive"])
            .output()?
            .into_result()?;
        let blob = output.stdout;
        Ok(blob)
    }

    fn restore_backup(
        &self,
        connection_string: &str,
        drop: bool,
        backup: Backup,
    ) -> Result<(), StrategyError> {
        let config_file = self.create_config_file(connection_string)?;
        let mut args = vec!["--config", &config_file.path, "--gzip", "--archive"];
        if drop {
            args.push("--drop");
        }

        let mut child = Command::new("mongorestore")
            .args(args)
            .stdin(Stdio::piped())
            .spawn()?;

        child.stdin.take().unwrap().write_all(&backup)?;

        let _ = child.wait_with_output()?.into_result()?;
        Ok(())
    }
}

struct PgAdminOptions {
    password: String,
    username: String,
    port: u32,
    host: String,
    database: String,
}

pub struct PostgresCompressedBackupStrategy {}

impl PostgresCompressedBackupStrategy {
    pub fn new() -> Self {
        Self {}
    }
}

impl BackupStrategy for PostgresCompressedBackupStrategy {
    fn create_backup(&self, connection_string: &str) -> Result<Backup, StrategyError> {
        todo!();
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

    fn restore_backup(
        &self,
        connection_string: &str,
        drop: bool,
        backup: Backup,
    ) -> Result<(), StrategyError> {
        todo!()
    }
}

impl From<IOError> for StrategyError {
    fn from(value: IOError) -> Self {
        StrategyError(Box::new(value))
    }
}

impl From<ProcessOutputError> for StrategyError {
    fn from(value: ProcessOutputError) -> Self {
        StrategyError(Box::new(value))
    }
}
