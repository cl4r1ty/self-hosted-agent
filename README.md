# self-hosted-agent
An nginx container that hosts the sourceclear agent internally at a designated url


## Steps to build & run

1. ./download-local.sh

2. docker build -t CONTAINER_NAME .

3. docker run -p 80:80 -e INTERNAL_URL=https://someurl.com CONTAINER_NAME

Note: You'll probably want to rebuild this and re-deploy it daily to keep updated.

## Using the internally hosted image

- curl -sSL https://someurl.com/ci.sh | bash

Note: ci.sh is rewritten when the docker image above is run using the passed in env var as the location to check for the latest version and download the agent.
