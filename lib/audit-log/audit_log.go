package main

import (
	"time"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/dynamodb"
	"github.com/aws/aws-sdk-go/service/dynamodb/dynamodbattribute"
	"github.com/google/uuid"
)

func storeConversationAuditLog(conversation Conversation) (Conversation, error) {
	sess, err := session.NewSession(&aws.Config{
		Region: aws.String("us-east-2"),
	})
	if err != nil {
		return Conversation{}, err
	}

	svc := dynamodb.New(sess)
	conversation.Timestamp = time.Now().Unix()
	conversation.ID = uuid.New().String()

	av, err := dynamodbattribute.MarshalMap(conversation)
	if err != nil {
		return Conversation{}, err
	}

	input := &dynamodb.PutItemInput{
		Item:      av,
		TableName: aws.String("LastStopAuditLog"),
	}

	_, err = svc.PutItem(input)
	if err != nil {
		return Conversation{}, err
	}
	return conversation, nil
}
