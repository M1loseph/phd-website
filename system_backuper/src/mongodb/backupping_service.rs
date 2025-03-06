use crate::backup_metadata::{
    BackupId, BackupMetadata, BackupMetadataRepository, BackupRepository, BackupTarget, BackupType,
    RandomId,
};
use crate::lock::LockManager;
use chrono::Local;
use log::info;
use std::fs;
use std::fs::File;
use std::io::{self, Write};
use std::path::Path;
use std::process::{Command, Stdio};
use std::sync::Arc;
use url::Url;

static MONGO_CONFIG_FILE_NAME: &str = "mongo.yml";

pub struct MongoDBBackuppingService {
    mongodump_config_file_path: String,
    mongo_uri: Url,
    lock_manager: Arc<LockManager>,
    backup_repository: Arc<dyn BackupRepository + Sync>,
    backup_metadata_repository: Arc<dyn BackupMetadataRepository + Sync>,
}

impl MongoDBBackuppingService {
    pub fn new(
        mongodump_config_file_path: String,
        mongo_uri: String,
        lock_manager: Arc<LockManager>,
        backup_repository: Arc<dyn BackupRepository>,
        backup_metadata_repository: Arc<dyn BackupMetadataRepository>,
    ) -> AnyResult<Self> {
        let mongodump_config_file_path =
            Path::new(&mongodump_config_file_path).join(MONGO_CONFIG_FILE_NAME);
        Self::create_config_file(mongodump_config_file_path.as_path(), &mongo_uri)?;
        let mongo_uri = Url::parse(&mongo_uri)?;

        Ok(Self {
            mongodump_config_file_path: mongodump_config_file_path.to_str().unwrap().to_string(),
            mongo_uri,
            lock_manager,
            backup_repository,
            backup_metadata_repository,
        })
    }

    fn create_config_file(mongodump_config_file_path: &Path, uri: &String) -> AnyResult<()> {
        let config_path = Path::new(&mongodump_config_file_path);
        let path_only = config_path.parent().ok_or(io::Error::other(
            "Failed to create directory for configuration file for mongodump",
        ))?;
        fs::create_dir_all(path_only)?;
        let mut file = File::create_new(mongodump_config_file_path)?;
        let file_content = format!("uri: {uri}");
        file.write_all(file_content.as_bytes())?;
        Ok(())
    }

    pub fn create_mongodb_backup(&self) -> AnyResult<BackupMetadata> {
        info!("Starting backing up mongo at {}", Local::now());

        let _lock = self.lock_manager.lock(BackupTarget::MONGODB);

        let output = Command::new("mongodump")
            .args([
                "--config",
                &self.mongodump_config_file_path,
                "--gzip",
                "--archive",
            ])
            .output()?;
        let exit_code = output.status;

        if !exit_code.success() {
            panic!("Failed to execute mongodump");
        }

        let blob = output.stdout;
        let blob_size = blob.len() as u64;

        let backup_metadata = BackupMetadata {
            backup_id: BackupId::random(),
            host: self.mongo_uri.host().unwrap().to_string(),
            created_at: Local::now().fixed_offset(),
            backup_size_bytes: blob_size,
            backup_target: BackupTarget::MONGODB,
            backup_type: BackupType::MANUAL,
        };

        // TODO: remove unwrap
        self.backup_metadata_repository.save(&backup_metadata)?;
        self.backup_repository.save(&backup_metadata, blob).unwrap();

        Ok(backup_metadata)
    }

    pub fn read_all_mongodb_backups(&self) -> AnyResult<Vec<BackupMetadata>> {
        // TODO: remove unwrap
        Ok(self.backup_metadata_repository.find_all().unwrap())
    }

    pub fn restore_backup(&self, backup_id: u64) -> AnyResult<()> {
        // TODO: remove unwrap
        let backup_metada = self
            .backup_metadata_repository
            .find_by_id(backup_id)
            .unwrap()
            .unwrap();

        let backup = self
            .backup_repository
            .find_by_metadata(&backup_metada)
            .unwrap()
            .unwrap();

        let mut child = Command::new("mongodump")
            .args([
                "--config",
                &self.mongodump_config_file_path,
                "--gzip",
                "--archive",
            ])
            .stdin(Stdio::piped())
            .stdout(Stdio::piped())
            .spawn()?;
        // TODO: add normal error
        child.stdin.as_mut().ok_or("No stdin")?.write_all(&backup)?;

        // TODO: don't ignore
        let _exit_code = child.wait()?;
        Ok(())
    }
}
