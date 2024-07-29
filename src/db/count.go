package db

import (
	"context"
	"errors"
	"fmt"
)

func getVisitCount() error {
	row := Conn.QueryRow(context.Background(), "SELECT count FROM uservisitcount")

	var test int
	err := row.Scan(&test)
	if err != nil {
		// fmt.Fprintf(os.Stderr, "QueryRow failed: %v\n", err)
		return errors.New("QueryRow failed")
	}

	fmt.Println(test)

	return nil
}

func updateVisitCount() error {
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
