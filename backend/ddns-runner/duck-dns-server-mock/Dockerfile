FROM rust:1.80.1-slim-bookworm AS build

RUN apt update && apt install -y pkg-config libssl-dev

WORKDIR /build
COPY . .
RUN cargo build --release

FROM debian:bookworm-20240311

RUN apt update && apt install -y libssl-dev && apt clean

WORKDIR /duck-dns-mock
COPY --from=build /build/target/release/duck-dns-server-mock .
EXPOSE 6000
CMD ["/duck-dns-mock/duck-dns-server-mock"]
