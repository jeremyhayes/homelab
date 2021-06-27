#!/bin/sh

# load .env
SCRIPT=$(readlink -f "$0")
SCRIPT_PATH=$(dirname "$SCRIPT")
export $(grep -v '^#' "$SCRIPT_PATH/.env" | xargs -d '\n')

# run image to reboot modem
IMAGE='motorola-mb8600-reboot:latest'
docker run --rm $IMAGE -s --url $MODEM_ADDRESS -u $MODEM_USERNAME -p $MODEM_PASSWORD
