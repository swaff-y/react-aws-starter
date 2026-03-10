#!/bin/bash
set -euo pipefail

STAGE=${STAGE:-dev}
PACKAGE_NAME="pheonix-${STAGE}"
ZIP_NAME="${PACKAGE_NAME}.zip"
SERVERLESS_CONFIG="serverless-${STAGE}.yml"

echo "=== Deployment Info ==="
echo "Stage: ${STAGE}"
echo "Package: ${PACKAGE_NAME}"
echo "Serverless config: ${SERVERLESS_CONFIG}"
echo "======================="

# Download artifacts from build step
buildkite-agent artifact download "${ZIP_NAME}" .
buildkite-agent artifact download "${SERVERLESS_CONFIG}" .

echo "Extracting ${ZIP_NAME}..."
unzip -o "${ZIP_NAME}"

if [ ! -d "dist" ]; then
  echo "Error: dist/ directory does not exist after extraction."
  exit 1
fi

npm ci

echo "=== Deploying with serverless ==="
npx serverless deploy --package "${PACKAGE_NAME}" --config "${SERVERLESS_CONFIG}"

echo "=== Invalidating CloudFront cache ==="
# Extract the CloudFront distribution ID from serverless output
DISTRIBUTION_ID=$(npx serverless info --config "${SERVERLESS_CONFIG}" --verbose 2>/dev/null \
  | grep -i "CloudFrontDistributionId" | awk '{print $NF}' || true)

if [ -n "${DISTRIBUTION_ID}" ]; then
  aws cloudfront create-invalidation \
    --distribution-id "${DISTRIBUTION_ID}" \
    --paths "/*" \
    --profile "${AWS_PROFILE:-dev}" \
    --region "${REGION:-ap-southeast-2}"
  echo "CloudFront cache invalidation created for ${DISTRIBUTION_ID}"
else
  echo "Warning: Could not determine CloudFront distribution ID - skipping cache invalidation"
fi

echo "Deployment completed successfully!"
