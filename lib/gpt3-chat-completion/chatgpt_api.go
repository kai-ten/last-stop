package main

import (
	"context"
	"fmt"
	"os"

	openai "github.com/sashabaranov/go-openai"
)

var client = openai.NewClient(os.Getenv("OPENAI_APIKEY"))

func createChatGPTCompletionMessage(messages []Message) ([]openai.ChatCompletionMessage, error) {
	var chatCompletion []openai.ChatCompletionMessage
	for _, m := range messages {
		if m.Participant == "user" {
			chatCompletion = append(chatCompletion, openai.ChatCompletionMessage{
				Role:    m.Participant,
				Content: m.Message,
			})
		} else if m.Participant == "assistant" {
			chatCompletion = append(chatCompletion, openai.ChatCompletionMessage{
				Role:    m.Participant,
				Content: m.Message,
			})
		}
	}
	if len(chatCompletion) == 0 {
		return nil, fmt.Errorf("Error creating chatgpt request message")
	}
	return chatCompletion, nil
}

func GetChatGPTCompletionResponse(messages []Message) (Message, error) {
	messageReq, err := createChatGPTCompletionMessage(messages)
	if err != nil {
		fmt.Printf("ChatCompletion Message error: %v\n", err)
		return Message{}, err
	}

	resp, err := client.CreateChatCompletion(
		context.Background(),
		openai.ChatCompletionRequest{
			Temperature: 0.8,
			Model:       openai.GPT3Dot5Turbo,
			Messages:    messageReq,
		},
	)
	if err != nil {
		fmt.Printf("ChatCompletion error: %v\n", err)
		return Message{}, err
	}

	gptMessage := Message{
		Participant: "assistant",
		Message:     resp.Choices[0].Message.Content,
	}

	return gptMessage, nil
}
