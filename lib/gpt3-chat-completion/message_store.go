package main

import (
	"log"
	"os"
	"strconv"
	"time"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/credentials"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/dynamodb"
	"github.com/aws/aws-sdk-go/service/dynamodb/dynamodbattribute"
	"github.com/google/uuid"
)

func CreateTable(ddb *dynamodb.DynamoDB, tableName string) error {
	input := &dynamodb.CreateTableInput{
		AttributeDefinitions: []*dynamodb.AttributeDefinition{
			{
				AttributeName: aws.String("id"),
				AttributeType: aws.String("S"),
			},
		},
		KeySchema: []*dynamodb.KeySchemaElement{
			{
				AttributeName: aws.String("id"),
				KeyType:       aws.String("HASH"),
			},
		},
		BillingMode: aws.String(dynamodb.BillingModePayPerRequest),
		TableName:   aws.String(tableName),
	}

	_, err := ddb.CreateTable(input)
	if err != nil {
		return err
	}

	return nil
}

func TableExist(ddb *dynamodb.DynamoDB, tableName string) bool {
	input := &dynamodb.DescribeTableInput{
		TableName: aws.String(tableName),
	}

	_, err := ddb.DescribeTable(input)

	if err != nil {
		return false
	} else {
		return true
	}
}

func GetDBSession() (*dynamodb.DynamoDB, error) {
	// TODO: dont use static credentials configured here, provider ~/.aws/credentials and session will automatically pull from there
	sess, err := session.NewSession(&aws.Config{
		Endpoint:    aws.String(os.Getenv("ENDPOINT")),
		Region:      aws.String(os.Getenv("REGION")),
		Credentials: credentials.NewStaticCredentials(os.Getenv("AWS_ACCESS_KEY_ID"), os.Getenv("AWS_SECRET_ACCESS_KEY"), ""),
	})
	if err != nil {
		return nil, err
	}
	return dynamodb.New(sess), nil
}

func CreateConversation() (Conversation, error) {
	conv := Conversation{
		ID:     uuid.NewString(),
		UserId: uuid.NewString(),
	}

	conv_map, err := dynamodbattribute.MarshalMap(conv)
	if err != nil {
		return Conversation{}, err
	}

	log.Printf("Dynamo Marshalled Map: %v", conv_map)

	input := &dynamodb.PutItemInput{
		Item:      conv_map,
		TableName: aws.String(os.Getenv("CONVERSATION_TABLE")),
	}

	_, err = ddb.PutItem(input)
	if err != nil {
		log.Printf("Error failed to store conversation: %v", err)
		return Conversation{}, err
	}
	log.Printf("CreatedConversation: %v", conv)
	return conv, nil
}

func GetConversation(conversationId string) (Conversation, error) {
	input := &dynamodb.GetItemInput{
		TableName: aws.String(os.Getenv("CONVERSATION_TABLE")),
		Key: map[string]*dynamodb.AttributeValue{
			"id": {
				S: aws.String(conversationId),
			},
		},
	}

	result, err := ddb.GetItem(input)
	if err != nil {
		log.Fatalf("Failed to get item: %v", err)
	}

	var conversation Conversation
	err = dynamodbattribute.UnmarshalMap(result.Item, &conversation)
	if err != nil {
		log.Fatalf("Failed to unmarshal item: %v", err)
	}

	log.Printf("GetConversation: %v", conversation)
	return conversation, nil
}

func SaveMessage(message Message) (Message, error) {
	message.Timestamp = time.Now().Unix()
	message.ID = uuid.New().String()

	av, err := dynamodbattribute.MarshalMap(message)
	log.Printf("Marshalled dynamo message: %v", av)
	if err != nil {
		return Message{}, err
	}

	input := &dynamodb.PutItemInput{
		Item:      av,
		TableName: aws.String(os.Getenv("MESSAGE_TABLE")),
	}

	_, err = ddb.PutItem(input)
	if err != nil {
		return Message{}, err
	}
	return message, nil
}

func UpdateConversationMessages(conversation Conversation, message Message) (Conversation, error) {
	input := &dynamodb.UpdateItemInput{
		TableName: aws.String(os.Getenv("CONVERSATION_TABLE")),
		Key: map[string]*dynamodb.AttributeValue{
			"id": {
				S: aws.String(conversation.ID),
			},
		},
		UpdateExpression: aws.String("SET #m = list_append(if_not_exists(#m, :empty_list), :vals)"),
		ExpressionAttributeNames: map[string]*string{
			"#m": aws.String("Messages"),
		},
		ExpressionAttributeValues: map[string]*dynamodb.AttributeValue{
			":empty_list": {
				L: []*dynamodb.AttributeValue{},
			},
			":vals": {
				L: []*dynamodb.AttributeValue{
					{
						M: map[string]*dynamodb.AttributeValue{
							"id": {
								S: aws.String(uuid.NewString()),
							},
							"participant": {
								S: aws.String(message.Participant),
							},
							"message": {
								S: aws.String(message.Message),
							},
							"timestamp": {
								N: aws.String(strconv.FormatInt(time.Now().Unix(), 10)),
							},
							"conversationId": {
								S: aws.String(conversation.ID),
							},
						},
					},
				},
			},
		},
		ReturnValues: aws.String("ALL_NEW"),
	}

	output, err := ddb.UpdateItem(input)
	if err != nil {
		log.Printf("Error updating conversation messages: %v", err)
		return Conversation{}, err
	}

	err = dynamodbattribute.UnmarshalMap(output.Attributes, &conversation)
	if err != nil {
		log.Printf("Failed to unmarshal response model: %v", err)
		return Conversation{}, err
	}
	
	return conversation, nil
}
