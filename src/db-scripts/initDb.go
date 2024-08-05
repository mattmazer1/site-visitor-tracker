package dbScripts

import (
	"context"
	"fmt"
	"io"
	"log"
	"os"

	"github.com/mattmazer1/site-visitor-tracker/src/db"
)

func InitDB() error {
	db.ConnectToDefaultDb()

	_, err := db.DefaultConn.Exec(context.Background(), "CREATE DATABASE personal_site_user_data;")
	if err != nil {
		return fmt.Errorf("failed to create database: %v", err)
	}

	db.CloseDefaultDb()

	db.Connect()
	defer db.CloseDb()

	url := os.Getenv("DBINIT")
	if url == "" {
		log.Fatal("PASSWORD environment variable not set")
	}

	sqlFile := url
	file, err := os.Open(sqlFile)
	if err != nil {
		return fmt.Errorf("failed to open sql file: %v", err)
	}
	defer file.Close()

	content, err := io.ReadAll(file)
	if err != nil {
		return fmt.Errorf("failed to read sql script: %v", err)
	}

	sqlScript := string(content)
	_, err = db.Conn.Exec(context.Background(), sqlScript)
	if err != nil {
		return fmt.Errorf("failed to execute sql script: %v", err)
	}

	return nil
}
