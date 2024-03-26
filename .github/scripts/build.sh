#!/bin/bash

COMMIT_SHA=${GITHUB_SHA:-$(git rev-parse HEAD)}
IMAGE_TAG=$COMMIT_SHA

docker build . \
  --tag test-image:$IMAGE_TAG \
  --file Dockerfile \
#   --build-arg SYSTEM_ACCESSTOKEN=$SYSTEM_ACCESSTOKEN \
  --progress=plain \
  --no-cache