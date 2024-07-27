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

	commandTag, err := conn.Exec(context.Background(),
		`UPDATE uservisitcount
     SET count = (SELECT count FROM uservisitcount LIMIT 1) + $1
     WHERE id = 1`,
		1)
	if err != nil {
		return err
	}

	if commandTag.RowsAffected() != 1 {
		return errors.New("no row found to delete")
	}
	fmt.Println(commandTag)
	fmt.Println("GREAT SUCESSS!!!")

	var test int
	err = conn.QueryRow(context.Background(), "SELECT count FROM uservisitcount").Scan(&test)
	if err != nil {
		fmt.Fprintf(os.Stderr, "QueryRow failed: %v\n", err)
		os.Exit(1)
	}

	fmt.Println(test)

	rows, _ := conn.Query(context.Background(), "SELECT * FROM userdata")

	res, err := pgx.CollectRows(rows, pgx.RowTo[string])

	if err != nil {
		return err
	}

	fmt.Println(res)

	return nil
}
