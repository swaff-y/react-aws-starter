#!/bin/bash
set -euo pipefail

echo "=== Environment Info ==="
node --version
npm --version
echo "Stage: ${STAGE:-dev}"
echo "Slice: ${SLICE:-local}"
echo "========================"

# Clean install in CI for reproducibility
if [ "${CI:-false}" = "true" ]; then
  echo "CI environment detected - removing node_modules for clean install"
  rm -rf node_modules
fi

npm ci

echo "=== Building ==="
npm run build 2>&1 | tee build.log
BUILD_EXIT_CODE=${PIPESTATUS[0]}

if [ $BUILD_EXIT_CODE -ne 0 ]; then
  echo "Build failed with exit code $BUILD_EXIT_CODE"
  exit 1
fi

if [ -d "dist" ]; then
  echo "dist/ folder exists"
  ls -la dist/
else
  echo "dist/ folder does not exist - build failed!"
  exit 1
fi

echo "=== Updating serverless config ==="
node scripts/build_serverless.cjs

STAGE=${STAGE:-dev}

if [ "${STAGE}" = "prod" ]; then
  cp serverless.yml serverless-prod.yml
  PACKAGE_NAME="pheonix-prod"
  ZIP_NAME="pheonix-prod.zip"
else
  cp serverless.yml serverless-dev.yml
  PACKAGE_NAME="pheonix-dev"
  ZIP_NAME="pheonix-dev.zip"
fi

echo "=== Packaging with serverless ==="
npx serverless package --package "${PACKAGE_NAME}"

echo "=== Creating artifact: ${ZIP_NAME} ==="
zip -r "${ZIP_NAME}" "${PACKAGE_NAME}" dist/

echo "=== Generated Artifacts ==="
ls -la *.yml *.zip
echo "========================"
