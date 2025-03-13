mod app_config;
mod backup_metadata;
mod endpoints;
mod errorstack;
mod file_system_repositories;
mod jobs;
mod lock;
mod mongodb;
mod postgres;
mod process;

use app_config::AppConfig;
use dotenv;
use endpoints::{MongoDBCreateBackupEndpoint, MongoDBReadAllBackups, MongoRestoreBackupEndpoint};
use file_system_repositories::{FileSystemBackupRepository, SQLiteBackupMetadataRepository};
use iron::Iron;
use jobs::{CronJobs, MongoDBScheduledBackupJob};
use lock::LockManager;
use mongodb::MongoDBBackuppingService;
use router::Router;
use std::sync::{atomic::AtomicBool, Arc};

fn main() -> Result<(), Box<dyn std::error::Error>> {
    dotenv::read_env_file();
    env_logger::init();

    let app_config = AppConfig::create_from_environment();

    let lock_manager = Arc::new(LockManager::new(app_config.locks_directory).unwrap());
    let backup_repository = Arc::new(FileSystemBackupRepository::new(app_config.target_directory));
    let backup_metadata_repoository = Arc::new(
        SQLiteBackupMetadataRepository::new(app_config.db_path, app_config.db_connection_pool_size)
            .unwrap(),
    );

    let mongodb_backupping_service = Arc::new(
        MongoDBBackuppingService::new(
            app_config.mongodump_config_file_path,
            app_config.mongodb_uri,
            lock_manager.clone(),
            backup_repository.clone(),
            backup_metadata_repoository.clone(),
        )
        .unwrap(),
    );
    let mongodb_full_backup_endpoint =
        MongoDBCreateBackupEndpoint::new(mongodb_backupping_service.clone());
    let mongodb_read_backups_endpoint =
        MongoDBReadAllBackups::new(mongodb_backupping_service.clone());
    let mongodb_restore_backup_endpoint =
        MongoRestoreBackupEndpoint::new(mongodb_backupping_service.clone());

    let mongodb_scheduled_backup_job =
        MongoDBScheduledBackupJob::new(mongodb_backupping_service.clone());

    let mut cron_jobs = CronJobs::new();
    cron_jobs.start(
        &app_config.cyclic_backup_mongodb_cron,
        mongodb_scheduled_backup_job,
    )?;

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

    signal_hook::flag::register_conditional_shutdown(
        signal_hook::consts::SIGTERM,
        0,
        Arc::new(AtomicBool::new(true)),
    )
    .unwrap();

    Iron::new(router)
        .http(format!("0.0.0.0:{}", app_config.server_port))
        .unwrap();
    Ok(())
}
