import { createContext, useContext, useReducer, useState } from "react";
import { Conversation, ConversationState } from "../models/Conversation";
import { Action } from "../models/Action";

const initalConversationState: ConversationState = {
  currentConversation: {id: '', userId: '', messages: []} as Conversation,
  allConversations: [] as Conversation[]
}
const ConversationDispatchContext = createContext<React.Dispatch<Action>>(() => {});
const ConversationContext = createContext<ConversationState>(initalConversationState);

export function ConversationProvider({ children }: any) {

  const [conversationState, dispatch] = useReducer<React.Reducer<ConversationState, Action>>(conversationReducer, initalConversationState);

  return (
    <ConversationContext.Provider value={conversationState}>
      <ConversationDispatchContext.Provider value={dispatch}>
        {children}
      </ConversationDispatchContext.Provider>
    </ConversationContext.Provider>
  );
}


export const useConversationState = () => {
  return useContext(ConversationContext)
}

// Allow child components to utilize dispatcher
export const useConversationDispatch = () => {
  return useContext(ConversationDispatchContext);
}

function conversationReducer(state: ConversationState, action: Action): ConversationState {
  console.log("ConversationReducer State (before): ", JSON.stringify(state));
  console.log("ConversationReducer Action: (before)", JSON.stringify(action));
  switch (action.type) {
    
    case 'newConversation': {
      console.log("------------------------------------------------------------")
      console.log("newConversation")
      console.log(action.payload)
      const newState = {
        allConversations: [...state.allConversations, action.payload as Conversation], 
        currentConversation: action.payload as Conversation
      }
      console.log("ConversationReducer State (after): ", JSON.stringify(newState));
      console.log("------------------------------------------------------------")
      return newState
    }

    case 'updateConversation': {
      console.log("------------------------------------------------------------")
      console.log("updateConversation")

      // Find index of conversation in allConversationsToEdit
      let newAll = state.allConversations.map((c: Conversation) => {
        if (c.id == (action.payload as Conversation).id) {
          console.log("ALLCONV - FOUND CONV TO UPDATE")
          c.messages = (action.payload as Conversation).messages
          return c
        }
        else {
          return c
        }
      });

      let found = false

      state.currentConversation.messages
        .find(msg => {
          if (msg.id == (action.payload as Conversation).messages[0].id) {
            found = true
          } 
          found = false;
        })

        let newCurrentCovo;

        if (!found) {
          newCurrentCovo = {
            ...state.currentConversation,
            messages: [...state.currentConversation.messages, (action.payload as Conversation).messages[0]]
          }
        } else {
          console.log("HIT THE ELSE SOMEHOW")
          newCurrentCovo = state.currentConversation
        }


          
          // msg.id == (action.payload as Conversation).id);


    

      // if (state.currentConversation.id === (action.payload as Conversation).id) {
      //   console.log("CURRENTCONV - FOUND CURR CONV TO UPDATE")
      //   state.currentConversation.messages = (action.payload as Conversation).messages;
      // }     
       const newState = {
        allConversations: newAll, 
        currentConversation: newCurrentCovo
      }

      console.log("ConversationReducer State (after): ", JSON.stringify(newState));
      console.log("------------------------------------------------------------")
      return newState;
    }

    // case 'onLoadConversations'
    // We want to send an API request to register another conversation
    // We should switch the Chats conversation to the newly created conversation

    // case 'startConversation': {
    //   return { state.allConversations, action.payload }
    // }

    // User has clicked on a different conversation in the Navbar component
    // The current conversation should switch to the chosen conversation
    // Chat should have the current conversation and its messages
    // All new messages should be directed to the current conversation
    // case 'changeConversation': {

      // must use the id of the conversation passed in, and set conversationState.currentConversation

    //   return state.allConversations.map((c: Conversation) => {
    //     if (Array.isArray(action.payload)) { // Check if payload is an array
    //       const foundConversation = (action.payload as Conversation[]).find(conv => conv.id === c.id); // Find the matching conversation
    //       if (foundConversation) {
    //         return { ...c, ...foundConversation };
    //       }
    //     }
    //     return c;
    //   });
    // }
    
    // TBD: Icon on the navbar to delete? 
    // Click on conversation and on chat window maybe there is a delete? 
    // Maybe no deleting function at all? Could get clutterd as a result

    // case 'deleteConversation': {
    //   return state.allConversations.map((c: Conversation) => {
    //     // Iterate over array and remove
    //     // Set Conversation to { id: "", messages: [] } if it is the current conversation
    //   })
    // }

    // For whatever conversatiom the user is in
    // When a message is sent as input
    // The corresponding conversations messages should be updated
    // TBD: what to do with the reploy of a user message from LLM

    // case 'handleSendMessage': {
    //   return state.allConversations.map((c: Conversation) => {
    //     if (Array.isArray(action.payload)) { // Check if payload is an array
    //       const foundConversation = (action.payload as Conversation[]).find(conv => conv.id === c.id); // Find the matching conversation
    //       if (foundConversation) {
    //         return { ...c, ...foundConversation };
    //       }
    //     } else if (action.payload as Conversation && c.id === action.payload.id) {
    //       return { ...c, messages: [...c.messages, action.payload] }
    //     }
    //     return c;
    //   })
    // }
    default: {
      throw Error('Unknown action: ' + action.type);
    }
  }
}