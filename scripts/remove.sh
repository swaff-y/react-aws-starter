#!/bin/bash
set -euo pipefail

SERVERLESS_CONFIG="serverless-dev.yml"

echo "=== Removing stack ==="
echo "Config: ${SERVERLESS_CONFIG}"
echo "======================"

buildkite-agent artifact download "${SERVERLESS_CONFIG}" .

npm ci

npx serverless remove --config "${SERVERLESS_CONFIG}"

echo "Stack removed successfully!"
