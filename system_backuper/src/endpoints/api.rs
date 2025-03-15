use crate::backup_metadata::{self, BackupMetadata};
use chrono::{DateTime, FixedOffset};
use iron::{
    headers::ContentType,
    mime::{Mime, SubLevel, TopLevel},
    modifiers::Header,
    status::Status,
    Response,
};
use serde::Serialize;

#[derive(Serialize)]
pub struct ArchiveBackupResponse {
    pub backup_id: u64,
    pub host: String,
    pub created_at: DateTime<FixedOffset>,
    pub backup_size_bytes: u64,
    pub backup_target: BackupTarget,
    pub backup_type: BackupType,
    pub backup_format: BackupFormat,
}

impl From<BackupMetadata> for ArchiveBackupResponse {
    fn from(value: BackupMetadata) -> Self {
        Self {
            backup_id: value.backup_id,
            host: value.host,
            created_at: value.created_at,
            backup_size_bytes: value.backup_size_bytes,
            backup_target: value.backup_target.into(),
            backup_type: value.backup_type.into(),
            backup_format: value.backup_format.into(),
        }
    }
}

#[derive(Serialize)]
pub enum BackupType {
    #[serde(rename = "MANUAL")]
    Manual,
    #[serde(rename = "SCHEDULED")]
    Scheduled,
}

impl From<backup_metadata::BackupType> for BackupType {
    fn from(value: backup_metadata::BackupType) -> Self {
        match value {
            backup_metadata::BackupType::Manual => BackupType::Manual,
            backup_metadata::BackupType::Scheduled => BackupType::Scheduled,
        }
    }
}

#[derive(Serialize)]
pub enum BackupTarget {
    #[serde(rename = "MONGODB")]
    MongoDB,
    #[serde(rename = "POSTGRES")]
    Postgres,
}

impl From<backup_metadata::BackupTarget> for BackupTarget {
    fn from(value: backup_metadata::BackupTarget) -> Self {
        match value {
            backup_metadata::BackupTarget::MongoDB => BackupTarget::MongoDB,
            backup_metadata::BackupTarget::Postgres => BackupTarget::Postgres,
        }
    }
}

#[derive(Serialize, Debug)]
pub enum ErrorCode {
    #[serde(rename = "BACKUP_TARGET_LOCKED")]
    BackupTargetLocked,
    #[serde(rename = "INTERNAL_ERROR")]
    InternalError,
    #[serde(rename = "BACKUP_NOT_FOUND")]
    BackupNotFound,
}

#[derive(Serialize, Debug)]
pub struct ApiError {
    pub error_code: ErrorCode,
    pub message: String,
}

pub fn json_response<T>(status: Status, response_body: T) -> Response
where
    T: Sized + Serialize,
{
    let response_body = serde_json::to_string(&response_body).unwrap();

    let header = Header(ContentType(Mime(
        TopLevel::Application,
        SubLevel::Json,
        vec![],
    )));

    Response::with((status, response_body, header))
}

#[derive(Serialize, Debug)]
pub enum BackupFormat {
    #[serde(rename = "TAR_GZ")]
    TarGz,
    #[serde(rename = "ARCHIVE_GZ")]
    ArchiveGz,
}

impl From<backup_metadata::BackupFormat> for BackupFormat {
    fn from(value: backup_metadata::BackupFormat) -> Self {
        match value {
            backup_metadata::BackupFormat::ArchiveGz => Self::ArchiveGz,
            backup_metadata::BackupFormat::TarGz => Self::TarGz,
        }
    }
}
