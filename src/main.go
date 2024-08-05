package main

import (
	"encoding/json"
	"io"
	"log"
	"net"
	"net/http"

	"github.com/mattmazer1/site-visitor-tracker/src/db"
)

type UserIP struct {
	IP string `json:"ip"`
}

func GetUserData(w http.ResponseWriter, r *http.Request) {
	userData, err := db.GetUserData()
	if err != nil {
		http.Error(w, "Failed to retrieve user data", http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	w.Write([]byte(userData))
}

func AddUserData(w http.ResponseWriter, r *http.Request) {
	defer r.Body.Close()

	data, err := io.ReadAll(r.Body)
	if err != nil {
		http.Error(w, "Failed to make GET request: %v", http.StatusInternalServerError)
	}

	var userData UserIP

	if err := json.Unmarshal(data, &userData); err != nil {
		http.Error(w, "Bad Request", http.StatusBadRequest)
		return
	}

	ipAddress := userData.IP

	if ipAddress == "" {
		http.Error(w, "IP address is required", http.StatusBadRequest)
		return
	}

	if net.ParseIP(ipAddress) == nil {
		http.Error(w, "Invalid IP address format", http.StatusBadRequest)
		return
	}

	err = db.AddNewVisit(ipAddress)
	if err != nil {
		http.Error(w, "Failed to retrieve visit count", http.StatusInternalServerError)
		return
	}

	w.WriteHeader(http.StatusOK)
}

func main() {
	db.Connect()
	defer db.CloseDb()

	http.HandleFunc("GET /user-data", GetUserData)
	http.HandleFunc("POST /add-visit", AddUserData)

	log.Println("Starting server on :8080")
	log.Fatal(http.ListenAndServe(":8080", nil))
}
