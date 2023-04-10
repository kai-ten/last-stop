export interface Message {
    id?: string;
    participant?: "user" | "assistant";
    chat_message?: string;
    conversation_id?: string;
    created_at?: Date;
    updated_at?: Date;
}
