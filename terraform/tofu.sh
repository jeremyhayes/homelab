#!/bin/bash

docker run \
  --rm \
  --user $(id -u):$(id -g) \
  --workdir=/srv/workspace \
  --mount type=bind,source=.,target=/srv/workspace \
  --mount type=bind,source=/opt/apps/terraform,target=/opt/apps/terraform \
  --env TF_VAR_authentik_token=$(cat ./.secret.authentik-token) \
  --env TF_VAR_grafana_token=$(cat ./.secret.grafana-token) \
  --interactive \
  --tty \
  ghcr.io/opentofu/opentofu:1.7.2 \
  "$@"
