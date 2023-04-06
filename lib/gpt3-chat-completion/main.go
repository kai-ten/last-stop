package main

import (
	"context"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"os"

	"github.com/google/uuid"
	openai "github.com/sashabaranov/go-openai"
)

type Conversation struct {
	ID       string    `json:"id"`
	UserId   string    `json:"userId"`
	Messages []Message `json:"messages"`
}

type Message struct {
	ID             string `json:"id"`
	Participant    string `json:"participant"`
	Message        string `json:"message"`
	Timestamp      int64  `json:"timestamp"`
	ConversationId string `json:"conversationId"`
}

func ConversationOptionsHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	w.Header().Set("Access-Control-Allow-Origin", "*")
	w.Header().Set("Access-Control-Allow-Methods", "*")
	w.Header().Set("Access-Control-Allow-Headers", "*")
	w.Write(nil)
}

func StartConversation(w http.ResponseWriter, r *http.Request) {
	uuid := uuid.New().String()
	log.Printf("Generating conversationId: %v", uuid)
	conv, err := CreateConversation(uuid)
	log.Printf("Generated: %v", conv)

	jsonBytes, err := json.Marshal(conv)
	if err != nil {
		log.Printf("Error creating JSON response %v", err)
		http.Error(w, "Error creating JSON response", http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	w.Write(jsonBytes)
}

func SendMessage(w http.ResponseWriter, r *http.Request) {
	var client = openai.NewClient(os.Getenv("OPENAI_APIKEY"))
	body, err := ioutil.ReadAll(r.Body)
	if err != nil {
		http.Error(w, "Error reading request body", http.StatusBadRequest)
		return
	}

	var message Message
	err = json.Unmarshal(body, &message)
	if err != nil {
		log.Printf("Error unmarshalling JSON %v", err)
		http.Error(w, "Error unmarshaling JSON", http.StatusBadRequest)
		return
	}

	conv, err := GetConversation(message.ConversationId)
	if err != nil {
		log.Printf("Failed to get conversation %v", err)
		http.Error(w, "Failed to get conversation", http.StatusBadRequest)
		return
	}

	conv, err = UpdateConversationMessages(conv, message)
	if err != nil {
		log.Printf("Failed to update conversation %v", err)
		http.Error(w, "Failed to update conversation", http.StatusBadRequest)
		return
	}

	chatCompletion := CreateChatGPTCompletionMessage(conv.Messages)
	log.Printf("ChatCompletion Messages: %v", chatCompletion)

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
		http.Error(w, "Error creating JSON response", http.StatusInternalServerError)
	}

	gptMessage := Message{
		Participant: "assistant",
		Message:     resp.Choices[0].Message.Content,
	}

	conv, err = UpdateConversationMessages(conv, gptMessage)
	if err != nil {
		log.Printf("Failed to update conversation %v", err)
		http.Error(w, "Failed to update conversation", http.StatusBadRequest)
		return
	}

	responseMsg := conv.Messages[len(conv.Messages)-1]

	jsonBytes, err := json.Marshal(responseMsg)
	if err != nil {
		log.Printf("Error creating JSON response %v", err)
		http.Error(w, "Error creating JSON response", http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	w.Header().Set("Access-Control-Allow-Origin", "*")
	w.Header().Set("Access-Control-Allow-Methods", "*")
	w.Header().Set("Access-Control-Allow-Headers", "*")
	w.Write(jsonBytes)
}

func main() {
	mux := mux.newRouter()

	convoHandler := http.HandlerFunc(StartConversation)
	convoOptionsHandler := http.HandlerFunc(ConversationOptionsHandler)
	messageHandler := http.HandlerFunc(SendMessage)

	mux.Handle("/conversation", convoHandler).Methods("GET")
	mux.Handle("/chatgpt3cc", messageHandler)

	err := http.ListenAndServe(":8081", nil)
	if err != nil {
		fmt.Println("Error starting server:", err)
		return
	}
}

func CreateChatGPTCompletionMessage(Message []Message) []openai.ChatCompletionMessage {
	var chatCompletion []openai.ChatCompletionMessage
	for _, m := range Message {
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
	return chatCompletion
}
