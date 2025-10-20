FROM rust:1.90.0-slim-bookworm AS build

RUN apt update && apt install -y pkg-config libssl-dev

WORKDIR /build/ddns-runner

COPY ddns-runner .
COPY lib/dotenv /build/lib/dotenv
COPY lib/migrations /build/lib/migrations

RUN cargo build --release

FROM debian:bookworm-20250929

ARG ADDITIONAL_PACKAGES

RUN apt update && apt install -y libssl-dev ${ADDITIONAL_PACKAGES} && apt clean
# Create a non-privileged user that the app will run under.
# See https://docs.docker.com/go/dockerfile-user-best-practices/
RUN groupadd -r appuser && useradd --no-log-init -r -g appuser appuser
USER appuser

COPY --from=build /build/ddns-runner/target/release/ddns-runner /ddns-runner/ddns-runner
COPY --chown=appuser:appuser ./ddns-runner/migrations /ddns-runner/migrations/
EXPOSE 3000
ENTRYPOINT ["/ddns-runner/ddns-runner"]
