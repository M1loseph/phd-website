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

#[derive(Display, EnumString, IntoStaticStr)]
pub enum BackupTarget {
    MONGODB,
    POSTGRES,
}

#[derive(EnumString, IntoStaticStr)]
pub enum BackupType {
    MANUAL,
    SCHEDULED,
}

pub struct BackupMetadata {
    pub backup_id: BackupId,
    pub host: String,
    pub created_at: DateTime<FixedOffset>,
    pub backup_size_bytes: u64,
    pub backup_target: BackupTarget,
    pub backup_type: BackupType,
}
