#!/bin/bash

AUTHENTIK_TOKEN=$(cat ./.secret.authentik-token)
docker run \
  --rm \
  --user $(id -u):$(id -g) \
  --workdir=/srv/workspace \
  --mount type=bind,source=.,target=/srv/workspace \
  --mount type=bind,source=/opt/apps/terraform,target=/opt/apps/terraform \
  --env AUTHENTIK_TOKEN=$AUTHENTIK_TOKEN \
  --interactive \
  --tty \
  ghcr.io/opentofu/opentofu:1.7.2 \
  "$@"
