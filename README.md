# React AWS Starter

React + Bootstrap web application deployed via Buildkite CI/CD to AWS (S3 + CloudFront).

## Development

```bash
npm install
npm run dev
```

## CI/CD

Pipeline is managed by Buildkite (`.buildkite/pipeline.yml`):
- **Dev**: Every branch deploys to an isolated "slice" (S3 + CloudFront stack)
- **Prod**: Only `main` branch deploys to production
- **Cleanup**: Manual step to tear down dev slices after merge
