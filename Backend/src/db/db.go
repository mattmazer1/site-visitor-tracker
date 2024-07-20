package db

import (
	"context"
	"log"
	"os"

	"github.com/jackc/pgx/v5"
)

var Conn *pgx.Conn

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

	ConnectToDefaultDb()
	defer CloseDefaultDb()

	_, err := DefaultConn.Exec(context.Background(), "DROP DATABASE IF EXISTS personal_site_user_data;")
	if err != nil {
		return err
	}
	return nil
}
