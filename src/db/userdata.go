package db

import (
	"context"
	"errors"
	"fmt"
	"log"
	"time"
)

func GetUserData() (string, error) {
	query := `
    SELECT json_build_object(
        'userData', json_agg(
            json_build_object('ip', ip, 'datetime', datetime)
        ),
		'count', (SELECT count FROM uservisitcount LIMIT 1)
    ) AS result
    FROM (SELECT ip, datetime
		FROM userdata
		ORDER BY id DESC
		) subquery;`

	row := Conn.QueryRow(context.Background(), query)

	var jsonResult string

	err := row.Scan(&jsonResult)
	if err != nil {
		log.Fatal("error scanning result:", err)
		return "", nil
	}

	return jsonResult, nil
}

func AddNewVisit(ipAddress string) error {
	tx, err := Conn.Begin(context.Background())
	if err != nil {
		return fmt.Errorf("failed to begin transaction: %w", err)
	}

	defer tx.Rollback(context.Background())

	commandTag, err := tx.Exec(context.Background(),
		`INSERT INTO userdata (ip, datetime)
		VALUES($1, $2 )`, ipAddress, time.Now().Format("2006-01-02 15:04:05"))
	if err != nil {
		log.Fatal("could not insert data:", err)
		return errors.New("could not insert data")
	}

	if commandTag.RowsAffected() != 1 {
		return errors.New("no row found to delete")
	}

	fmt.Println(commandTag)

	err = UpdateVisitCount(tx)
	if err != nil {
		return errors.New("failed to retrieve visit count")
	}

	err = tx.Commit(context.Background())
	if err != nil {
		return fmt.Errorf("failed to commit transaction: %w", err)
	}

	fmt.Println("GREAT SUCESSS!!!")

	return nil
}
