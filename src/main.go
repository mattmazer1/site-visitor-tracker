package main

import (
	"log"
	"net/http"

	"github.com/mattmazer1/site-visitor-tracker/db"
)

func healthHandler() {
	// return a ping to ourselves?

}

func userDataHandler(w http.ResponseWriter, r *http.Request) {
	log.Println("Fetching data.....")

	userData, err := db.GetUserData()
	if err != nil {
		http.Error(w, "Failed to retrieve visit count", http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	w.Write([]byte(userData))
}

func addVisitHandler(w http.ResponseWriter, r *http.Request) {
	ipAddress := r.URL.Query()["ip"][0]
	log.Println("Posting data.....")

	err := db.AddNewVisit(ipAddress)
	if err != nil {
		http.Error(w, "Failed to retrieve visit count", http.StatusInternalServerError)
		return
	}
	// do we have to add success reposnes to write?
}

func main() {
	//make sure that if db can't connect we shutdown server
	db.Connect()
	defer db.CloseDb()
	http.HandleFunc("GET /user-data", userDataHandler)
	http.HandleFunc("POST /add-visit", addVisitHandler)

	log.Println("Starting server on :8080")
	log.Fatal(http.ListenAndServe(":8080", nil))
}
