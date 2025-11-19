# DevOps Pipeline Demo

Minimal-yet-professional reference project that demonstrates a complete CI/CD workflow for a TypeScript API running on Amazon EKS. The repository is intentionally small so a university assignment can focus on the infrastructure story (Terraform → CodePipeline → CodeBuild → ECR → EKS → CloudWatch).

## Architecture overview

- **Application** – Express API written in TypeScript with `/health`, `/hello`, and `/users` routes. It is covered by Jest tests and shipped as a non-root Docker image.
- **Infrastructure** – Terraform provisions the networking layer, EKS cluster + node group, ECR repository, IAM roles, CodeBuild projects, CodePipeline, and CloudWatch logging/alarms.
- **Pipeline** – CodePipeline orchestrates Source (GitHub) → Build (CodeBuild verify project) → Package (CodeBuild Docker/ECR project via `buildspec.yml`) → Deploy (CodeBuild kubectl project via `buildspec-deploy.yml`). The Build and Package stages both run in Amazon CodeBuild so every commit is linted, tested, containerized, and rolled out.
- **Kubernetes** – Straightforward namespace/deployment/service manifests that reference the ECR image, include probes, and expose the service via a load balancer.
- **Observability** – CloudWatch log groups capture EKS control plane + CodeBuild logs, while SNS-backed alarms watch for ALB 5xx spikes and high node CPU.

```
.
├── app                     # TypeScript API + Dockerfile + Jest tests
├── infra                   # Terraform IaC grouped by concern
├── k8s                     # Kubernetes namespace/deployment/service
├── buildspec-verify.yml    # CodeBuild stage for lint/test compile
├── buildspec.yml           # CodeBuild stage for Docker build + ECR push
├── buildspec-deploy.yml    # CodeBuild stage for kubectl deploy to EKS
└── README.md               # This guide
```

## Application highlights (`app/`)

- `src/app.ts` wires Express, Helmet, and Morgan plus the three routes.
- `src/routes/*.ts` keep handlers tiny and readable (each returns JSON/text immediately).
- `tests/app.test.ts` uses Supertest to verify the routes; Jest is configured through `ts-jest`.
- `Dockerfile` uses multi-stage builds, installs only production deps in the runtime stage, drops privileges to a non-root user, and defines a `/health` `HEALTHCHECK`.
- `build` script compiles TypeScript to `dist/`, `start` script runs the compiled bundle.

### Running locally

```bash
cd app
npm install
npm run dev      # hot reload via ts-node-dev
npm test         # executes the Jest suite
npm run build && npm start  # production build
```

### Docker locally

```bash
cd app
docker build -t devops-demo-api .
docker run -p 8080:8080 devops-demo-api
```

## Terraform walkthrough (`infra/`)

Terraform follows a clean “one concern per file” layout:

- `main.tf` – provider, opinionated tags, and the S3 bucket/log group used by CodePipeline/CodeBuild.
- `variables.tf` / `outputs.tf` – configurable inputs such as `github_owner`, `github_repo`, `alarm_topic_email`, plus outputs for the EKS cluster, ECR URL, and pipeline name.
- `vpc/vpc.tf` – creates a /16 VPC, public/private subnets across AZs, an internet gateway, NAT gateway, and the required route tables.
- `eks/eks.tf` – security groups, the managed EKS control plane, and a managed node group.
- `ecr/ecr.tf` – single repository with tag immutability, encryption, and retention policy.
- `iam/roles.tf` – IAM roles + policies for CodePipeline, the two CodeBuild projects, and the EKS cluster/nodes.
- `codebuild/*.tf` – three CodeBuild projects (verify/tests, package+push, kubectl deploy) mapped to the buildspecs at the repo root.
- `codepipeline/pipeline.tf` – a four-stage pipeline with GitHub source, CodeBuild verify stage, CodeBuild package stage, and CodeBuild deploy stage.
- `cloudwatch/monitoring.tf` – log groups, SNS topic/subscription, and alarms for ALB 5xx plus node CPU.

Every AWS resource receives the academic tags requested in the brief:

```hcl
locals {
  tags = {
    Project     = "DevOpsPipelineDemo"
    Environment = "Dev"
    ManagedBy   = "Terraform"
    Owner       = "Umer Karachiwala"
    Purpose     = "University DevOps Assignment"
  }
}
```

### Deploying with Terraform

1. Export AWS credentials for the destination account.
2. Populate `terraform.tfvars` (or CLI vars) with GitHub repo info, OAuth token, email address for alarms, and any CIDR overrides.
3. Initialize and apply:
   ```bash
   cd infra
   terraform init
   terraform plan -out plan.out
   terraform apply plan.out
   ```
4. Confirm the SNS subscription email to start receiving CloudWatch notifications.

The apply will create the network, cluster, IAM roles, CodeBuild projects, CodePipeline, CloudWatch lifts, and ECR repository. When the pipeline runs the first time, CodeBuild also creates the ECR image and deploys the manifests to EKS.

## CI/CD flow

1. **Source** – CodePipeline monitors the GitHub repository/branch configured via Terraform. CodePipeline’s artifact bucket is encrypted and versioned.
2. **Build (Verify stage)** – `aws_codebuild_project.build` executes `buildspec-verify.yml`, which runs `npm ci`, `npm run lint`, `npm test`, and `npm run build`. The workspace is zipped and passed to the next stage as `BuildOutput`.
3. **Package (ECR stage)** – `aws_codebuild_project.package` uses `buildspec.yml` to rebuild, run tests again for safety, build the Docker image, log in to ECR, push the tagged image, and emit `app/imageDetail.json` describing the pushed tag.
4. **Deploy (EKS stage)** – `aws_codebuild_project.deploy` consumes the packaged artifact, obtains `kubectl` + `jq`, updates the kubeconfig for the target cluster, applies the namespace/deployment/service manifests from `/k8s`, and performs a rolling update with `kubectl set image` + rollout status.
5. **Observability** – EKS control plane logs stream to CloudWatch, ALB/node alarms notify the SNS topic, and build logs live under `/aws/codebuild/<project>` for troubleshooting.

## Kubernetes manifests (`k8s/`)

- `namespace.yaml` – isolates workloads under `devops-demo`.
- `deployment.yaml` – 2 replicas, readiness/liveness probes on `/health`, CPU/memory requests+limits, and environment variables for the container. Replace the placeholder ECR image URI with the repository Terraform outputs.
- `service.yaml` – LoadBalancer service with port 80 → container port 8080; selectors match the deployment labels.

## AWS credentials & secrets

- GitHub personal access token (`github_oauth_token`) is stored as a Terraform variable and injected only into the CodePipeline Source action.
- CodeBuild service roles are least-privilege: the verify and package projects reuse the same role with ECR/S3/CloudWatch permissions, while deploy uses a separate role that can call `eks:DescribeCluster` and invoke `kubectl`.
- Kubernetes deploys rely on the AWS IAM role assigned to the deploy CodeBuild project instead of embedding kubeconfig secrets.

## Monitoring & alarms

- `/aws/eks/<cluster>/cluster` log group captures API server/audit/authenticator logs.
- `/aws/codebuild/<project>` streams gather CodeBuild logs for all three stages.
- CloudWatch alarms notify the SNS topic (confirm the subscription!) when ALB 5xx count spikes or when average node CPU exceeds 75%.

## How to test the app manually

After CodePipeline deploys, grab the external load balancer DNS name from the Kubernetes service and send sample requests:

```bash
curl http://<elb-dns>/health
curl http://<elb-dns>/hello
curl http://<elb-dns>/users | jq
```

You can also port-forward locally via `kubectl port-forward svc/devops-demo-api 8080:80 -n devops-demo` and hit `http://localhost:8080`.

## Next steps / customization ideas

1. Add an RDS or DynamoDB module if you need persistent data.
2. Extend the pipeline with a Manual Approval stage before production deployments.
3. Swap GitHub for CodeCommit by changing only the Terraform variables.
4. Use Kubernetes secrets or ConfigMaps to parameterize the API further.

This repository now captures an end-to-end DevOps story (app → Docker → Terraform → AWS services → Kubernetes) in a compact, academic-friendly format. Have fun demoing it! 🎓
