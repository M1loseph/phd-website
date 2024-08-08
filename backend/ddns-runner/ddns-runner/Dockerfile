FROM rust:1.76.0-slim-bookworm as build

WORKDIR /app
COPY . .

RUN apt update && apt install -y pkg-config libssl-dev

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

COPY --from=build /app/target/release/ddns-runner /bin/ddns-runner
EXPOSE 3000
CMD ["/bin/ddns-runner"]
