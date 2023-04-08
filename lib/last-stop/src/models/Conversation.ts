import { Message } from "./Message";

export interface Conversation {
    id: string;
    messages: Message[];
    userId: string;
}

export interface ConversationState {
    currentConversation: Conversation,
    allConversations: Conversation[]
}