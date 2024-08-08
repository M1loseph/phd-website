use std::error::Error;
use std::fmt::Display;

#[derive(Debug, PartialEq)]
pub enum DuckDnsMessageParsingError {
    EmptyResponse,
    KoResponse,
    UnknownResponse,
    IncorrectIpV4,
    IncorrectIpV6,
    MissingServerAction,
    UnknownServerAction,
    TooManyLines,
}

impl Error for DuckDnsMessageParsingError {}

impl Display for DuckDnsMessageParsingError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "Unable to parse response from DuckDns")
    }
}

#[derive(Debug)]
pub struct UpdateIpError {
    inner: Box<dyn std::error::Error>,
}

impl Display for UpdateIpError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "Error updating IP address, cause: {}", self.inner)
    }
}

impl From<reqwest::Error> for UpdateIpError {
    fn from(value: reqwest::Error) -> Self {
        UpdateIpError {
            inner: Box::new(value),
        }
    }
}

impl From<DuckDnsMessageParsingError> for UpdateIpError {
    fn from(value: DuckDnsMessageParsingError) -> Self {
        UpdateIpError {
            inner: Box::new(value),
        }
    }
}
