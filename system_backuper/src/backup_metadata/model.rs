use chrono::{DateTime, FixedOffset};
use strum::{Display, EnumString, IntoStaticStr};
use rand;

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

#[derive(Display, Debug, EnumString, IntoStaticStr)]
pub enum BackupTarget {
    MongoDB,
    Postgres,
}

#[derive(Debug, Clone, EnumString, IntoStaticStr)]
pub enum BackupType {
    Manual,
    Scheduled,
}

pub struct BackupMetadata {
    pub backup_id: BackupId,
    pub host: String,
    pub created_at: DateTime<FixedOffset>,
    pub backup_size_bytes: u64,
    pub backup_target: BackupTarget,
    pub backup_type: BackupType,
}
