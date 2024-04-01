#!/bin/bash

# Get first 6 characters of commit sha for image tag
COMMIT_SHA=${GITHUB_SHA:-$(git rev-parse HEAD)}
IMAGE_TAG=${COMMIT_SHA:0:6}

# Build web image
docker build . \
  --tag web:$IMAGE_TAG \
  --file Dockerfile \
  --progress=plain \
  --no-cache
