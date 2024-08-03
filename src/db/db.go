package db

import (
	"context"

	"log"
	"os"

	"github.com/jackc/pgx/v5"
	"github.com/joho/godotenv"
)

var Conn *pgx.Conn
var conn *pgx.Conn

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

func RemoveDb() error {
	CloseDb()

	connectToDefaultDb()
	defer closeDefaultDb()

	_, err := conn.Exec(context.Background(), "DROP DATABASE IF EXISTS personal_site_user_dataa;")
	if err != nil {
		return err
	}
	return nil
}

func connectToDefaultDb() {
	err := godotenv.Load()
	if err != nil {
		log.Fatal("Error loading .env file")
	}

	password := os.Getenv("DEFAULT_URL")
	if password == "" {
		log.Fatal("PASSWORD environment variable not set")
	}

	conn, err = pgx.Connect(context.Background(), os.Getenv("DEFAULT_URL"))
	if err != nil {
		log.Fatal("can't connect to database:", err)
	}

	log.Println("Connected to default database on :5432")
}

func closeDefaultDb() {
	conn.Close(context.Background())
}
