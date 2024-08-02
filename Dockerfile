FROM postgres:15-alpine

WORKDIR /db

COPY README.md ./

RUN echo "Hello world"

EXPOSE 5432
