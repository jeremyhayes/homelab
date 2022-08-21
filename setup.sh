#!/bin/sh

# set label for node architecture
ARCH=$(docker info -f '{{.Architecture}}')
NODE_ID=$(docker node inspect self -f '{{.ID}}')
docker node update --label-add arch="$ARCH" "$NODE_ID"
