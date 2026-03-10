#!/usr/bin/env node

const fs = require('fs');
const yaml = require('js-yaml');
const path = require('path');

const serverlessFilePath = path.join(__dirname, '../serverless.yml');

// Sanitize slice name: replace non-alphanumeric chars with hyphens, collapse multiple hyphens
function sanitizeSlice(slice) {
  return slice
    .toLowerCase()
    .replace(/[^a-z0-9-]/g, '-')
    .replace(/-+/g, '-')
    .replace(/^-|-$/g, '');
}

try {
  const fileContents = fs.readFileSync(serverlessFilePath, 'utf8');
  const serverlessConfig = yaml.load(fileContents);

  const stage = process.env.STAGE || 'dev';
  const slice = sanitizeSlice(process.env.SLICE || 'local');
  const profile = (process.env.AWS_PROFILE || 'dev').toLowerCase();
  const region = (process.env.REGION || 'ap-southeast-2').toLowerCase();

  serverlessConfig.service = `${serverlessConfig.service}-${stage}-${slice}`;
  serverlessConfig.provider.profile = profile;
  serverlessConfig.provider.region = region;
  serverlessConfig.custom.bucketName = `${serverlessConfig.custom.bucketName}-${stage}-${slice}`;

  fs.writeFileSync(serverlessFilePath, yaml.dump(serverlessConfig));

  console.log(`Updated serverless.yml:`);
  console.log(`  service: ${serverlessConfig.service}`);
  console.log(`  profile: ${profile}`);
  console.log(`  region: ${region}`);
  console.log(`  bucket: ${serverlessConfig.custom.bucketName}`);
} catch (e) {
  console.error('Error reading or parsing serverless.yml:', e);
  process.exit(1);
}
