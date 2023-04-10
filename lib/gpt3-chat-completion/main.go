package main

import (
	"context"
	"fmt"
	"log"
	"os"

	"github.com/go-playground/validator/v10"
	fiber "github.com/gofiber/fiber/v2"
	"github.com/gofiber/fiber/v2/middleware/cors"
	"github.com/jackc/pgx/v5/pgxpool"
)

var pool *pgxpool.Pool
var validate = validator.New()

func setupRoutes(app *fiber.App) {
	api := app.Group("/api")
	v1 := api.Group("/v1")

	chatgpt3cc := v1.Group("/chatgpt3cc")
	chatgpt3cc.Post("/conversation", ValidateConversation, NewConversation)
	chatgpt3cc.Get("/messages/:conversation_id", ValidateMessage, MessagesByConversationID)
	chatgpt3cc.Patch("/user-message", ValidateMessage, NewUserMessage)
	chatgpt3cc.Patch("/assistant-message", ValidateMessage, NewAssistantMessage)
}

func postgresInit() {
	dsn := fmt.Sprintf("postgres://%s:%s@%s/circulate", os.Getenv("DB_USER"), os.Getenv("DB_PASSWORD"), os.Getenv("DB_HOST"))
	var err error
	pool, err = pgxpool.New(context.Background(), dsn)
	if err != nil {
		log.Printf("Unable to connect to database: %v\n", err)
		os.Exit(1)
	}
}

func main() {
	postgresInit()
	app := fiber.New()
	app.Use(cors.New(cors.Config{
		AllowHeaders: "Content-Type, Authorization",
	}))
	setupRoutes(app)

	log.Fatal(app.Listen(":8081"))
}
