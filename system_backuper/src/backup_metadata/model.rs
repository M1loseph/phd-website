use chrono::{DateTime, FixedOffset};
use rand;
use strum::Display;

pub type BackupId = u64;

pub type Backup = Vec<u8>;

pub trait RandomId {
    fn random() -> Self;
}

impl RandomId for BackupId {
    fn random() -> Self {
        rand::random()
    }
}

#[derive(Display, Debug)]
pub enum BackupTarget {
    MongoDB,
    Postgres,
}

#[derive(Display, Debug)]
pub enum BackupType {
    Manual,
    Scheduled,
}

#[derive(Display, Debug, PartialEq)]
pub enum BackupFormat {
    ArchiveGz,
    TarGz,
}

pub struct BackupMetadata {
    pub backup_id: BackupId,
    pub host: String,
    pub created_at: DateTime<FixedOffset>,
    pub backup_size_bytes: u64,
    pub backup_target: BackupTarget,
    pub backup_type: BackupType,
    pub backup_format: BackupFormat,
}
