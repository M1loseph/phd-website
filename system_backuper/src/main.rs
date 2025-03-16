mod app_config;
mod endpoints;
mod errorstack;
mod file_system_repositories;
mod jobs;
mod lock;
mod model;
mod process;
mod services;

use app_config::AppConfig;
use dotenv;
use endpoints::{
    ConfiguredTargetsReadAllEndpoint, CreateBackupEndpoint, MongoDBReadAllBackups,
    MongoRestoreBackupEndpoint,
};
use file_system_repositories::{FileSystemBackupRepository, SQLiteBackupMetadataRepository};
use iron::Iron;
use jobs::{CronJobs, ScheduledBackupJob};
use lock::LockManager;
use router::Router;
use services::{
    BackuppingService, MongoDBCompressedBackupStrategy, PostgresCompressedBackupStrategy,
};
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

    let mongodb_strategy = Arc::new(
        MongoDBCompressedBackupStrategy::new(app_config.mongodump_config_file_path).unwrap(),
    );
    let postgres_strategy = Arc::new(PostgresCompressedBackupStrategy::new());

    let backupping_service = Arc::new(BackuppingService::new(
        lock_manager.clone(),
        backup_repository.clone(),
        backup_metadata_repoository.clone(),
        mongodb_strategy,
        postgres_strategy,
        app_config.backup_targets,
    ));

    let read_targets_endpoint = ConfiguredTargetsReadAllEndpoint::new(backupping_service.clone());
    let create_backup_endpoint = CreateBackupEndpoint::new(backupping_service.clone());
    let read_backups_endpoint = MongoDBReadAllBackups::new(backupping_service.clone());
    let restore_backup_endpoint = MongoRestoreBackupEndpoint::new(backupping_service.clone());

    let mut cron_jobs = CronJobs::new();
    for job in app_config.cyclic_backups {
        let task = ScheduledBackupJob::new(job.target_name, backupping_service.clone());
        cron_jobs.start(&job.cron_schedule, task)?;
    }

    let mut router = Router::new();
    router.get("/api/v1/targets", read_targets_endpoint, "readAllTargets");
    router.post(
        "/api/v1/backups/:target_name",
        create_backup_endpoint,
        "createBackupFromTarget",
    );
    router.get("/api/v1/backups", read_backups_endpoint, "readAllBackups");
    router.post(
        "/api/v1/backups/:target_name/:backup_id",
        restore_backup_endpoint,
        "restoreBackupToTarget",
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
