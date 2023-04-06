package main

import (
	"os"
	"time"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/credentials"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/dynamodb"
	"github.com/aws/aws-sdk-go/service/dynamodb/dynamodbattribute"
	"github.com/google/uuid"
)

func StoreConversationAuditLog(conversation Conversation) (Conversation, error) {
	sess, err := session.NewSession(&aws.Config{
		Region:      aws.String(os.Getenv("REGION")),
		Credentials: credentials.NewStaticCredentials(os.Getenv("ACCESS_KEY"), os.Getenv("SECRET_ACCESS_KEY"), ""),
	})
	if err != nil {
		return Conversation{}, err
	}

	svc := dynamodb.New(sess)
	conversation.Timestamp = time.Now().Unix()
	conversation.ID = uuid.New()

	av, err := dynamodbattribute.MarshalMap(conversation)
	if err != nil {
		return Conversation{}, err
	}

	input := &dynamodb.PutItemInput{
		Item:      av,
		TableName: aws.String(os.Getenv("LOG_TABLE_NAME")),
	}

	_, err = svc.PutItem(input)
	if err != nil {
		return Conversation{}, err
	}
	return conversation, nil
}
