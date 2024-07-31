package main

import (
	"encoding/json"
	"io"
	"log"
	"net/http"

	"github.com/mattmazer1/site-visitor-tracker/db"
)

func GetUserData(w http.ResponseWriter, r *http.Request) {
	userData, err := db.GetUserData()
	if err != nil {
		http.Error(w, "Failed to retrieve visit count", http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	w.Write([]byte(userData))
}

func AddUserData(w http.ResponseWriter, r *http.Request) {
	type UserIP struct {
		IP string `json:"ip"`
	}

	defer r.Body.Close()

	data, err := io.ReadAll(r.Body)
	if err != nil {
		// log.Fatal(err)
		http.Error(w, "Failed to make GET request: %v", http.StatusInternalServerError)
	}

	var userData UserIP

	if err := json.Unmarshal(data, &userData); err != nil {
		http.Error(w, "Bad Request", http.StatusBadRequest)
		return
	}

	ipAddress := userData.IP

	// word := query.Get("word")
	// if len(word) == 0 {
	//     w.WriteHeader(http.StatusBadRequest)
	//     fmt.Fprintf(w, "missing word")
	//     return
	// }

	err = db.AddNewVisit(ipAddress)
	if err != nil {
		http.Error(w, "Failed to retrieve visit count", http.StatusInternalServerError)
		return
	}
	w.WriteHeader(http.StatusOK)
}

func main() {
	//make sure that if db can't connect we shutdown server
	test := db.Test{
		Test: false,
	}
	db.Connect(test)
	defer db.CloseDb()

	http.HandleFunc("GET /user-data", GetUserData)
	http.HandleFunc("POST /add-visit", AddUserData)

	log.Println("Starting server on :8080")
	log.Fatal(http.ListenAndServe(":8080", nil))
}
