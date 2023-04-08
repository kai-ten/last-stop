package main

import (
	"encoding/json"
	"log"
	"github.com/gofiber/fiber/v2"
)

type IError struct {
    Field string
    Tag   string
    Value string
}

func NewUserMessage(c *fiber.Ctx) error {

	log.Print(string(c.Body()))
	var message Message
	err := json.Unmarshal(c.Body(), &message)
	message.Participant = "user"

	if err != nil {
		log.Printf("Error unmarshaling JSON: %v", err)
		return fiber.NewError(500, "Error unmarshaling JSON")
	}

	conv, err := GetConversation(message.ConversationId)
	if err != nil {
		log.Printf("Failed to get Conversation from database: %v", err)
		return fiber.NewError(500, "Failed to get conversation from database")
	}

	message, err = SaveMessage(message)

	conv, err = UpdateConversationMessages(conv, message)
	if err != nil {
		log.Printf("Failed to update Conversation: %v", err)
		return fiber.NewError(500, "Failed to update Conversation")
	}

	return c.Status(200).JSON(message)
}
