#!/bin/bash

docker run \
  --rm \
  --user $(id -u):$(id -g) \
  --workdir=/srv/workspace \
  --mount type=bind,source=.,target=/srv/workspace \
  ghcr.io/opentofu/opentofu:1.7.2 \
  "$@"
