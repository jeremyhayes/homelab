#!/bin/bash

AUTHENTIK_TOKEN=$(cat ./.secret.authentik-token)
docker run \
  --rm \
  --user $(id -u):$(id -g) \
  --workdir=/srv/workspace \
  --mount type=bind,source=.,target=/srv/workspace \
  --env AUTHENTIK_TOKEN=$AUTHENTIK_TOKEN \
  ghcr.io/opentofu/opentofu:1.7.2 \
  "$@"
