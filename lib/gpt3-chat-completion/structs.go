package main

import (
	"github.com/go-playground/validator/v10"
	"github.com/gofiber/fiber/v2"
)

type Conversation struct {
	ID       string    `json:"id"`
	UserId   string    `json:"userId"`
	Messages []Message `json:"messages"`
}

type Message struct {
	ID             string `json:"id"`
	Participant    string `json:"participant"`
	Message        string `json:"message" validate:"required"`
	Timestamp      int64  `json:"timestamp"`
	ConversationId string `json:"conversationId" validate:"required"`
}

func ValidateMessage(c *fiber.Ctx) error {
    var errors []*IError
    body := new(Message)
    c.BodyParser(&body)

    err := validate.Struct(body)
    if err != nil {
        for _, err := range err.(validator.ValidationErrors) {
            var el IError
            el.Field = err.Field()
            el.Tag = err.Tag()
            el.Value = err.Param()
            errors = append(errors, &el)
        }
        return c.Status(fiber.StatusBadRequest).JSON(errors)
    }
    return c.Next()
}

func ValidateConversation(c *fiber.Ctx) error {
    var errors []*IError
    body := new(Conversation)
    c.BodyParser(&body)

    err := validate.Struct(body)
    if err != nil {
        for _, err := range err.(validator.ValidationErrors) {
            var el IError
            el.Field = err.Field()
            el.Tag = err.Tag()
            el.Value = err.Param()
            errors = append(errors, &el)
        }
        return c.Status(fiber.StatusBadRequest).JSON(errors)
    }
    return c.Next()
}
