import { Conversation } from "./Conversation";

export interface Action {
    type: string
    payload: Conversation | Conversation[]
}
