#!/bin/sh

SCRIPT_DIR=$(dirname -- "$0")
STACK_NAME=lab

SERVICE_DIR="$1"
if [ -z $SERVICE_DIR ]; then
  echo "Must provide service directory name"
  echo "Usage: ./deploy.sh <directory>"
  exit 1
fi

echo "Deploying service $SERVICE_DIR to $STACK_NAME..."
docker stack deploy -c "$SERVICE_DIR/docker-compose.yml" $STACK_NAME
