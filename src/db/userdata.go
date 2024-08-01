package db

import (
	"context"
	"fmt"
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
		return "", fmt.Errorf("error scanning user data %v", err)
	}

	return jsonResult, nil
}

func AddNewVisit(ipAddress string) error {
	tx, err := Conn.Begin(context.Background())
	if err != nil {
		return fmt.Errorf("failed to initiate transaction: %v", err)
	}

	defer tx.Rollback(context.Background())

	commandTag, err := tx.Exec(context.Background(),
		`INSERT INTO userdata (ip, datetime)
		VALUES($1, $2 )`, ipAddress, time.Now().Format("2006-01-02 15:04:05"))
	if err != nil {
		return fmt.Errorf("could not insert visit data %v", err)
	}

	if commandTag.RowsAffected() != 1 {
		return fmt.Errorf("no rows were affected %v", err)
	}

	err = UpdateVisitCount(tx)
	if err != nil {
		return fmt.Errorf("failed to update visit count %v", err)
	}

	err = tx.Commit(context.Background())
	if err != nil {
		return fmt.Errorf("failed to commit transaction: %v", err)
	}

	return nil
}
