import React, { useState, useEffect } from "react";
import { useConversationDispatch, useConversationState } from "../contexts/ConversationContext";
import { Message } from "../models/Message";
import { newConversation, newUserMessage, newAssistantMessage } from "../services/ConversationAPI";
import { Conversation } from "../models/Conversation";


function Chat() {

  const conversationDispatch = useConversationDispatch();
  const state = useConversationState();
  const [input, setInput] = useState("");

  const handleSubmit = (e: React.SyntheticEvent) => {
    e.preventDefault();

    // let message: Message = { message: input, participant: "user" }
    if (!input) return;
    sendMessage({ message: input.trim() })
    setInput("");
  };

  const handleEnterSubmit = (e: React.KeyboardEvent) => {
    e.preventDefault();

    if (e.code === 'Enter') {
      if (!input) return;
      sendMessage({ message: input.trim() })
      setInput("");
    }
  };

  const handleDispatch = async (msg: Message) => {

    msg.conversationId = state.currentConversation.id
    console.log("In handle dispatch");
    console.log(state.currentConversation.messages)

    console.log(msg)

    conversationDispatch({
      type: "updateConversation",
      payload: {
        id: state.currentConversation.id,
        messages: [...state.currentConversation.messages, msg],
        userId: state.currentConversation.userId
      } as Conversation
    })
  }

  const sendMessage = async (msg: Message) => {
    if (!state.currentConversation?.id) {
      console.log("Sending message: (no currentConversation): ")

      let conv: Conversation = await newConversation(msg);
      conversationDispatch({
        type: "newConversation",
        payload: conv
      });

      msg.conversationId = conv.id
      let userMsg: Message = await newUserMessage(msg);
      conversationDispatch({
        type: "updateConversation",
        payload: {
          id: conv.id,
          messages: [userMsg],
          userId: conv.userId
        } as Conversation
      });

      let assistantMsg: Message = await newAssistantMessage(msg);
      conversationDispatch({
        type: "updateConversation",
        payload: {
          id: conv.id,
          messages: [assistantMsg],
          userId: conv.userId
        } as Conversation
      });

    } else {
      // console.log("sendMessage: We have an existing coversation")
      // msg.conversationId = state.currentConversation.id
      // let userMsg: Message = await newUserMessage(msg);
      // conversationDispatch({
      //   type: "updateConversation",
      //   payload: {
      //     id: state.currentConversation.id,
      //     messages: [userMsg],
      //     userId: state.currentConversation.userId
      //   } as Conversation
      // });

      // let assistantMsg: Message = await newAssistantMessage(msg);
      // conversationDispatch({
      //   type: "updateConversation",
      //   payload: {
      //     id: state.currentConversation.id,
      //     messages: [assistantMsg],
      //     userId: state.currentConversation.userId
      //   } as Conversation
      // });
    }
  }
  
  return (
    <div className="w-full h-full flex flex-col">
      <div className="flex h-full flex-col overflow-y-scroll">
        <div className="p-1 px-16">
        {state.currentConversation?.messages?.map((message, index) => (
            // Message cards
            <div
              key={index}
              className={`w-full my-4
                rounded-lg p-4 whitespace-normal ${
                message.participant === "user"
                  ? "bg-gray-200 text-gray-900 self-end"
                  : "bg-gray-300 text-gray-900 self-start"
              }`}
            >
              <div key={index} className="whitespace-pre-wrap">{message.message}</div>
            </div>
          ))}
          <div className="w-full h-20 flex-shrink-0"></div>
        </div>
      </div>
      <div className="w-full">
        <form
          onSubmit={handleSubmit}
          onKeyUp={handleEnterSubmit}
          className="stretch flex flex-row gap-3 justify-center p-4 bg-gray-300 border-3"
        >
          <textarea
            value={input}
            onChange={(e) => setInput(e.target.value)}
            placeholder="Enter your message here..."
            rows={4}
            className="flex-grow px-4 py-2 mr-2 bg-white rounded-lg shadow-md focus:outline-none"
          />
          <button
            type="submit"
            className="my-10 px-4 py-2 bg-tertiary text-white rounded-lg shadow-md focus:outline-none"
          >
            Send
          </button>
        </form>
      </div>
    </div>
  );
};

export default Chat;