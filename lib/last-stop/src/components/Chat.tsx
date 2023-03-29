import React, { useState, useEffect, useRef } from "react";

interface Message {
  participant: "user" | "assistant";
  message: string;
}

function Chat() {
  const [messages, setMessages] = useState<Message[]>([]);
  const [input, setInput] = useState("");
  const API_ENDPOINT = "http://localhost:8080/2015-03-31/functions/function/invocations"

  const sendMessage = (message: Message) => {
    console.log(message)
    const response = fetch(API_ENDPOINT, {
      method: "POST",
      headers: {
        "Content-Type": "application/json"
      },
      mode: "cors",
      body: JSON.stringify({
        "resource": "/",
        "path": "/",
        "httpMethod": "GET",
        "requestContext": {
          "accountId": "123456789012",
          "apiId": "id",
          "authorizer": {
            "claims": null,
            "scopes": null
          },
          "domainName": "id.execute-api.us-east-1.amazonaws.com",
          "domainPrefix": "id",
          "extendedRequestId": "request-id",
          "httpMethod": "GET",
          "identity": {
            "accessKey": null,
            "accountId": null,
            "caller": null,
            "cognitoAuthenticationProvider": null,
            "cognitoAuthenticationType": null,
            "cognitoIdentityId": null,
            "cognitoIdentityPoolId": null,
            "principalOrgId": null,
            "sourceIp": "IP",
            "user": null,
            "userAgent": "user-agent",
            "userArn": null,
            "clientCert": {
              "clientCertPem": "CERT_CONTENT",
              "subjectDN": "www.example.com",
              "issuerDN": "Example issuer",
              "serialNumber": "a1:a1:a1:a1:a1:a1:a1:a1:a1:a1:a1:a1:a1:a1:a1:a1",
              "validity": {
                "notBefore": "May 28 12:30:02 2019 GMT",
                "notAfter": "Aug  5 09:36:04 2021 GMT"
              }
            }
          },
          "path": "/",
          "protocol": "HTTP/1.1",
          "requestId": "id=",
          "requestTime": "04/Mar/2020:19:15:17 +0000",
          "requestTimeEpoch": 1583349317135,
          "resourceId": null,
          "resourcePath": "/",
          "stage": "$default"
        },
        "pathParameters": null,
        "stageVariables": null,
        "body": JSON.stringify(messages),
        "isBase64Encoded": false
      })
    })
    .then(response => {
      response.json().then(data => {
        // Set the assistant's response message
        setMessages((msgs) => [...msgs, 
          { 
            participant: "assistant",
            message: data.body 
          }
        ]);
      })
      .catch(err => {
        console.log(err);
      })
    })
    .catch(err => {
      console.log(err)
    })
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!input.trim()) return;
    setMessages((prev) => [...prev, { participant: "user", message: input }]);
    setInput("");
  };

  useEffect(() => {
    if (messages.length === 0) {
      return;
    }
    
    const lastMessage = messages[messages.length - 1];
    if (lastMessage.participant === "user") {
      sendMessage(lastMessage);
    }
  }, [messages]);

  return (
    <div className="flex flex-col h-screen">
      <div className="flex-grow p-4 space-y-4">
        {messages.map((message, index) => (
          <div
            key={index}
            className={`w-full 
              rounded-lg p-4 whitespace-normal ${
              message.participant === "user"
                ? "bg-gray-200 text-gray-900 self-end"
                : "bg-gray-300 text-gray-900 self-start"
            }`}
          >
            <div className="whitespace-pre-wrap">{message.message}</div>
          </div>
        ))}
      </div>
      <form
        onSubmit={handleSubmit}
        className="flex items-center justify-center p-4 bg-gray-200"
      >
        <textarea
          value={input}
          onChange={(e) => setInput(e.target.value)}
          className="flex-grow px-4 py-2 mr-2 bg-white rounded-lg shadow-md focus:outline-none"
        />
        <button
          type="submit"
          className="px-4 py-2 bg-tertiary text-white rounded-lg shadow-md focus:outline-none"
        >
          Send
        </button>
      </form>
    </div>
  );
};

export default Chat;