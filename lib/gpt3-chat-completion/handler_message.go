package main

import (
	"encoding/json"
	"log"

	"github.com/gofiber/fiber/v2"
)

func MessagesByConversationID(c *fiber.Ctx) error {
	converstionId := c.Params("conversation_id")

	messages, err := GetMessagesByConversationID(converstionId)
	if err != nil {
		log.Printf("Error unmarshaling JSON: %v", err)
		return fiber.NewError(500, "Error unmarshaling JSON")
	}

	return c.Status(200).JSON(messages)
}

func NewUserMessage(c *fiber.Ctx) error {
	var message Message
	err := json.Unmarshal(c.Body(), &message)
	message.Participant = "user"

	if err != nil {
		log.Printf("Error unmarshaling JSON: %v", err)
		return fiber.NewError(500, "Error unmarshaling JSON")
	}

	message, err = CreateMessage(message)
	if err != nil {
		log.Printf("Failed to update Conversation: %v", err)
		return fiber.NewError(500, "Failed to update Conversation")
	}

	return c.Status(200).JSON(message)
}

func NewAssistantMessage(c *fiber.Ctx) error {
	var message Message
	err := json.Unmarshal(c.Body(), &message)
	if err := validate.Struct(message); err != nil {
		log.Print(message)
		c.Status(fiber.StatusBadRequest).JSON(err.Error())
	}
	if err != nil {
		log.Printf("Error unmarshaling JSON %v", err)
		return fiber.NewError(500, "Error unmarshaling JSON")
	}

	messages, err := GetMessagesByConversationID(message.ConversationId)
	if err != nil {
		log.Printf("Failed to get Messages response: %v", err)
		return fiber.NewError(500, "Failed to get Messages response")
	}

	gptMessage, err := GetChatGPTCompletionResponse(messages)
	if err != nil {
		log.Printf("Failed to get ChatGPT response: %v", err)
		return fiber.NewError(500, "Failed to get ChatGPT response")
	}

	gptMessage.ConversationId = message.ConversationId
	message, err = CreateMessage(gptMessage)
	if err != nil {
		log.Printf("Failed to get Message response: %v", err)
		return fiber.NewError(500, "Failed to get Message response")
	}

	return c.Status(200).JSON(message)
}
