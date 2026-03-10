#!/bin/bash
set -euo pipefail

npm ci
npm run test-deploy
