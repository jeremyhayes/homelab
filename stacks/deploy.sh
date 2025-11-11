#!/bin/bash

SCRIPT_DIR=$(dirname -- "$0")
STACK=$(basename $(realpath -s "$1"))

if [ -z $STACK ]; then
  echo "Must provide service directory name"
  echo "Usage: ./deploy.sh <stack>"
  exit 1
fi

NETWORK="web-proxy"
echo "Deploying overlay network $NETWORK..."
docker network create --driver overlay $NETWORK

echo "Deploying stack $STACK..."
docker stack deploy -c "$SCRIPT_DIR/$STACK/stack.yaml" $STACK
