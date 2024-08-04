package db

import (
	"context"

	"log"
	"os"

	"github.com/jackc/pgx/v5"
)

var Conn *pgx.Conn
var conn *pgx.Conn

func Connect() {
	password := os.Getenv("DATABASE_URL")
	if password == "" {
		log.Fatal("PASSWORD environment variable not set")
	}

	var err error
	Conn, err = pgx.Connect(context.Background(), password)
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

	_, err := conn.Exec(context.Background(), "DROP DATABASE IF EXISTS personal_site_user_data;")
	if err != nil {
		return err
	}
	return nil
}

func connectToDefaultDb() {

	password := os.Getenv("DEFAULT_URL")
	if password == "" {
		log.Fatal("PASSWORD environment variable not set")
	}

	var err error
	conn, err = pgx.Connect(context.Background(), password)
	if err != nil {
		log.Fatal("can't connect to database:", err)
	}

	log.Println("Connected to default database on :5432")
}

func closeDefaultDb() {
	conn.Close(context.Background())
}
