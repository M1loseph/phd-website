pub struct AppConfig {
    pub mongodump_config_file_path: String,
    pub locks_directory: String,
    pub target_directory: String,
    pub mongodb_uri: String,
    pub db_path: String,
    pub db_connection_pool_size: u32,
    pub server_port: u32,
}

impl AppConfig {
    pub fn create_from_environment() -> Self {
        let mongodump_config_file_path = env::read_or_default(
            &Self::to_env_variable_name("MONGO_DUMP_CONFIG_FILE"),
            "local/working/config",
        );
        let locks_directory = env::read_or_default(
            &Self::to_env_variable_name("LOCKS_DIRECTORY"),
            "local/working/locks",
        );
        let target_directory = env::read_or_default(
            &Self::to_env_variable_name("TARGET_DIRECTORY"),
            "local/results",
        );
        let mongodb_uri = env::read(&Self::to_env_variable_name("MONGODB_URI"));
        let db_path = env::read_or_default(
            &Self::to_env_variable_name("DB_PATH"),
            "local/db/db.sqlite3",
        );
        let db_connection_pool_size =
            env::read_int_or_default(&Self::to_env_variable_name("DB_CONNECTION_POOL_SIZE"), 3);
        let server_port =
            env::read_int_or_default(&Self::to_env_variable_name("SERVER_PORT"), 2000);

        Self {
            mongodump_config_file_path,
            locks_directory,
            target_directory,
            mongodb_uri,
            db_path,
            db_connection_pool_size,
            server_port,
        }
    }

    fn to_env_variable_name(key_suffix: &str) -> String {
        format!("SB_{key_suffix}")
    }
}

mod env {
    use std::env::VarError;

    pub fn read(key: &str) -> String {
        read_env_variable(key)
            .unwrap_or_else(|| panic!("Missing required environment variable {key}"))
    }

    pub fn read_or_default(key: &str, default: &str) -> String {
        read_env_variable(key).unwrap_or_else(|| default.to_string())
    }

    pub fn read_int_or_default(key: &str, default: u32) -> u32 {
        read_env_variable(key)
            .map(|value| {
                value.parse().unwrap_or_else(|_| {
                    panic!(
                "Failed to parse content of environment variable {}. Expected unsigned integer.",
                key
            )
                })
            })
            .unwrap_or(default)
    }

    fn read_env_variable(key: &str) -> Option<String> {
        match std::env::var(&key) {
            Ok(value) => Some(value),
            Err(err) => match err {
                VarError::NotPresent => None,
                VarError::NotUnicode(_) => {
                    panic!("Unable to decode value of environment variable {key}")
                }
            },
        }
    }
}
