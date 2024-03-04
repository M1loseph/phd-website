use std::env;
use std::result::Result;
use std::time::Duration;

const DEFAULT_PORT: u16 = 3000;
const DEFAULT_INTERVAL: Duration = Duration::from_secs(60 * 5);

pub struct ApplicationConfig {
    pub domain: String,
    pub token: String,
    pub server_port: u16,
    pub ip_update_interval: Duration,
}

fn to_env_variable_name(name: &str) -> String {
    static ENV_VAR_PREFIX: &str = "DDNS_RUNNER";
    format!("{}_{}", ENV_VAR_PREFIX, name)
}

fn read_env_variable(name: &str) -> Result<String, Box<dyn std::error::Error>> {
    let env_variable_name = to_env_variable_name(name);
    env::var(&env_variable_name)
        .map_err(|_| format!("{} environment variable is not set", env_variable_name).into())
}

pub fn read_config_with_default() -> Result<ApplicationConfig, Box<dyn std::error::Error>> {
    let domain = read_env_variable("DOMAIN")?;
    let token = read_env_variable("TOKEN")?;
    let server_port = read_env_variable("SERVER_PORT")
        .ok()
        .map(|port| port.parse::<u16>().ok())
        .flatten()
        .unwrap_or(DEFAULT_PORT);
    let ip_update_interval = read_env_variable("IP_UPDATE_INTERVAL_SEC")
        .ok()
        .map(|interval| interval.parse::<u64>().ok())
        .flatten()
        .map(Duration::from_secs)
        .unwrap_or(DEFAULT_INTERVAL);
    Ok(ApplicationConfig {
        domain,
        token,
        server_port,
        ip_update_interval,
    })
}
