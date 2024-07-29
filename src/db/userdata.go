package db

import (
	"context"
	"errors"
	"fmt"
	"time"
)

func getUserData() (string, error) {
	query := `
    SELECT json_build_object(
        'items', json_agg(
            json_build_object('ip', ip, 'datetime', datetime)
        )
    ) AS result
    FROM (SELECT ip, datetime FROM userdata ORDER BY id DESC) subquery;`

	row := Conn.QueryRow(context.Background(), query)

	var jsonResult string
	err := row.Scan(&jsonResult)
	if err != nil {
		fmt.Println("Error scanning result:", err)
		return "", nil
	}
	return jsonResult, nil
}

func addNewVisit() error {
	commandTag, err := Conn.Exec(context.Background(),
		`INSERT INTO userdata (ip, datetime)
		VALUES($1, $2 )`, "123.123.12.3", time.Now().Format("2006-01-02 15:04:05"))
	if err != nil {
		return err
	}

	if commandTag.RowsAffected() != 1 {
		return errors.New("no row found to delete")
	}
	fmt.Println(commandTag)
	fmt.Println("GREAT SUCESSS!!!")

	return nil
}
