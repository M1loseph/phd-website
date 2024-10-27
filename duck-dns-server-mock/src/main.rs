use iron::prelude::*;
use iron::status;
use iron::Handler;
use iron::Iron;
use params::Params;
use params::Value;
use rand::random;
use router::Router;
use std::io::stdin;
use std::io::IsTerminal;
use std::sync::Arc;
use std::sync::Mutex;
use std::sync::MutexGuard;
use std::time::Duration;
use std::time::Instant;

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

struct DDNSHandler {
    server_data: Arc<Mutex<MockDuckDnsServer>>,
}

impl DDNSHandler {
    fn new(server_data: Arc<Mutex<MockDuckDnsServer>>) -> Self {
        DDNSHandler { server_data }
    }
}
impl DDNSHandler {
    fn handle_normal(
        &self,
        req: &mut Request,
        mut server_data: MutexGuard<MockDuckDnsServer>,
    ) -> IronResult<Response> {
        match req.get_ref::<Params>() {
            Ok(params) => {
                if params.get("token") != Some(&Value::String(CORRECT_TOKEN.to_string()))
                    && params.get("domain") != Some(&Value::String("phdwebsite".to_string()))
                {
                    let response = Response::with((status::Ok, "KO"));
                    Ok(response)
                } else {
                    let update = if server_data.change_ip_if_needed() {
                        "UPDATED"
                    } else {
                        "NOCHANGE"
                    };
                    match params.get("verbose") {
                        None => Ok(Response::with((status::Ok, "OK"))),
                        Some(&Value::String(ref query)) => match query.as_str() {
                            "false" => Ok(Response::with((status::Ok, "OK"))),
                            "true" => {
                                let ip = &server_data.current_ip;
                                Ok(Response::with((
                                    status::Ok,
                                    format!("OK\n{ip}\n\n{update}"),
                                )))
                            }
                            _ => Ok(Response::with(status::BadRequest)),
                        },
                        _ => Ok(Response::with(status::BadRequest)),
                    }
                }
            }
            Err(e) => Err(IronError::new(e, status::InternalServerError)),
        }
    }

    fn handle_error_ko(&self) -> IronResult<Response> {
        Ok(Response::with(("KO", status::Ok)))
    }

    fn handle_error_500(&self) -> IronResult<Response> {
        Ok(Response::with(status::InternalServerError))
    }
}

impl Handler for DDNSHandler {
    fn handle(&self, req: &mut Request) -> IronResult<Response> {
        println!("Handling request coming from {}", req.remote_addr);
        let server_data = self.server_data.lock().unwrap();
        match server_data.mode {
            Mode::Normal => self.handle_normal(req, server_data),
            Mode::ErrorKO => self.handle_error_ko(),
            Mode::Error500 => self.handle_error_500(),
        }
    }
}

fn main() {
    let mut router = Router::new();
    let server_data = Arc::new(Mutex::new(MockDuckDnsServer::new()));
    router.get(
        "/update",
        DDNSHandler::new(server_data.clone()),
        "update-ip",
    );

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

    Iron::new(router).http(format!("0.0.0.0:{}", PORT)).unwrap();
}
