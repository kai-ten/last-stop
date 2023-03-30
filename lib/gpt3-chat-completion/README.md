# GPT-3 Chat Completion Prompt Service

The GPT-3 Chat Completion Prompt Service is a lambda that handles the request from the frontend to the LLM. It is at this point that the data being submitted to the LLM is processed for monitoring and DLP mitigation. It is possible to only enable a "monitor mode", or to stop requests from ever being sent to the LLM.

<br />

## Code / Build Requirements

- Docker
- Golang

## Running locally:

1. Build the Prompt Service docker container: <br />
    ```
    docker build . -t gpt3-cc
    ```

1. Run the docker container as described below, be sure to pass in your OpenAPI API Key (from platform.openapi.com):
    ```
    docker run \
        -e OPENAPI_KEY='your_key_here' \
        -p 8080:8080 gpt3-cc /main
    ```

1. Execute the curl command to test the lambda and 
    ```
    curl -XPOST -H "Content-Type: application/json" "http://localhost:8080/2015-03-31/functions/function/invocations" -d @./assets/request.json
    ```

<br />

## Roadmap:

