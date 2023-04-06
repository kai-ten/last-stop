import React, { useState, useEffect } from "react";

interface Message {
  participant?: "user" | "assistant";
  message?: string;
  timestamp?: number;
  conversationId?: string;
}

interface Conversation {
  id?: string;
  messages?: Message[];
  userId?: string;
}

function Chat() {
  // const [messages, setMessages] = useState<Message[]>([]);
  const [conversations, setConversations] = useState<Conversation[]>([{id: "", messages: [], userId: ""}]);
  const [conversation, setConversation] = useState<Conversation>({id: "", messages: [], userId: ""});
  const [input, setInput] = useState("");

  const API_ENDPOINT = process.env.REACT_APP_API_ENDPOINT || "http://localhost:8081/chatgpt3cc";

  const sendMessage = async (message: Message) => {
    try {
      const response = await fetch(`${API_ENDPOINT}/gpt3cc`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json"
        },
        mode: "cors",
        body: JSON.stringify(message)
      });

      const msg = (await response.json()).body as Message
      const currentConvoIdx = conversations.findIndex(c => c.id = msg.conversationId)
      // conversations[currentConvoIdx].messages.push(msg)
      setConversations((convs) => [...convs])
    }
    catch(e) {
      console.log("" + e)
    }
  };

  const startConversation = async () => {
    try {
      const response = await fetch(`${API_ENDPOINT}/conversation`, {
        method: "GET",
        mode: "cors"
      });

      const conv = (await response.json()).body as Conversation
      setConversations((convs) => [...convs, conv])
    }
    catch(e) {
      console.log("" + e)
    }
  }

  const handleSubmit = (e: React.SyntheticEvent) => {
    e.preventDefault();

    let message: Message = { message: input, participant: "user" }
    
    if (!input.trim()) return;
    // setMessages((prev) => [...prev, { participant: "user", message: input }]);
    setConversations(())
    setInput("");
  };

  const handleEnterSubmit = (e: React.KeyboardEvent) => {
    e.preventDefault();

    if (e.code === 'Enter') {
      if (!input.trim()) return;
      // setMessages((prev) => [...prev, { participant: "user", message: input }]);
      setInput("");
    }
  };

  // useEffect(() => {
  //   if (conversations.length() === 0) {
  //     return;
  //   } else {

  //   }
    
  //   const lastMessage = conversations[0]?.messages[conversations[0]?.messages?.length - 1];
  //   if (lastMessage.participant === "user") {
  //     sendMessage(lastMessage);
  //   }
  // }, [conversations[0]?.messages]);
//           {/* {messages.map((message, index) => ( */}
  return (
    <div className="w-full h-full flex flex-col">
      <div className="flex h-full flex-col overflow-y-scroll">
        <div className="p-1 px-16">
        {conversations[0]?.messages?.map((message, index) => (
            // message cards
            <div
              key={index}
              className={`w-full my-4
                rounded-lg p-4 whitespace-normal ${
                message.participant === "user"
                  ? "bg-gray-200 text-gray-900 self-end"
                  : "bg-gray-300 text-gray-900 self-start"
              }`}
            >
              <div className="whitespace-pre-wrap">{message.message}</div>
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