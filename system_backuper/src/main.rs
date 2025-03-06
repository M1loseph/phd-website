mod backup_metadata;
mod endpoints;
mod file_system_repositories;
mod lock;
mod mongodb;
mod postgres;

use dotenv;
use endpoints::{MongoDBFullBackupEndpoint, MongoDBReadAllBackups, MongoRestoreBackupEndpoint};
use file_system_repositories::{FileSystemBackupRepository, SQLiteBackupMetadataRepository};
use iron::Iron;
use lock::LockManager;
use mongodb::MongoDBBackuppingService;
use router::Router;
use std::sync::Arc;

pub struct AppConfig {
    pub mongodump_config_file_path: String,
    pub locks_directory: String,
    pub target_directory: String,
    pub uri: String,
    pub sqlite_path: String,
    pub sqlite_connection_pool: u32,
}

fn main() {
    dotenv::read_env_file();
    env_logger::init();

    // TODO: read env variables and create configuration file out of it
    let app_config = AppConfig {
        mongodump_config_file_path: "local/working/config".to_string(),
        locks_directory: "local/working/locks".to_string(),
        target_directory: "local/results".to_string(),
        uri: "mongodb://username:password@localhost:27017/testdb?authSource=admin".to_string(),
        sqlite_path: "local/db/db.sqlite3".to_string(),
        sqlite_connection_pool: 3,
    };

    let lock_manager = Arc::new(LockManager::new(app_config.locks_directory).unwrap());
    let backup_repository = Arc::new(FileSystemBackupRepository::new(app_config.target_directory));
    let backup_metadata_repoository = Arc::new(
        SQLiteBackupMetadataRepository::new(
            app_config.sqlite_path,
            app_config.sqlite_connection_pool,
        )
        .unwrap(),
    );

    let backupping_service = Arc::new(
        MongoDBBackuppingService::new(
            app_config.mongodump_config_file_path,
            app_config.uri,
            lock_manager.clone(),
            backup_repository.clone(),
            backup_metadata_repoository.clone(),
        )
        .unwrap(),
    );
    let mongodb_full_backup_endpoint = MongoDBFullBackupEndpoint::new(backupping_service.clone());
    let mongodb_read_backups_endpoint = MongoDBReadAllBackups::new(backupping_service.clone());
    let mongodb_restore_backup_endpoint =
        MongoRestoreBackupEndpoint::new(backupping_service.clone());

    let mut router = Router::new();
    router.post(
        "/api/v1/backups/mongodb",
        mongodb_full_backup_endpoint,
        "fullBackupMongoDB",
    );
    router.get(
        "/api/v1/backups/mongodb",
        mongodb_read_backups_endpoint,
        "readAllMongoDBBackups",
    );
    router.post(
        "/api/v1/backups/mongodb/:backup_id",
        mongodb_restore_backup_endpoint,
        "restoreMongoDBBackup",
    );
    Iron::new(router).http("0.0.0.0:2000").unwrap();
}
