FROM golang:alpine AS builder

WORKDIR /api

COPY go.mod go.sum ./

RUN go mod download && go mod verify

COPY . .

RUN go build -v -o ./bin/server ./src/main.go

ENV DATABASE_URL DATABASE_URL

FROM alpine:latest AS final

WORKDIR /server

COPY --from=builder /api/bin/server /server/

EXPOSE 8080

RUN addgroup -S appgroup && adduser -S appuser -G appgroup

USER appuser

ENTRYPOINT [ "./server" ]
