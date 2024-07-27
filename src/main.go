package main

import (
	"encoding/json"
	"log"
	"net/http"

	"github.com/mattmazer1/site-visitor-tracker/db"
)

type Payload struct {
	Ip          string `json:"ip"`
	Date        string `json:"date"`
	Time        string `json:"time"`
	TotalVisits int    `json:"totalVisits"`
}

type getHandler struct {
}

type postHandler struct {
}

func healthHandler() {
	// return a ping to ourselves?

}

func (h *getHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	log.Println("Fetching data.....")

	payload := Payload{
		Ip:          "123.123.123",
		Date:        "19/07/2023",
		Time:        "23:08",
		TotalVisits: 12,
	}

	w.Header().Set("Content-Type", "application/json")

	json.NewEncoder(w).Encode(payload)
}

func (h *postHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	log.Println("Posting data.....")

}

func main() {
	http.Handle("GET /data", new(getHandler))
	http.Handle("POST /user", new(postHandler))

	log.Println("Starting server on :8080")
	log.Fatal(http.ListenAndServe(":8080", nil))
	db.Connect()
}
