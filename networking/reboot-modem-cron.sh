#!/bin/sh

# load .env
export $(grep -v '^#' .env | xargs -d '\n')

# run image to reboot modem
IMAGE='motorola-mb8600-reboot:latest'
docker run --rm $IMAGE -s --url $MODEM_ADDRESS -u $MODEM_USERNAME -p $MODEM_PASSWORD
