FROM rust:1.76.0-slim-bookworm as build

RUN apt update && apt install -y pkg-config libssl-dev

WORKDIR /build
COPY . .
RUN cargo build --release

FROM debian:bookworm-20240311

RUN apt update && apt install -y libssl-dev && apt clean
# Create a non-privileged user that the app will run under.
# See https://docs.docker.com/go/dockerfile-user-best-practices/
ARG UID=10001
RUN adduser \
    --disabled-password \
    --gecos "" \
    --home "/nonexistent" \
    --shell "/sbin/nologin" \
    --no-create-home \
    --uid "${UID}" \
    appuser
USER appuser

COPY --from=build /build/target/release/ddns-runner /ddns-runner/ddns-runner
COPY --chown=appuser:appuser ./migrations /ddns-runner/migrations/
EXPOSE 3000
CMD ["/ddns-runner/ddns-runner"]
