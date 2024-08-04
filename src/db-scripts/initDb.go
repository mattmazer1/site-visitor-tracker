package dbScripts

import (
	"context"
	"fmt"
	"io"
	"log"
	"os"

	"github.com/jackc/pgx/v5"

	"github.com/mattmazer1/site-visitor-tracker/src/db"
)

var conn *pgx.Conn

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

func InitDB() error {
	connectToDefaultDb()

	_, err := conn.Exec(context.Background(), "CREATE DATABASE personal_site_user_dataa;")
	if err != nil {
		return fmt.Errorf("failed to create database: %v", err)
	}

	closeDefaultDb()

	db.Connect()
	defer db.CloseDb()

	url := os.Getenv("DBINIT")
	if url == "" {
		log.Fatal("PASSWORD environment variable not set")
	}

	sqlFile := url
	file, err := os.Open(sqlFile)
	if err != nil {
		return err
	}
	defer file.Close()

	content, err := io.ReadAll(file)
	if err != nil {
		return err
	}

	sqlScript := string(content)
	_, err = db.Conn.Exec(context.Background(), sqlScript)
	if err != nil {
		return err
	}
	return nil
}
