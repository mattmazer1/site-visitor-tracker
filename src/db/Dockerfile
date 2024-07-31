FROM 15-Alpine

WORKDIR /db

RUN sudo apt-run update && sudo apt-run install -y postgres

FROM alpine:latest

EXPOSE 8080

CMD ["start postgres"]

