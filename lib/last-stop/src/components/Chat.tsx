import React, { useState, useEffect } from "react";
import { Message } from "../models/Message";
import { useNewConversationMutation, useNewUserMessageMutation, useNewAssistantMessageMutation } from "../services/ConversationAPI";
import ConversationList from "./ConversationList";
import { Conversation } from "../models/Conversation";


function Chat() {

  const [newConversation, conversation] = useNewConversationMutation();
  const [newUserMessage, userMessage] = useNewUserMessageMutation();
  const [newAssistantMessage, assistantMessage] = useNewAssistantMessageMutation();
  
  const [input, setInput] = useState("");

  const [conv, setConversation] = useState<Conversation>({id: "", messages: [], userId: ""});

  const handleSubmit = (e: React.SyntheticEvent) => {
    e.preventDefault();

    if (!input) return;
    sendMessage({ message: input.trim() })
    setInput("");
  };

  const handleEnterSubmit = (e: React.KeyboardEvent) => {
    if (e.code === 'Enter') {
      e.preventDefault();
      if (!input) return;
      sendMessage({ message: input.trim() })
      setInput("");
    }
  };

  const sendMessage = async (msg: Message) => {
    console.log(msg)
    if (!conv?.id) {
      let conversation: Conversation = await newConversation({id: "", messages: [], userId: ""}).unwrap()
      msg.conversationId = conversation.id
      conversation = await newUserMessage(msg).unwrap();
      setConversation(conversation)
      setTimeout(() => {}, 1000);
      conversation = await newAssistantMessage(msg).unwrap();
      setConversation(conversation)
    } else {
      msg.conversationId = conv.id;
      let s = await newUserMessage(msg).unwrap();
      setConversation(s)
      setTimeout(() => {}, 1000);
      s = await newAssistantMessage(msg).unwrap();
      setConversation(s)
    }
  }

  return (
    <div className="w-full h-full flex flex-col">
      <div className="flex h-full flex-col overflow-y-scroll">
        <div className="p-1 px-16">
        {conv?.messages?.map((message, index) => (
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
          onKeyPress={handleEnterSubmit}
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