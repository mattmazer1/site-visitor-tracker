package main

import (
	"bytes"
	"encoding/json"
	"io"
	"testing"

	"net/http"
	"net/http/httptest"

	"github.com/mattmazer1/site-visitor-tracker/db"
)

func TestGetUserData(t *testing.T) {
	db.Connect()
	defer db.CloseDb()

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

	if userData.DateTime != "2024-07-31T16:20:27" {
		t.Errorf("expected 2024-07-31T16:20:27 got %v", userData.DateTime)
	}

	if count != 2 {
		t.Errorf("expected 2 got %v", count)
	}
}

func TestAddNewVisit(t *testing.T) {
	db.Connect()
	defer db.CloseDb()

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
