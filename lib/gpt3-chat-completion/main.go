package main

import (
	"context"
	"fmt"
	"log"
	"os"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	ssm "github.com/aws/aws-secretsmanager-caching-go/secretcache"
	openai "github.com/sashabaranov/go-openai"
)

var (
	secretcache, ssm_err = ssm.New()
)

func getSecret() (string, error) {
	if ssm_err != nil {
		return "", fmt.Errorf("failed to get SSM cache: %v", ssm_err)
	}

	secret, err := secretcache.GetSecretString(os.Getenv("OPENAPI_SECRET_NAME"))
	if err != nil {
		return "", fmt.Errorf("failed to get secret from SSM cache: %v", err)
	}

	return secret, nil
}

var headers = map[string]string{
	"Access-Control-Allow-Origin": "*",
	"Content-Type":                "application/json",
}

type Conversation struct {
	ID          string `json:"id"`
	Participant string `json:"participant"`
	Message     string `json:"message"`
	Timestamp   int64  `json:"timestamp"`
}

func HandleRequest(conversation []Conversation) (events.APIGatewayProxyResponse, error) {
	api_key, err := getSecret()
	if err != nil {
		fmt.Printf("Error: %v\n", err)
		return events.APIGatewayProxyResponse{Headers: headers, StatusCode: 500, Body: "Failed get OpenAPI credentials"}, nil
	}

	log.Print(api_key)

	var client = openai.NewClient(api_key)
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
		return events.APIGatewayProxyResponse{Headers: headers, StatusCode: 500, Body: "Invalid Message"}, nil
	}

	return events.APIGatewayProxyResponse{
		Headers:    headers,
		StatusCode: 200,
		Body:       resp.Choices[0].Message.Content,
	}, nil
}

func main() {
	fmt.Printf("Lambda started")
	lambda.Start(HandleRequest)
}
