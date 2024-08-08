use std::sync::Mutex;
use std::time::Duration;
use std::time::Instant;

use iron::prelude::*;
use iron::status;
use iron::Handler;
use iron::Iron;
use params::Params;
use params::Value;
use rand::random;
use rand::Rng;
use router::Router;

const CORRECT_TOKEN: &str = "dbaceba3-3e25-44b6-ad6b-c6b39a2ec16a";
const UPDATE_INTERVAL: Duration = Duration::from_secs(5);
const ERROR_CHANCE: f32 = 0.3;
const PORT: u32 = 6000;

struct MockDuckDnsServer {
    last_ip_update: Instant,
    ip_update_interval: Duration,
    current_ip: String,
}

impl MockDuckDnsServer {
    fn new() -> Self {
        MockDuckDnsServer {
            last_ip_update: Instant::now(),
            ip_update_interval: UPDATE_INTERVAL,
            current_ip: Self::random_ip(),
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
    server_data: Mutex<MockDuckDnsServer>,
}

impl DDNSHandler {
    fn new() -> Self {
        DDNSHandler {
            server_data: Mutex::new(MockDuckDnsServer::new()),
        }
    }
}

impl Handler for DDNSHandler {
    fn handle(&self, req: &mut Request) -> IronResult<Response> {
        println!("Handling request coming from {}", req.remote_addr);
        match req.get_ref::<Params>() {
            Ok(params) => {
                if rand::thread_rng().gen_range(0f32..1f32) < ERROR_CHANCE {
                    Ok(Response::with((status::Ok, "KO")))
                } else if params.get("token") != Some(&Value::String(CORRECT_TOKEN.to_string()))
                    && params.get("domain") != Some(&Value::String("phdwebsite".to_string()))
                {
                    let response = Response::with((status::Ok, "KO"));
                    Ok(response)
                } else {
                    let mut server_data = self.server_data.lock().unwrap();
                    let update = if server_data.change_ip_if_needed() {
                        "UPDATED"
                    } else {
                        "NOCHANGE"
                    };
                    if params.get("verbose") == Some(&Value::Boolean(false)) {
                        Ok(Response::with((status::Ok, "OK")))
                    } else {
                        let ip = &server_data.current_ip;
                        Ok(Response::with((
                            status::Ok,
                            format!("OK\n{ip}\n\n{update}"),
                        )))
                    }
                }
            }
            Err(e) => Err(IronError::new(e, status::InternalServerError)),
        }
    }
}

fn main() {
    let mut router = Router::new();
    router.get("/update", DDNSHandler::new(), "update-ip");

    Iron::new(router)
        .http(format!("127.0.0.1:{}", PORT))
        .unwrap();
}
