package main

import (
	"fmt"
	"log"

	"github.com/aws/aws-lambda-go/lambda"
)

type Conversation struct {
	ID          string `json:"id"`
	Participant string `json:"participant"`
	Message     string `json:"message"`
	Timestamp   int64  `json:"timestamp"`
}

func HandleRequest(conversation []Conversation) ([]Conversation, error) {

	msgIndex := len(conversation) - 1
	output, err := storeConversationAuditLog(conversation[msgIndex])
	if err != nil {
		log.Fatalf("Error storing conversation: %s", err)
	} else {
		fmt.Printf("Stored conversation with ID: %s\n", conversation[msgIndex].ID)
	}

	conversation[msgIndex] = output

	return conversation, nil
}

func main() {
	fmt.Printf("Lambda started")
	lambda.Start(HandleRequest)
}
