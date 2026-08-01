#!/bin/bash

SCRIPT_DIR=$(dirname -- "$0")

echo "Deploying all stacks..."
find . -mindepth 1 -maxdepth 1 -type d -print0 | xargs -0 -n 1 ./deploy.sh
