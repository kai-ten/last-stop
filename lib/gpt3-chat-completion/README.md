# GPT-3 Chat Completion Prompt Service

The GPT-3 Chat Completion Prompt Service is a lambda that handles the request from the frontend to the LLM. It is at this point that the data being submitted to the LLM is processed for monitoring and DLP mitigation. It is possible to only enable a "monitor mode", or to stop requests from ever being sent to the LLM.

<br />

## Code / Build Requirements

- Docker
- Golang

## Running locally:

1. Build the Prompt Service docker container: <br />
    ```
    docker build . -t prompt-svc
    ```

1. Run the docker container locally using one of the following methods:
    - With Circulate's ArangoDB running and configured:
        ```
        docker run -p 8080:8080 prompt-svc /main
        ```
    - Print to console (quickest way to test):
        ```
        docker run \
            -e OPENAPI_KEY='add_your_key' \
            -p 8080:8080 prompt-svc /main
        ```

<br />

## Current Targets:

- Circulate Database (TODO)
    ```
    -e ENABLE_ARANGODB='true' \
    -e DB_ENDPOINT="tcp://172.17.0.2:8529" \
    -e ROOT_PASSWORD="password" \
    -e CA_CERT="" \
    ```
- DynamoDB (TODO)
    ```
    -e ENABLE_DYNAMODB='true'
    ```
- Console (TODO)
    ```
    -e ENABLE_CONSOLE_OUTPUT='true' \
    ```

Interested in seeing more targets? Create an issue

<br />

## Roadmap:

