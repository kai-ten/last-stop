import { Message } from "../models/Message";
import { createApi, fetchBaseQuery } from '@reduxjs/toolkit/query/react'

const API_ENDPOINT = process.env.REACT_APP_API_ENDPOINT || "http://localhost:8081";

export const apiSlice = createApi({
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
    getConversations: builder.query({
      query: () => '/api/v1/chatgpt3cc/conversations',
    }),
    getConversation: builder.query({
      query: conversationId => `/api/v1/chatgpt3cc/conversations/${conversationId}`,
    }),
    getMessagesById: builder.query({
      query: conversationId => `/api/v1/chatgpt3cc/messages/${conversationId}`,
    }),
    newConversation: builder.mutation({
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
    }),
    newAssistantMessage: builder.mutation({
      query: (payload: Message) => ({
        url: '/api/v1/chatgpt3cc/assistant-message',
        method: 'PATCH',
        body: payload,
      }),
    }),
  }),
});

export const { 
  useNewConversationMutation, 
  useNewUserMessageMutation, 
  useNewAssistantMessageMutation,
  useGetConversationQuery,
  useGetConversationsQuery
} = apiSlice;
