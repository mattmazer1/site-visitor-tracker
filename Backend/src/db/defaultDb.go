package db

import (
	"context"
	"log"
	"os"

	"github.com/jackc/pgx/v5"
)

var DefaultConn *pgx.Conn

func ConnectToDefaultDb() {

	password := os.Getenv("DEFAULT_URL")
	if password == "" {
		log.Fatal("PASSWORD environment variable not set")
	}

	var err error
	DefaultConn, err = pgx.Connect(context.Background(), password)
	if err != nil {
		log.Fatal("can't connect to database:", err)
	}

	log.Println("Connected to default database on :5432")
}

func CloseDefaultDb() {
	DefaultConn.Close(context.Background())
}
