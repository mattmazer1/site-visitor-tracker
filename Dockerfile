FROM golang:15-alpine AS builder

WORKDIR /api

COPY go.mod go.sum ./

RUN go mod download && go mod verify

COPY . .

ENV DATABASE_URL: DATABASE_URL
ENV DEFAULT_URL: DEFAULT_URL
ENV DBINIT: DBINIT

RUN go build -v -o ./bin/server ./src/main.go

FROM alpine:latest AS final

WORKDIR /server

COPY --from=builder /api/bin/ /server/

EXPOSE 8080

RUN useradd runner

USER runner

ENTRYPOINT [ "server" ]
