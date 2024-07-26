package db

import (
	"context"
	"errors"
	"fmt"
	"log"
	"os"

	"github.com/jackc/pgx/v5"
	"github.com/joho/godotenv"
)

func Connect() error {
	err := godotenv.Load()
	if err != nil {
		log.Fatal("Error loading .env file")
	}

	password := os.Getenv("DATABASE_URL")
	if password == "" {
		log.Fatal("PASSWORD environment variable not set")
	}

	conn, err := pgx.Connect(context.Background(), os.Getenv("DATABASE_URL"))
	if err != nil {
		fmt.Fprintf(os.Stderr, "Unable to connect to database: %v\n", err)
		os.Exit(1)
	}
	defer conn.Close(context.Background())

	// var test int
	// err = conn.QueryRow(context.Background(), "select * from uservisitcount").Scan(&test)
	// if err != nil {
	// 	fmt.Fprintf(os.Stderr, "QueryRow failed: %v\n", err)
	// 	os.Exit(1)
	// }

	commandTag, err := conn.Exec(context.Background(), "WITH current_count AS (
		SELECT count
		FROM uservisitcount)
		insert into uservisitcount (count) values ((SELECT count FROM current_count) + $1)", 5)
	if err != nil {
		return err
	}

	if commandTag.RowsAffected() != 1 {
		return errors.New("no row found to delete")
	}
	fmt.Println(commandTag)

	rows, _ := conn.Query(context.Background(), "select * from userdata")

	numbers, err := pgx.CollectRows(rows, pgx.RowTo[int32])

	if err != nil {
		return err
	}

	fmt.Println(numbers)

	return nil
}

// UPDATE uservisitcount
// SET count = count + 1
