import { Conversation } from "../models/Conversation";
import { Message } from "../models/Message";


const API_ENDPOINT = process.env.REACT_APP_API_ENDPOINT || "http://localhost:8081/chatgpt3cc";

const parseConversation = async (response: Response) => {
  return await response.json() as Conversation
}

const parseConversations = async (response: Response) => {
  return await response.json() as Conversation[]
}

const parseMessage = async (response: Response) => {
  return await response.json() as Message
}

export const newConversation = async (message: Message) => {
  const response = await fetch(`${API_ENDPOINT}/api/v1/chatgpt3cc/conversation`, {
    method: "POST",
    headers: { 
      "Content-Type": "application/json",
    },
    mode: "cors",
    body: JSON.stringify(message)
  })

  return parseConversation(response);
};

export const newUserMessage = async (message: Message) => {
  const response = await fetch(`${API_ENDPOINT}/api/v1/chatgpt3cc/user-message`, {
    method: "POST",
    headers: { 
      "Content-Type": "application/json",
    },
    mode: "cors",
    body: JSON.stringify(message)
  });

  return parseMessage(response)
};

export const newAssistantMessage = async (message: Message) => {
  const response = await fetch(`${API_ENDPOINT}/api/v1/chatgpt3cc/assistant-message`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    mode: "cors",
    body: JSON.stringify(message)
  });

  return parseMessage(response)
};

// export const newConversation = async () => {
//   const response = fetch(`${API_ENDPOINT}/conversation/new`, { method: "GET" });
//   return response.then(res => parseConversation(res));
// }

// export const getAllConversations = async () => {
//   const response = fetch(`${API_ENDPOINT}/conversations`, { method: "GET"});
//   return response.then(res => parseConversations(res));
// }