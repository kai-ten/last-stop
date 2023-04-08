package main

import (
	"errors"
	"testing"
	"time"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/service/dynamodb"
	"github.com/aws/aws-sdk-go/service/dynamodb/dynamodbattribute"
	"github.com/aws/aws-sdk-go/service/dynamodb/dynamodbiface"
	"github.com/google/uuid"
)

type MockDynamoDBClient struct {
	dynamodbiface.DynamoDBAPI
	err error
}

func (client *MockDynamoDBClient) PutItem(input *dynamodb.PutItemInput) (*dynamodb.PutItemOutput, error) {
	if client.err != nil {
		return nil, client.err
	}
	return &dynamodb.PutItemOutput{}, nil
}

func TestSaveMessage(t *testing.T) {
	conv := Message{
		Participant: "user",
		Message:     "Hello!",
	}

	t.Run("Successful store", func(t *testing.T) {
		ddb := &MockDynamoDBClient{}
		lastMessage, err := SaveMessageWithClient(conv, ddb)
		if err != nil {
			t.Errorf("Expected no error, got %v", err)
		}
		if lastMessage == (Message{}) {
			t.Error("Expected a valid ID, got an empty string")
		}
		if lastMessage.ID == "" {
			t.Error("Expected a non-empty ID, got an empty string")
		} else {
			t.Log("Success - ID matches")
		}
	})

	t.Run("Failed store", func(t *testing.T) {
		ddb := &MockDynamoDBClient{err: errors.New("put item error")}
		_, err := SaveMessageWithClient(conv, ddb)
		if err == nil {
			t.Error("Expected an error, got nil")
		}
	})
}

func SaveMessageWithClient(message Message, ddb dynamodbiface.DynamoDBAPI) (Message, error) {
	message.Timestamp = time.Now().Unix()
	message.ID = uuid.NewString()

	msg_map, err := dynamodbattribute.MarshalMap(message)
	if err != nil {
		return Message{}, err
	}

	input := &dynamodb.PutItemInput{
		Item:      msg_map,
		TableName: aws.String("LastStopAuditLog"),
	}

	_, err = ddb.PutItem(input)
	if err != nil {
		return Message{}, err
	}
	return message, nil
}
