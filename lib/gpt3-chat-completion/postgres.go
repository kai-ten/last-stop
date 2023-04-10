package main

import (
	"context"
	"log"

	"github.com/google/uuid"
)

func GetConversation(conversationId string) (Conversation, error) {
	var responseConversation Conversation

	err := pool.QueryRow(context.Background(), `
		SELECT * FROM ls.conversation WHERE id=$1 RETURNING id;
	`, conversationId).Scan(&responseConversation.ID)
	if err != nil {
		log.Fatalf("Unable to get conversation: %v\n", err)
		return Conversation{}, err
	}

	return responseConversation, nil
}

func CreateConversation() (Conversation, error) {
	var responseConversation Conversation

	err := pool.QueryRow(context.Background(), `
		INSERT INTO ls.conversation (id) VALUES ($1) RETURNING id;
	`, uuid.NewString()).Scan(&responseConversation.ID)

	if err != nil {
		log.Fatalf("Unable to scan conversation: %v\n", err)
		return Conversation{}, err
	}

	return responseConversation, nil
}

func GetMessagesByConversationID(conversationId string) ([]Message, error) {
	var responseMessages []Message

	rows, err := pool.Query(context.Background(), `
		SELECT * FROM ls.message WHERE conversation_id=$1;
	`, conversationId)
	if err != nil {
		log.Fatalf("Unable to get conversation: %v\n", err)
		return []Message{}, err
	}

	defer rows.Close()

	for rows.Next() {
		var message Message
		err = rows.Scan(&message.ID, &message.ConversationId, &message.Message, &message.Participant, &message.CreatedAt, &message.UpdatedAt)
		if err != nil {
			return []Message{}, err
		}
		responseMessages = append(responseMessages, message)
	}

	return responseMessages, nil
}

func CreateMessage(message Message) (Message, error) {
	var responseMessage Message

	err := pool.QueryRow(context.Background(), `
		INSERT INTO ls.message (
			id,
			conversation_id,
			chat_message,
			participant
		) VALUES ($1, $2, $3, $4)
		RETURNING id, conversation_id, chat_message, participant;
	`, uuid.NewString(), message.ConversationId, message.Message, message.Participant).Scan(
		&responseMessage.ID, &responseMessage.ConversationId, &responseMessage.Message, &responseMessage.Participant,
	)

	if err != nil {
		log.Fatalf("Unable to insert message: %v\n", err)
		return Message{}, err
	}

	return responseMessage, nil
}
