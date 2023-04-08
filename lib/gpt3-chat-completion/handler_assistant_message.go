package main

import (
	"encoding/json"
	"log"

	"github.com/gofiber/fiber/v2"
)

// Input user message to send to OpenAI key
func NewAssistantMessage(c *fiber.Ctx) error {
	var message Message
	err := json.Unmarshal(c.Body(), &message)
	if err := validate.Struct(message); err != nil {
		c.Status(fiber.StatusBadRequest).JSON(err.Error())
	}
	if err != nil {
		log.Printf("Error unmarshaling JSON %v", err)
		return fiber.NewError(500, "Error unmarshaling JSON")
	}

	conv, err := GetConversation(message.ConversationId)
	if err != nil {
		log.Printf("Failed to get Conversation from database: %v", err)
		return fiber.NewError(500, "Failed to get conversation from database")
	}

	log.Printf("WPOWOW: %v", conv.Messages)

	gptMessage, err := GetChatGPTCompletionResponse(conv.Messages)
	if err != nil {
		log.Printf("Failed to get ChatGPT response: %v", err)
		return fiber.NewError(500, "Failed to get ChatGPT response")
	}

	message, err = SaveMessage(gptMessage)

	conv, err = UpdateConversationMessages(conv, gptMessage)
	if err != nil {
		log.Printf("Failed to update conversation: %v", err)
		return fiber.NewError(500, "Failed to update conversation")
	}

	return c.Status(200).JSON(message)
}
