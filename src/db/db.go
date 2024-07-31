package db

import (
	"context"

	"fmt"
	"log"
	"os"

	"github.com/jackc/pgx/v5"
	"github.com/joho/godotenv"
)

var Conn *pgx.Conn

type Test struct {
	Test bool
}

func Connect(t Test) {
	err := godotenv.Load()
	if err != nil {
		log.Fatal("Error loading .env file")
	}

	var password string

	if t.Test {
		password = os.Getenv("TEST_DATABASE_URL")
	} else {
		password = os.Getenv("DATABASE_URL")
	}
	if password == "" {
		log.Fatal("PASSWORD environment variable not set")
	}

	Conn, err = pgx.Connect(context.Background(), os.Getenv("DATABASE_URL"))
	if err != nil {
		fmt.Fprintf(os.Stderr, "Unable to connect to database: %v\n", err)
		os.Exit(1)
	}

	fmt.Println("Connected to database")
}

func CloseDb() {
	Conn.Close(context.Background())
}
