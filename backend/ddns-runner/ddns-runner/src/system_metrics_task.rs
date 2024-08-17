use prometheus::Result;
use prometheus::{Gauge, Opts, Registry};
use std::time::Duration;
use sysinfo::{get_current_pid, System};
use tokio::time::sleep;

pub struct PrometheusSystemInfoMetricsTask {
    memory_used: Gauge,
    cpu_used: Gauge,
}

impl PrometheusSystemInfoMetricsTask {
    pub fn new(registry: &Registry) -> Result<Self> {
        let memory_used = Gauge::with_opts(
            Opts::new(
                "ddns_runner_memory",
                "Memory associated with the process in bytes",
            )
            .const_label("type", "used"),
        )?;
        let cpu_used = Gauge::new("ddns_runner_cpu", "Memory used by the process in percents")?;

        registry.register(Box::new(memory_used.clone()))?;
        registry.register(Box::new(cpu_used.clone()))?;

        Ok(PrometheusSystemInfoMetricsTask {
            memory_used,
            cpu_used,
        })
    }

    pub async fn update_system_info(&self) {
        loop {
            if let Ok(pid) = get_current_pid() {
                let system_info = System::new_all();
                if let Some(process) = system_info.process(pid) {
                    let memory_in_bytes = process.memory() as f64;
                    let cpu_usage_percent = process.cpu_usage() as f64;
                    self.memory_used.set(memory_in_bytes);
                    self.cpu_used.set(cpu_usage_percent);
                }
            };
            sleep(Duration::from_secs(10)).await;
        }
    }
}
