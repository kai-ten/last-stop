package main

import (
	"errors"
	"testing"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/service/dynamodb"
	"github.com/aws/aws-sdk-go/service/dynamodb/dynamodbattribute"
	"github.com/aws/aws-sdk-go/service/dynamodb/dynamodbiface"
)

type mockDynamoDBClient struct {
	dynamodbiface.DynamoDBAPI
	err error
}

func (m *mockDynamoDBClient) PutItem(input *dynamodb.PutItemInput) (*dynamodb.PutItemOutput, error) {
	if m.err != nil {
		return nil, m.err
	}
	return &dynamodb.PutItemOutput{}, nil
}

func TestStoreConversationAuditLog(t *testing.T) {
	conv := Conversation{
		Participant: "user",
		Message:     "Hello!",
	}

	t.Run("Successful store", func(t *testing.T) {
		mockSvc := &mockDynamoDBClient{}
		id, err := storeConversationWithClient(conv, mockSvc)
		if err != nil {
			t.Errorf("Expected no error, got %v", err)
		}
		if id == "" {
			t.Error("Expected a valid ID, got an empty string")
		}
		if id == "test-uuid" {
			t.Log("Success - ID matches")
		}
	})

	t.Run("Failed store", func(t *testing.T) {
		mockSvc := &mockDynamoDBClient{err: errors.New("put item error")}
		_, err := storeConversationWithClient(conv, mockSvc)
		if err == nil {
			t.Error("Expected an error, got nil")
		}
	})
}

func storeConversationWithClient(conversation Conversation, svc dynamodbiface.DynamoDBAPI) (string, error) {
	conversation.Timestamp = 1 // Use a fixed timestamp for testing
	conversation.ID = "test-uuid"

	av, err := dynamodbattribute.MarshalMap(conversation)
	if err != nil {
		return "", err
	}

	input := &dynamodb.PutItemInput{
		Item:      av,
		TableName: aws.String("LastStopAuditLog"),
	}

	_, err = svc.PutItem(input)
	if err != nil {
		return "", err
	}
	return conversation.ID, nil
}
