package db

import (
	"context"
	"fmt"
	"os"

	"github.com/jackc/pgx/v5/pgxpool"
)

func Connect() {
	testing := os.Getenv("DB_CONNECTION_URL")
	fmt.Println("testing babyyyyyy")
	fmt.Println(testing)
	// password := os.Getenv("PASSWORD")
	// if password == "" {
	// 	log.Fatal("PASSWORD environment variable not set")
	// }
	dbpool, err := pgxpool.New(context.Background(), os.Getenv("DB_CONNECTION_URL"))
	if err != nil {
		fmt.Fprintf(os.Stderr, "Unable to create connection pool: %v\n", err)
		os.Exit(1)
	}
	defer dbpool.Close()

	var greeting string
	err = dbpool.QueryRow(context.Background(), "select * from UserVisitCount").Scan(&greeting)
	if err != nil {
		fmt.Fprintf(os.Stderr, "QueryRow failed: %v\n", err)
		os.Exit(1)
	}

	fmt.Println(greeting)
	fmt.Println("Connecting to db..")
}
