use regex::Regex;

pub fn read_env_file() {
    if let Ok(file_content) = std::fs::read_to_string(".env") {
        for line in file_content.lines() {
            match line.split_once('=') {
                Some((key, value)) => {
                    if !is_valid_env_variable_name(key) {
                        panic!("Incorrect env variable name: {key}")
                    }
                    std::env::set_var(key, value);
                }
                None => panic!("Incorrect line format encountered in .env file: {line}"),
            }
        }
    }
}

fn is_valid_env_variable_name(env_variable_name: &str) -> bool {
    let correct_env_variable_name = Regex::new("[a-zA-Z_]+[a-zA-Z0-9_]*").unwrap();
    correct_env_variable_name.is_match(env_variable_name)
}
