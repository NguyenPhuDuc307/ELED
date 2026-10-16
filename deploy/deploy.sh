#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
host="${ELED_SSH_HOST:-aws-vps}"
release="$(date -u +%Y%m%dT%H%M%SZ)"
remote="/home/ducnp/eled"
npm ci --prefix apps/web
npm run build --prefix apps/web
npm ci --prefix services/api
npm run build --prefix services/api
ssh "$host" "mkdir -p '$remote/releases/$release' '$remote/api'"
COPYFILE_DISABLE=1 tar --no-xattrs --exclude=vocabulary.json -C apps/web/dist -czf - . | ssh "$host" "tar -xzf - -C '$remote/releases/$release'"
COPYFILE_DISABLE=1 tar --no-xattrs -C services/api -czf - Dockerfile package.json package-lock.json tsconfig.json src | ssh "$host" "tar -xzf - -C '$remote/api'"
scp -q apps/web/public/vocabulary.json "$host:$remote/api/vocabulary.json"
scp -q deploy/compose.yaml deploy/nginx.conf "$host:$remote/"
ssh "$host" "set -eu
  cd '$remote'
  docker compose -p eled -f compose.yaml up -d --build --wait --wait-timeout 90 api
  if [ -L releases/current ]; then readlink releases/current > previous-release; fi
  if [ -d releases/current/assets ]; then
    cp -an releases/current/assets/. 'releases/$release/assets/'
  fi
  ln -sfn '$release' releases/current
  docker compose -p eled -f compose.yaml up -d --force-recreate --wait --wait-timeout 90 web
"
printf 'Deployed release %s to https://eled.vnlab.id.vn\n' "$release"
