FROM golang:15-alpine

WORKDIR /api

RUN echo "Hello world"

RUN go mod download && go mod verify

ENV DATABASE_URL: DB_URL
ENV DEFAULT_URL: DEFAULT_URL
ENV DBINIT: DBINIT

RUN go build /src/main.go /bin

COPY ./bin ./

EXPOSE 5432

CMD [ "go run" ]
