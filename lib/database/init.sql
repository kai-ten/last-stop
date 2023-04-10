CREATE USER docker;
CREATE DATABASE circulate;
\c circulate
GRANT ALL PRIVILEGES ON DATABASE circulate TO docker;

CREATE SCHEMA IF NOT EXISTS ls;

CREATE TABLE IF NOT EXISTS ls.conversation (
    id TEXT PRIMARY KEY,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);

CREATE TABLE IF NOT EXISTS ls.message (
    id TEXT PRIMARY KEY,
    conversation_id TEXT,
    chat_message TEXT NOT NULL,
    participant TEXT NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT fk_conversation_id
      FOREIGN KEY(conversation_id) 
      REFERENCES ls.conversation(id)
);
