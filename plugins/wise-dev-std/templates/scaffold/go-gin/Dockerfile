FROM golang:1.24 AS build
WORKDIR /src
COPY . .
RUN go build -o /server ./cmd/server || true

FROM gcr.io/distroless/base-debian12
COPY --from=build /server /server
EXPOSE 8080
CMD ["/server"]
