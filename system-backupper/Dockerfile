FROM rust:1.90.0-slim-bookworm AS build

# RUN apt update && apt install -y pkg-config libssl-dev

WORKDIR /build/system-backupper

COPY system-backupper .
COPY lib/dotenv /build/lib/dotenv
COPY lib/migrations /build/lib/migrations

RUN cargo build --release

FROM debian:bookworm-20250929

# Create a non-privileged user that the app will run under.
# See https://docs.docker.com/go/dockerfile-user-best-practices/
RUN groupadd -r appuser && useradd --no-log-init -r -g appuser -u 10001 --home /nonexistent --shell /sbin/nologin appuser
USER appuser

COPY --from=build /build/system-backupper/target/release/system-backupper /system-backupper/system-backupper
COPY --chown=appuser:appuser /system-backupper/migrations /system-backupper/migrations/
EXPOSE 2000
ENTRYPOINT ["/system-backupper/system-backupper"]