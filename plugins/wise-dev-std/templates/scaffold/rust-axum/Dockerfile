FROM rust:1 AS build
WORKDIR /src
COPY . .
RUN cargo build --release || true

FROM debian:bookworm-slim
COPY --from=build /src/target/release/{{PROJECT_NAME}} /app/server
EXPOSE 3000
CMD ["/app/server"]
