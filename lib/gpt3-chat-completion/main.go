package main

import (
	"log"
	"os"
	"github.com/go-playground/validator/v10"
	"github.com/aws/aws-sdk-go/service/dynamodb"
	fiber "github.com/gofiber/fiber/v2"
	"github.com/gofiber/fiber/v2/middleware/cors"
)

var ddb *dynamodb.DynamoDB
var validate = validator.New()

func setupRoutes(app *fiber.App) {
	api := app.Group("/api")
	v1 := api.Group("/v1")

	chatgpt3cc := v1.Group("/chatgpt3cc")
	chatgpt3cc.Post("/conversation", ValidateConversation, NewConversation)
	chatgpt3cc.Post("/user-message", ValidateMessage, NewUserMessage)
	chatgpt3cc.Post("/assistant-message", ValidateMessage, NewAssistantMessage)
}

func initDB() {
	client, err := GetDBSession()
	if err != nil {
		log.Fatalf("Failed to start dynamodb session")
	}
	ddb = client
	convTableExist := TableExist(ddb, os.Getenv("CONVERSATION_TABLE"))
	if !convTableExist {
		err = CreateTable(ddb, os.Getenv("CONVERSATION_TABLE"))
		if err != nil {
			log.Fatalf("Failed to create conversation table")
		}
	}
	msgTableExist := TableExist(ddb, os.Getenv("MESSAGE_TABLE"))
	if !msgTableExist {
		err = CreateTable(ddb, os.Getenv("MESSAGE_TABLE"))
		if err != nil {
			log.Fatalf("Failed to create message table")
		}
	}
}

func main() {
	app := fiber.New()
	app.Use(cors.New(cors.Config{
		AllowHeaders: "Content-Type, Authorization",
	}))
	setupRoutes(app)

	initDB()

	log.Fatal(app.Listen(":8081"))
}
