package db

import (
	"context"
	"errors"
	"fmt"
)

func UpdateVisitCount() error {
	// do we need the "where id = 1?"
	commandTag, err := Conn.Exec(context.Background(),
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

	return nil
}
