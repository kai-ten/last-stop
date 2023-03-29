package main

import (
	"context"
	"encoding/json"
	"fmt"
	"os"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	openai "github.com/sashabaranov/go-openai"
)

var client = openai.NewClient(os.Getenv("OPENAPI_KEY"))

type Conversation struct {
	Participant string `json:"participant"`
	Message     string `json:"message"`
}

func HandleRequest(request events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	message := request.Body
	fmt.Printf("Parsed: %v", message)

	var conversation []Conversation
	err := json.Unmarshal([]byte(message), &conversation)
	if err != nil {
		return events.APIGatewayProxyResponse{StatusCode: 400, Body: "No conversations were submitted"}, nil
	}

	var chatCompletion []openai.ChatCompletionMessage
	for _, c := range conversation {

		if c.Participant == "user" {
			chatCompletion = append(chatCompletion, openai.ChatCompletionMessage{
				Role:    c.Participant,
				Content: c.Message,
			})
		} else if c.Participant == "assistant" {
			chatCompletion = append(chatCompletion, openai.ChatCompletionMessage{
				Role:    c.Participant,
				Content: c.Message,
			})
		}
	}

	resp, err := client.CreateChatCompletion(
		context.Background(),
		openai.ChatCompletionRequest{
			Temperature: 0.8,
			Model:       openai.GPT3Dot5Turbo,
			Messages:    chatCompletion,
		},
	)

	if err != nil {
		fmt.Printf("ChatCompletion error: %v\n", err)
		return events.APIGatewayProxyResponse{StatusCode: 500, Body: "Invalid Message"}, nil
	}

	return events.APIGatewayProxyResponse{
		StatusCode: 200,
		Body:       resp.Choices[0].Message.Content,
	}, nil
}

func main() {
	fmt.Printf("Lambda started")
	lambda.Start(HandleRequest)
}
