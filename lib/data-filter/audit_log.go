package main

import (
	"time"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/dynamodb"
	"github.com/aws/aws-sdk-go/service/dynamodb/dynamodbattribute"
	"github.com/google/uuid"
)

func storeConversationAuditLog(conversation Conversation) (string, error) {
	sess, err := session.NewSession(&aws.Config{
		Region: aws.String("us-east-2"),
	})
	if err != nil {
		return "", err
	}

	svc := dynamodb.New(sess)
	conversation.Timestamp = time.Now().Unix()
	conversation.ID = uuid.New().String()

	av, err := dynamodbattribute.MarshalMap(conversation)
	if err != nil {
		return "", err
	}

	input := &dynamodb.PutItemInput{
		Item:      av,
		TableName: aws.String("AuditLog"),
	}

	_, err = svc.PutItem(input)
	if err != nil {
		return "", err
	}
	return conversation.ID, nil
}
