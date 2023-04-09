import { Conversation } from "../models/Conversation";
import { Message } from "../models/Message";
// import { createApi, fetchBaseQuery } from '@reduxjs/toolkit/query/react';
import { createApi, fetchBaseQuery } from '@reduxjs/toolkit/query/react'

const API_ENDPOINT = process.env.REACT_APP_API_ENDPOINT || "http://localhost:8081";

export const conversationApi = createApi({
  reducerPath: 'conversationApi',
  baseQuery: fetchBaseQuery({ 
    baseUrl: API_ENDPOINT,
    mode: "cors",
    headers: {
      'Content-Type': 'application/json; charset=UTF-8',
    },
  }),
  tagTypes: ['Conversation'],
  endpoints: (builder) => ({
// init 
// getAllConversations
// GET /conversations (behind the scenes using session/tokens to get convs for specific user)
// selects a conversation
// GET /conversations/:id - and maybe because these are under /conversations its all managed via conversations (object/list) in state store
// OR creates a conversation
// POST /conversations - should skip store and make api call, no data should be stored locally until res is back
// send message
// POST /conversation/:id/messages - body in req
// POST /conversation/:id/user/messages 
// POST /conversation/:id/${llm}/messages 
//      - server will make openai api call and return (user msg? chat response?, both?)
//      - response should only alter current state of conversation (append msg to existing state)
// 

// Create conversation
// Persist user message and get Conversation response
// Query ChatGPT and get Conversation response

// https://www.mitrais.com/news-updates/the-easy-way-to-use-redux-toolkit-in-react/
    getConversation: builder.mutation({
      query: () => ({
        url: '/api/v1/chatgpt3cc/conversation',
        method: 'GET',
        // body: payload,
      }),
      invalidatesTags: ['Conversation'],
    }),
    newConversation: builder.mutation<Conversation, { id: string; messages: Partial<Message[]>; userId: string }>({
      query: () => ({
        url: '/api/v1/chatgpt3cc/conversation',
        method: 'POST',
        // body: payload,
      }),

      invalidatesTags: ['Conversation'],
    }),
    newUserMessage: builder.mutation({
      query: (payload: Message) => ({
        url: '/api/v1/chatgpt3cc/user-message',
        method: 'PATCH',
        body: payload,
      }),
      invalidatesTags: ['Conversation'],
    }),                                   // ResultType
    newAssistantMessage: builder.mutation({
      query: (payload: Message) => ({
        url: '/api/v1/chatgpt3cc/assistant-message',
        method: 'PATCH',
        body: payload,
      }),
      invalidatesTags: ['Conversation'],
    }),
  }),
});

export const { useNewConversationMutation, useNewUserMessageMutation, useNewAssistantMessageMutation } = conversationApi;



// const parseConversation = async (response: Response) => {
//   return await response.json() as Conversation
// }

// const parseConversations = async (response: Response) => {
//   return await response.json() as Conversation[]
// }

// const parseMessage = async (response: Response) => {
//   return await response.json() as Message
// }

// export const newConversation = async (message: Message) => {
//   const response = await fetch(`${API_ENDPOINT}/api/v1/chatgpt3cc/conversation`, {
//     method: "POST",
//     headers: { 
//       "Content-Type": "application/json",
//     },
//     mode: "cors",
//     body: JSON.stringify(message)
//   })

//   return parseConversation(response);
// };

// export const newUserMessage = async (message: Message) => {
//   const response = await fetch(`${API_ENDPOINT}/api/v1/chatgpt3cc/user-message`, {
//     method: "POST",
//     headers: { 
//       "Content-Type": "application/json",
//     },
//     mode: "cors",
//     body: JSON.stringify(message)
//   });

//   return parseMessage(response)
// };

// export const newAssistantMessage = async (message: Message) => {
//   const response = await fetch(`${API_ENDPOINT}/api/v1/chatgpt3cc/assistant-message`, {
//     method: "POST",
//     headers: {
//       "Content-Type": "application/json",
//     },
//     mode: "cors",
//     body: JSON.stringify(message)
//   });

//   return parseMessage(response)
// };

// export const newConversation = async () => {
//   const response = fetch(`${API_ENDPOINT}/conversation/new`, { method: "GET" });
//   return response.then(res => parseConversation(res));
// }

// export const getAllConversations = async () => {
//   const response = fetch(`${API_ENDPOINT}/conversations`, { method: "GET"});
//   return response.then(res => parseConversations(res));
// }