# AWS DevOps Sample API

This repository contains a minimal Express API that is intentionally small so you can focus on practicing the AWS Git (e.g., GitHub) → CodeBuild → ECR → CodePipeline → Lambda pipeline.

## Project structure

```
.
├── Dockerfile            # Container image used by CodeBuild & Lambda container
├── buildspec.yml         # CodeBuild instructions
├── lambda.env.sample     # Template for Lambda container environment variables
├── package.json          # Node.js dependencies and scripts
├── src                   # Express application source code
│   ├── app.js            # Routes
│   └── server.js         # HTTP server bootstrap
└── tests                 # Jest + Supertest specs
```

## Run locally

1. Install dependencies: `npm install`
2. Start the API: `npm start`
3. Hit the endpoints:
   - `GET http://localhost:3000/health` → `{ "status": "ok" }`
   - `POST http://localhost:3000/echo` with any JSON body to get it back
4. Run tests anytime with `npm test`
5. Use `cp lambda.env.sample .env` if you want to provide local environment variables (optional).

## How it fits the AWS pipeline

- **Git (Source)**: Push this repo to GitHub (or any Git provider). Configure CodePipeline's source stage to pull from that repository/branch.
- **CodeBuild (Build + Test)**: CodePipeline triggers CodeBuild with the included `buildspec.yml`. CodeBuild installs Node.js dependencies, runs Jest tests, logs into Amazon ECR, builds the Docker image, tags it with `$IMAGE_TAG`, and pushes it to your ECR repository.
- **ECR (Store Docker Image)**: The pushed image becomes the source artifact for downstream stages. Update the environment variables at the top of `buildspec.yml` with your AWS account ID, region, repo name, and tag strategy.
- **CodePipeline (Orchestrate)**: Create a pipeline with your Git provider as the source, CodeBuild as the build stage, and a deploy stage targeting Lambda.
- **Lambda (Deploy)**: Configure Lambda to use the container image stored in ECR. The handler just needs the exposed port, so set environment variables similar to `lambda.env.sample` (e.g., `PORT=3000`, `ENV=dev`). Lambda will invoke the container and route requests to port 3000.
- **CloudWatch (Monitoring)**: Lambda sends logs to CloudWatch automatically. You can also add custom logs inside the Express handlers or enable metrics/alarms on invocation errors.

Because the API is intentionally tiny, you can iterate quickly on pipeline concepts (approvals, automated tests, deployment to multiple environments) without incurring more than AWS Free Tier costs.
