package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"

	"github.com/google/uuid"
)

type Conversation struct {
	ID          uuid.UUID `json:"id"`
	Participant string    `json:"participant"`
	Message     string    `json:"message"`
	Timestamp   int64     `json:"timestamp"`
}

func main() {

	http.HandleFunc("/audit", func(w http.ResponseWriter, r *http.Request) {
		body, err := ioutil.ReadAll(r.Body)
		if err != nil {
			http.Error(w, "Error reading request body", http.StatusBadRequest)
			return
		}

		var conversation []Conversation
		err = json.Unmarshal(body, &conversation)
		if err != nil {
			http.Error(w, "Error unmarshaling JSON", http.StatusBadRequest)
			return
		}

		msgIndex := len(conversation) - 1
		output, err := StoreConversationAuditLog(conversation[msgIndex])
		if err != nil {
			log.Fatalf("Error storing conversation: %s", err)
		} else {
			fmt.Printf("Stored conversation with ID: %s\n", conversation[msgIndex].ID)
		}

		conversation[msgIndex] = output

		jsonBytes, err := json.Marshal(conversation)
		if err != nil {
			http.Error(w, "Error marshalling conversation", http.StatusInternalServerError)
		}

		// return conversation, nil
		w.Header().Set("Content-Type", "application/json")
		w.Write(jsonBytes)
	})

	// err := http.ListenAndServeTLS(":8080", "cert.pem", "key.pem", nil)
	err := http.ListenAndServe(":8080", nil)
	if err != nil {
		fmt.Println("Error starting server:", err)
		return
	}

}
