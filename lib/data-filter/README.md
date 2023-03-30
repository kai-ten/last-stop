# GPT-3 Chat Completion Prompt Service

The Data Filter is the first step of processing. The data is stored in an audit log to then be checked for potential DLP scenarios.

<br />

## Code / Build Requirements

- Docker
- Golang
- In order to run locally, must have the ddb table built and be connected to AWS CLI

<br />

## Running locally:

1. Build the Prompt Service docker container:
    ```
    docker build . -t data-filter
    ```

1. Run the docker container as described below, be sure to pass in your OpenAPI API Key (from platform.openapi.com):
    ```
    docker run -p 8080:8080 data-filter /main
    ```

1. Execute the curl command to test the lambda and 
    ```
    curl -XPOST -H "Content-Type: application/json" "http://localhost:8080/2015-03-31/functions/function/invocations" -d @./assets/request.json
    ```

<br />

## Testing locally:

1. Run `go test -v` in the terminal

<br />

## Planned Targets for further analysis:

- DynamoDB (default)
- More to come with flags to pick and choose which target to store audit logs to

Interested in seeing specific targets? Please create an issue.

<br />

## Roadmap:

