#!/usr/bin/env bash
set -euo pipefail

for i in $(seq 1 15); do
  if curl -fsS "http://localhost:8080/generate_204" >/dev/null 2>&1; then
    echo "derper is up"
    docker logs derper-smoke
    docker rm -f derper-smoke >/dev/null
    exit 0
  fi
  sleep 2
done

echo "derper did not become healthy in time"
docker logs derper-smoke || true
docker rm -f derper-smoke >/dev/null || true
exit 1
