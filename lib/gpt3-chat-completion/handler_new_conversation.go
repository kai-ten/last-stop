package main

import (
	"log"

	"github.com/gofiber/fiber/v2"
)

func NewConversation(c *fiber.Ctx) error {
	created_conv, err := CreateConversation()
	if err != nil {
		log.Printf("Error creating conversation %v", err)
		return fiber.NewError(500, "Error creating Conversation")
	}

	return c.Status(200).JSON(created_conv)
}
