package db

import (
	"context"

	"log"
	"os"

	"github.com/jackc/pgx/v5"
	"github.com/joho/godotenv"
)

var Conn *pgx.Conn

func Connect() {
	err := godotenv.Load()
	if err != nil {
		log.Fatal("Error loading .env file")
	}

	password := os.Getenv("DATABASE_URL")
	if password == "" {
		log.Fatal("PASSWORD environment variable not set")
	}

	Conn, err = pgx.Connect(context.Background(), os.Getenv("DATABASE_URL"))
	if err != nil {
		log.Fatal("can't connect to database:", err)
	}

	log.Println("Connected to database on :5432")
}

func CloseDb() {
	Conn.Close(context.Background())
}
