FROM rust:1.90.0-slim-bookworm AS build

WORKDIR /build/system-backupper

COPY system-backupper .
COPY lib/dotenv /build/lib/dotenv
COPY lib/migrations /build/lib/migrations

RUN RUST_MIN_STACK=16777216 cargo build --release

FROM ubuntu:24.04

RUN apt-get update && \
    # Install PostgreSQL pg_dump and pg_restore
    apt-get install -y curl ca-certificates wget && \
    install -d /usr/share/postgresql-common/pgdg && \
    curl -o /usr/share/postgresql-common/pgdg/apt.postgresql.org.asc --fail https://www.postgresql.org/media/keys/ACCC4CF8.asc && \
    . /etc/os-release && \
    sh -c "echo 'deb [signed-by=/usr/share/postgresql-common/pgdg/apt.postgresql.org.asc] https://apt.postgresql.org/pub/repos/apt $VERSION_CODENAME-pgdg main' > /etc/apt/sources.list.d/pgdg.list" && \
    apt-get update && \
    apt-get install -y postgresql-client-18 && \
    # Install MongoDB Database Tools
    case $(uname -m) in "x86_64") OS_ARCH="x86_64" ;; "aarch64") OS_ARCH="arm64" ;; *) OS_ARCH="unsupported" ;; esac && \
    if [ "$OS_ARCH" = "unsupported" ]; then echo "Unsupported architecture $(uname -m)."; exit 1; fi && \
    wget https://fastdl.mongodb.org/tools/db/mongodb-database-tools-ubuntu2404-${OS_ARCH}-100.13.0.deb && \
    apt-get install -y ./mongodb-database-tools-ubuntu2404-${OS_ARCH}-100.13.0.deb && \
    rm mongodb-database-tools-ubuntu2404-${OS_ARCH}-100.13.0.deb && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Create a non-privileged user that the app will run under.
# See https://docs.docker.com/go/dockerfile-user-best-practices/
RUN groupadd -r appuser && useradd --no-log-init -r -g appuser -u 10001 --home /nonexistent --shell /sbin/nologin appuser

COPY --from=build /build/system-backupper/target/release/system-backupper /system-backupper/system-backupper
COPY system-backupper/migrations /system-backupper/migrations/
RUN chown -R appuser:appuser /system-backupper

USER appuser

EXPOSE 2000
WORKDIR /system-backupper
CMD ["./system-backupper"]
