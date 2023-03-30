package main

import (
	"encoding/json"
	"fmt"
	"log"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
)

type Conversation struct {
	ID          string `json:"id"`
	Participant string `json:"participant"`
	Message     string `json:"message"`
	Timestamp   int64  `json:"timestamp"`
}

func HandleRequest(request events.APIGatewayProxyRequest) ([]Conversation, error) {
	var conversation []Conversation
	err := json.Unmarshal([]byte(request.Body), &conversation)
	if err != nil {
		log.Printf("Failed to marshal: %v", err)
		return nil, err
	}

	msgIndex := len(conversation) - 1
	conversation[msgIndex], err = storeConversationAuditLog(conversation[msgIndex])
	if err != nil {
		log.Fatalf("Error storing conversation: %s", err)
	} else {
		fmt.Printf("Stored conversation with ID: %s\n", conversation[msgIndex].ID)
	}

	return conversation, nil
}

func main() {
	fmt.Printf("Lambda started")
	lambda.Start(HandleRequest)
}
