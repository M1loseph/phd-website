use std::{cmp::Ordering, fmt::Display};

use super::errors::MigrationError;

#[derive(Eq, Debug, PartialEq, Clone, Copy)]
pub struct SemanticVersion {
    major: u32,
    minor: u32,
    patch: u32,
}

impl Display for SemanticVersion {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}.{}.{}", self.major, self.minor, self.patch)
    }
}

impl From<&SemanticVersion> for String {
    fn from(value: &SemanticVersion) -> Self {
        format!("{}.{}.{}", value.major, value.minor, value.patch)
    }
}

impl TryFrom<&str> for SemanticVersion {
    type Error = MigrationError;

    fn try_from(value: &str) -> std::result::Result<Self, Self::Error> {
        let parts = value.splitn(3, '.').collect::<Vec<&str>>();
        if parts.len() != 3 {
            return Err(MigrationError::IncorrectSemanticVersion {
                sem_ver: value.to_string(),
            });
        }

        let major = parts[0]
            .parse()
            .map_err(|_| MigrationError::IncorrectSemanticVersion {
                sem_ver: value.to_string(),
            })?;
        let minor = parts[1]
            .parse()
            .map_err(|_| MigrationError::IncorrectSemanticVersion {
                sem_ver: value.to_string(),
            })?;
        let patch = parts[2]
            .parse()
            .map_err(|_| MigrationError::IncorrectSemanticVersion {
                sem_ver: value.to_string(),
            })?;
        return Ok(SemanticVersion {
            major,
            minor,
            patch,
        });
    }
}

impl PartialOrd for SemanticVersion {
    fn partial_cmp(&self, other: &Self) -> Option<Ordering> {
        Some(self.cmp(other))
    }
}

impl Ord for SemanticVersion {
    fn cmp(&self, other: &Self) -> Ordering {
        if self.major < other.major {
            Ordering::Less
        } else if self.major > other.major {
            Ordering::Greater
        } else if self.minor < other.minor {
            Ordering::Less
        } else if self.minor > other.minor {
            Ordering::Greater
        } else if self.patch < other.patch {
            Ordering::Less
        } else if self.patch > other.patch {
            Ordering::Greater
        } else {
            Ordering::Equal
        }
    }
}

#[cfg(test)]
mod tests {
    use std::cmp::Ordering;

    use super::MigrationError;
    use super::SemanticVersion;

    impl SemanticVersion {
        fn new(major: u32, minor: u32, patch: u32) -> Self {
            SemanticVersion {
                major,
                minor,
                patch,
            }
        }
    }

    #[test]
    fn should_correctly_order_semantic_versions_major() {
        assert_eq!(
            SemanticVersion::new(0, 0, 0).cmp(&SemanticVersion::new(1, 0, 0)),
            Ordering::Less
        );
        assert_eq!(
            SemanticVersion::new(0, 1, 1).cmp(&SemanticVersion::new(1, 0, 0)),
            Ordering::Less
        );
    }

    #[test]
    fn should_correctly_order_semantic_versions_minor() {
        assert_eq!(
            SemanticVersion::new(0, 0, 0).cmp(&SemanticVersion::new(0, 1, 0)),
            Ordering::Less
        );
        assert_eq!(
            SemanticVersion::new(0, 0, 1).cmp(&SemanticVersion::new(0, 1, 0)),
            Ordering::Less
        );
    }

    #[test]
    fn should_correctly_order_semantic_versions_patch() {
        assert_eq!(
            SemanticVersion::new(0, 0, 0).cmp(&SemanticVersion::new(0, 0, 1)),
            Ordering::Less
        );
    }

    #[test]
    fn should_turn_semantic_version_to_correct_string() {
        let semantic_version = SemanticVersion::new(20, 0, 10);
        assert_eq!(String::from(&semantic_version), String::from("20.0.10"));
    }

    #[test]
    fn should_parse_semantic_version() {
        let semantic_version = SemanticVersion::try_from("20.0.10").unwrap();
        assert_eq!(semantic_version, SemanticVersion::new(20, 0, 10));
    }

    #[test]
    fn should_fail_parsing_semantic_version() {
        let error = SemanticVersion::try_from("20.0.-10").unwrap_err();
        assert_eq!(
            error,
            MigrationError::IncorrectSemanticVersion {
                sem_ver: "20.0.-10".to_string()
            }
        );
    }
}
