package abs_test

import (
	"testing"

	"path_to_pkg/abs"
)

func TestMain(t *testing.T) {
	got := abs.Abs(-1)
	if got != 1 {
		t.Errorf("Abs(-1) = %d; want 1", got)
	}
}
