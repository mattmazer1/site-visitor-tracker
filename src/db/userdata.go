package db

import (
	"context"
	"errors"
	"fmt"
	"time"
)

func GetUserData() (string, error) {
	//needs to be transaction
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
		fmt.Println("Error scanning result:", err)
		return "", nil
	}
	return jsonResult, nil
}

func AddNewVisit(ipAddress string) error {
	//add transaction
	commandTag, err := Conn.Exec(context.Background(),
		`INSERT INTO userdata (ip, datetime)
		VALUES($1, $2 )`, ipAddress, time.Now().Format("2006-01-02 15:04:05"))

	if err != nil {
		return err
	}

	if commandTag.RowsAffected() != 1 {
		return errors.New("no row found to delete")
	}

	fmt.Println(commandTag)

	UpdateVisitCount()

	fmt.Println("GREAT SUCESSS!!!")

	return nil
}
