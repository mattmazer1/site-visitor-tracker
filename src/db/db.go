package db

import (
	"context"
	"fmt"
	"log"
	"os"

	"github.com/jackc/pgx/v5"
	"github.com/joho/godotenv"
)

func Connect() {
	err := godotenv.Load()
	if err != nil {
		log.Fatal("Error loading .env file")
	}

	// password := os.Getenv("PASSWORD")
	// if password == "" {
	// 	log.Fatal("PASSWORD environment variable not set")
	// }
	// dbpool, err := pgxpool.New(context.Background(), os.Getenv("DB_CONNECTION_URL"))
	// conn, err := pgx.Connect(context.Background(), os.Getenv("DATABASE_URL"))
	dbpool, err := pgx.Connect(context.Background(), os.Getenv("DB_CONNECTION_URL"))
	if err != nil {
		fmt.Fprintf(os.Stderr, "Unable to connect to database: %v\n", err)
		os.Exit(1)
	}
	defer dbpool.Close(context.Background())

	var greeting string
	err = dbpool.QueryRow(context.Background(), "SELECT * FROM uservisitcount").Scan(&greeting)
	if err != nil {
		fmt.Fprintf(os.Stderr, "QueryRow failed: %v\n", err)
		os.Exit(1)
	}

	fmt.Println(greeting)
	fmt.Println("Connecting to db..")
}
