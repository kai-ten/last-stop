import React, { useState, useEffect, useRef, SyntheticEvent } from "react";

interface Message {
  participant: "user" | "assistant";
  message: string;
}

function Chat() {
  const [messages, setMessages] = useState<Message[]>([]);
  const [input, setInput] = useState("");
  const API_ENDPOINT = process.env.REACT_APP_API_ENDPOINT || "http://localhost:8080/2015-03-31/functions/function/invocations";

  const sendMessage = (message: Message) => {
    const response = fetch(API_ENDPOINT, {
      method: "POST",
      headers: {
        "Content-Type": "application/json"
      },
      mode: "cors",
      body: JSON.stringify(messages)
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

  const handleSubmit = (e: React.SyntheticEvent) => {
    e.preventDefault();

    if (!input.trim()) return;
    setMessages((prev) => [...prev, { participant: "user", message: input }]);
    setInput("");
  };

  const handleEnterSubmit = (e: React.KeyboardEvent) => {
    e.preventDefault();

    if (e.code === 'Enter') {
      if (!input.trim()) return;
      setMessages((prev) => [...prev, { participant: "user", message: input }]);
      setInput("");
    }
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
    <div className="w-full h-full flex flex-col">
      <div className="flex h-full flex-col overflow-y-scroll">
        <div className="p-1 px-16">
          {messages.map((message, index) => (
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