use std::path::Path;
use std::process::Stdio;
use std::{fs, process::Command};

use crate::model::{Backup, BackupFormat};
use crate::process::IntoResult;
use anyhow::{anyhow, Result};
use flate2::write::{GzEncoder, GzDecoder};
use flate2::Compression;
use std::io::Write;
use url::Url;

pub trait BackupStrategy: Send + Sync {
    fn create_backup(&self, connection_string: &str) -> Result<(Backup, BackupFormat)>;

    fn restore_backup(&self, connection_string: &str, drop: bool, backup: Backup) -> Result<()>;
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
    pub fn new(mongodump_config_file_folder: String) -> Result<Self> {
        fs::create_dir_all(&mongodump_config_file_folder)?;
        Ok(MongoDBCompressedBackupStrategy {
            mongodump_config_file_folder,
        })
    }

    fn create_config_file(&self, connection_string: &str) -> Result<ConfigFileRAII> {
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
    fn create_backup(&self, connection_string: &str) -> Result<(Backup, BackupFormat)> {
        let config_file = self.create_config_file(connection_string)?;
        let output = Command::new("mongodump")
            .args(["--config", &config_file.path, "--gzip", "--archive"])
            .stderr(Stdio::piped())
            .output()?
            .into_result()?;
        let blob = output.stdout;
        Ok((blob, BackupFormat::ArchiveGz))
    }

    fn restore_backup(&self, connection_string: &str, drop: bool, backup: Backup) -> Result<()> {
        let config_file = self.create_config_file(connection_string)?;
        let mut args = vec!["--config", &config_file.path, "--gzip", "--archive"];
        if drop {
            args.push("--drop");
        }

        let mut child = Command::new("mongorestore")
            .args(args)
            .stdin(Stdio::piped())
            .stderr(Stdio::piped())
            .spawn()?;

        child.stdin.take().unwrap().write_all(&backup)?;

        let _ = child.wait_with_output()?.into_result()?;
        Ok(())
    }
}

struct PostgresOptions {
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

    fn parse_connection_string(&self, connection_string: &str) -> Result<PostgresOptions> {
        let url = Url::parse(connection_string)?;
        let password = url.password().ok_or(anyhow!(
            "Missing password in the postgres connection string"
        ))?;
        let username = url.username();
        let port = url
            .port()
            .ok_or(anyhow!("Missing port in the postgres connection string"))?;
        let host = url
            .host_str()
            .ok_or(anyhow!("Missing host in the postgres connection string"))?;
        let database = url.path().strip_prefix("/").ok_or(anyhow!(
            "Missing database name in the postgres connection string"
        ))?;

        Ok(PostgresOptions {
            password: password.to_string(),
            username: username.to_string(),
            port: port.into(),
            host: host.to_string(),
            database: database.to_string(),
        })
    }
}

impl BackupStrategy for PostgresCompressedBackupStrategy {
    fn create_backup(&self, connection_string: &str) -> Result<(Backup, BackupFormat)> {
        let pg_dump_options = self.parse_connection_string(connection_string)?;

        let process_output = Command::new("pg_dump")
            .args([
                "--username",
                &pg_dump_options.username,
                "--port",
                &pg_dump_options.port.to_string(),
                "--host",
                &pg_dump_options.host,
                "--format",
                "tar",
                &pg_dump_options.database,
            ])
            .env("PGPASSWORD", &pg_dump_options.password)
            .stderr(Stdio::piped())
            .output()?
            .into_result()?;

        let database_dump = process_output.stdout;
        let mut encoder = GzEncoder::new(Vec::new(), Compression::best());
        encoder.write_all(database_dump.as_slice())?;
        let compressed_dump = encoder.finish()?;
        Ok((compressed_dump, BackupFormat::TarGz))
    }

    fn restore_backup(&self, connection_string: &str, drop: bool, backup: Backup) -> Result<()> {
        let pg_restore_options = self.parse_connection_string(connection_string)?;
        let port = pg_restore_options.port.to_string();

        let mut args = vec![
            "--username",
            &pg_restore_options.username,
            "--port",
            &port,
            "--host",
            &pg_restore_options.host,
            "--dbname",
            &pg_restore_options.database,
            "--single-transaction"
        ];
        if drop {
            args.extend_from_slice(&["--clean", "--if-exists"]);
        }

        let mut decoder = GzDecoder::new(Vec::new());
        decoder.write_all(&backup)?;
        let decompressed_backup = decoder.finish()?;

        let mut process = Command::new("pg_restore")
            .args(args)
            .env("PGPASSWORD", &pg_restore_options.password)
            .stdin(Stdio::piped())
            .stderr(Stdio::piped())
            .spawn()?;
        process.stdin.take().unwrap().write_all(&decompressed_backup)?;
        let _ = process.wait_with_output()?.into_result()?;
        Ok(())
    }
}
