package main

import (
	"bytes"
	"encoding/json"

	"io"
	"log"
	"os"
	"testing"

	"time"

	"net/http"
	"net/http/httptest"

	"github.com/mattmazer1/site-visitor-tracker/src/db"
	dbScripts "github.com/mattmazer1/site-visitor-tracker/src/db-scripts"
)

func TestMain(m *testing.M) {
	err := dbScripts.InitDB()
	if err != nil {
		log.Fatalf("Failed to initialize database: %v", err)
	}

	db.Connect()

	exitVal := m.Run()

	err = db.RemoveDb()
	if err != nil {
		log.Fatalf("Failed to drop database: %v", err)
	}

	os.Exit(exitVal)
}
func TestAddNewVisit(t *testing.T) {
	log.Println("Test AddNewVisit")

	ts := httptest.NewServer(http.HandlerFunc(AddUserData))
	defer ts.Close()

	data := map[string]string{"ip": "123.123.12.3"}

	jsonData, err := json.Marshal(data)
	if err != nil {
		t.Errorf("could not marshal data")
	}

	res, err := http.Post(ts.URL+"/user-data", "application/json", bytes.NewBuffer(jsonData))
	if err != nil {
		t.Fatalf("Failed to make POST request: %v", err)
	}

	if res.StatusCode != 200 {
		t.Errorf("expected status code of 200, got %v", res.StatusCode)
	}

	res.Body.Close()
}

func TestGetUserData(t *testing.T) {
	log.Println("Test GetUserData")

	ts := httptest.NewServer(http.HandlerFunc(GetUserData))
	defer ts.Close()

	res, err := http.Get(ts.URL + "/user-data")
	if err != nil {
		t.Fatalf("Failed to make GET request: %v", err)
	}

	data, err := io.ReadAll(res.Body)
	res.Body.Close()
	if err != nil {
		t.Fatalf("Failed to make GET request: %v", err)
	}

	type UserData struct {
		IP       string `json:"ip"`
		DateTime string `json:"datetime"`
	}

	type Response struct {
		UserData []UserData `json:"userData"`
		Count    int        `json:"count"`
	}

	var response Response

	if err := json.Unmarshal(data, &response); err != nil {
		t.Fatalf("Failed to unmarshal response body: %v", err)
	}

	if len(response.UserData) == 0 {
		t.Fatal("No user data found")
	}

	userData := response.UserData[0]
	count := response.Count

	if userData.IP != "123.123.12.3" {
		t.Errorf("expected 123.123.12.3 got %v", userData.IP)
	}

	parsedDbDate, err := time.Parse("2006-01-02 15:04:05", userData.DateTime)
	if err != nil {
		t.Errorf("Error parsing date")
	}

	dbDate := parsedDbDate.Format("2006-01-02")
	currentDate := time.Now().Format("2006-01-02")

	if dbDate != currentDate {
		t.Errorf("expected %v got %v", currentDate, dbDate)
	}

	if count != 2 {
		t.Errorf("expected 2 got %v", count)
	}
}
