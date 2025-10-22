use axum::extract::Query;
use axum::extract::State;
use axum::http::StatusCode;
use axum::routing::get;
use axum::Router;
use rand::random;
use std::collections::HashMap;
use std::io::stdin;
use std::io::IsTerminal;
use std::sync::Arc;
use std::sync::Mutex;
use std::time::Duration;
use std::time::Instant;
use tokio::net::TcpListener;

const CORRECT_TOKEN: &str = "dbaceba3-3e25-44b6-ad6b-c6b39a2ec16a";
const UPDATE_INTERVAL: Duration = Duration::from_secs(5);
const PORT: u32 = 6000;

enum Mode {
    Normal,
    ErrorKO,
    Error500,
}

struct MockDuckDnsServer {
    last_ip_update: Instant,
    ip_update_interval: Duration,
    current_ip: String,
    mode: Mode,
}

impl MockDuckDnsServer {
    fn new() -> Self {
        MockDuckDnsServer {
            last_ip_update: Instant::now(),
            ip_update_interval: UPDATE_INTERVAL,
            current_ip: Self::random_ip(),
            mode: Mode::Normal,
        }
    }

    fn random_ip() -> String {
        let mut random_numbers: [u8; 4] = [0; 4];
        for i in 0..4 {
            random_numbers[i] = random();
        }
        random_numbers
            .into_iter()
            .map(|e| e.to_string())
            .collect::<Vec<String>>()
            .join(".")
    }

    fn change_ip_if_needed(&mut self) -> bool {
        if self.last_ip_update + self.ip_update_interval > Instant::now() {
            false
        } else {
            self.last_ip_update = Instant::now();
            self.current_ip = Self::random_ip();
            true
        }
    }
}

fn handle_normal(
    server_data: &mut MockDuckDnsServer,
    params: &HashMap<String, String>,
) -> (StatusCode, String) {
    if params.get("token") != Some(&CORRECT_TOKEN.to_string())
        && params.get("domain") != Some(&"phdwebsite".to_string())
    {
        return (StatusCode::OK, "KO".to_string());
    }
    let update = if server_data.change_ip_if_needed() {
        "UPDATED"
    } else {
        "NOCHANGE"
    };
    match params.get("verbose") {
        None => (StatusCode::OK, "OK".to_string()),
        Some(query) => match query.as_str() {
            "false" => (StatusCode::OK, "OK".to_string()),
            "true" => {
                let ip = &server_data.current_ip;
                (StatusCode::OK, format!("OK\n{ip}\n\n{update}"))
            }
            _ => (StatusCode::BAD_REQUEST, "".to_string()),
        }
    }
}

fn handle_error_ko() -> (StatusCode, String) {
    (StatusCode::OK, "KO".to_string())
}

fn handle_error_500() -> (StatusCode, String) {
    (StatusCode::INTERNAL_SERVER_ERROR, "".to_string())
}

async fn mocked_handler(
    State(server_data): State<Arc<Mutex<MockDuckDnsServer>>>,
    Query(params): Query<HashMap<String, String>>,
) -> (StatusCode, String) {
    println!("Handling request");
    let mut server_data = server_data.lock().unwrap();
    match server_data.mode {
        Mode::Normal => handle_normal(&mut server_data, &params),
        Mode::ErrorKO => handle_error_ko(),
        Mode::Error500 => handle_error_500(),
    }
}

#[tokio::main]
async fn main() {
    let server_data = Arc::new(Mutex::new(MockDuckDnsServer::new()));
    let router = Router::new()
        .route("/update", get(mocked_handler))
        .with_state(server_data.clone());

    std::thread::spawn(move || {
        if !stdin().is_terminal() {
            return;
        }
        loop {
            println!(
                "Chose a mode: \n\
            1. Normal Responses\n\
            2. KO Errors \n\
            3. 500 Errors"
            );

            let mut buffer = String::new();
            match stdin().read_line(&mut buffer) {
                Ok(_) => match buffer.trim().parse::<u8>() {
                    Ok(index) => match index {
                        1 => {
                            println!("Set Normal mode");
                            server_data.lock().unwrap().mode = Mode::Normal;
                        }
                        2 => {
                            println!("Set ErrorKO mode");
                            server_data.lock().unwrap().mode = Mode::ErrorKO;
                        }
                        3 => {
                            println!("Set Error500 mode");
                            server_data.lock().unwrap().mode = Mode::Error500;
                        }
                        _ => {}
                    },
                    Err(e) => {
                        println!("{}", e);
                    }
                },
                Err(e) => {
                    println!("{}", e);
                }
            }
            buffer.clear();
        }
    });

    let tcp_listener = TcpListener::bind(format!("0.0.0.0:{}", PORT))
        .await
        .unwrap();
    axum::serve(tcp_listener, router).await.unwrap();
}
