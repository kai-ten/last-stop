export interface Message {
    id?: string;
    participant?: "user" | "assistant";
    message: string;
    timestamp?: number;
    conversationId?: string;
}