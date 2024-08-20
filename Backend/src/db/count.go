package db

import (
	"context"
	"fmt"

	"github.com/jackc/pgx/v5"
)

func UpdateVisitCount(tx pgx.Tx) error {
	commandTag, err := tx.Exec(context.Background(),
		`UPDATE uservisitcount
	 SET count = (SELECT count FROM uservisitcount LIMIT 1) + $1
	 WHERE id = 1`,
		1)
	if err != nil {
		return fmt.Errorf("failed to update visit count %v", err)
	}

	if commandTag.RowsAffected() != 1 {
		return fmt.Errorf("no rows were affected %v", err)
	}

	return nil
}
