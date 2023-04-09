import { configureStore } from "@reduxjs/toolkit";
// import conversationReducer from "./ConversationSlice"
import { conversationApi } from "../services/ConversationAPI";

export const conversationStore = configureStore({
    // something wrong with this?
    // https://redux-toolkit.js.org/tutorials/rtk-query

    // looks like API reducer is a wrapper for Slice reducer, 
    // reducer: {
    //     currentConversation: conversationReducer,
    //     conversations: conversationReducer
    // }
    reducer: {
        [conversationApi.reducerPath]: conversationApi.reducer,
        // currentConversation: conversationReducer,
        // conversations: conversationReducer
    },
    middleware: (getDefaultMiddleware) =>
        getDefaultMiddleware().concat(conversationApi.middleware),
});

// setupListeners(conversationStore.dispatch) // optional, but required for refetchOnFocus/refetchOnReconnect behaviors

// export type AppDispatch = typeof conversationStore.dispatch;
// export type RootState = ReturnType<typeof conversationStore.getState>;


