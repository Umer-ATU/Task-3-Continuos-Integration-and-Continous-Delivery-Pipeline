# DevOps Pipeline Assignment - Masters Level 9

**Student Name:** Umer Karachiwala  
**Student ID:** l00196895  
**Course:** Masters in DevOps  
**Module:** Task 3 - DevOps Pipeline  

---

## Project Overview

This project demonstrates a comprehensive, industry-standard DevOps pipeline for deploying a containerized application to a Kubernetes cluster on AWS. It implements Infrastructure as Code (IaC), Continuous Integration (CI), and Continuous Delivery (CD) using Terraform, AWS CodePipeline, AWS CodeBuild, Amazon ECR, and Amazon EKS.

The objective is to showcase a robust, automated, and secure software delivery lifecycle (SDLC) suitable for a modern cloud-native environment.

## Architecture

The solution is built on AWS and consists of the following components:

*   **Infrastructure as Code (IaC):** Terraform is used to provision all AWS resources, ensuring reproducibility and state management.
*   **Network:** A custom VPC (`10.0.0.0/16`) with 2 Public Subnets and 2 Private Subnets across 2 Availability Zones for high availability.
*   **Compute:** Amazon EKS (Elastic Kubernetes Service) with a Managed Node Group running in Private Subnets.
*   **Container Registry:** Amazon ECR (Elastic Container Registry) for storing Docker images.
*   **CI/CD Pipeline:** AWS CodePipeline orchestrating the flow:
    1.  **Source:** GitHub (Webhooks trigger the pipeline).
    2.  **Build (Verify):** CodeBuild runs linting (`npm run lint`) and unit tests (`npm test`).
    3.  **Package:** CodeBuild builds the Docker image, tags it with the commit ID, and pushes it to ECR.
    4.  **Deploy:** CodeBuild updates the Kubernetes manifests with the new image URI and applies them to the EKS cluster using `kubectl`.
*   **Load Balancing:** An Application Load Balancer (ALB) distributes traffic to the EKS nodes.
*   **Observability:** CloudWatch Logs for build and cluster logs; CloudWatch Alarms for monitoring ALB errors and Node CPU usage.

## Project Structure

```
.
├── app/                        # Application Source Code
│   ├── src/                    # TypeScript Express API
│   ├── tests/                  # Jest Unit Tests
│   ├── Dockerfile              # Multi-stage Docker build
│   └── package.json            # Dependencies and scripts
├── infra/                      # Terraform Infrastructure Code
│   ├── main.tf                 # Provider and backend config
│   ├── vpc.tf                  # Network configuration
│   ├── eks.tf                  # Kubernetes Cluster & Node Group
│   ├── codepipeline.tf         # CI/CD Pipeline definition
│   ├── codebuild-*.tf          # CodeBuild project definitions
│   └── variables.tf            # Input variables
├── k8s/                        # Kubernetes Manifests
│   ├── deployment.yaml         # App Deployment (parameterized)
│   ├── service.yaml            # NodePort Service
│   └── namespace.yaml          # K8s Namespace
├── buildspec.yml               # Build & Package spec
├── buildspec-verify.yml        # Test & Lint spec
├── buildspec-deploy.yml        # Deployment spec
└── README.md                   # Project Documentation
```

## Prerequisites

To deploy this project, you need the following tools installed:

*   [Terraform](https://www.terraform.io/) (v1.6+)
*   [AWS CLI](https://aws.amazon.com/cli/) (v2)
*   [kubectl](https://kubernetes.io/docs/tasks/tools/)
*   [Node.js](https://nodejs.org/) (v18+) & npm (for local app testing)
*   [Docker](https://www.docker.com/) (for local container testing)

## Configuration

The infrastructure is highly configurable via `infra/variables.tf`. Key variables include:

*   `project_name`: `l00196895-devops-pipeline-demo`
*   `vpc_cidr`: `10.0.0.0/16` (Assignment Requirement)
*   `public_subnets`: `["10.0.1.0/24", "10.0.2.0/24"]`
*   `private_subnets`: `["10.0.10.0/24", "10.0.20.0/24"]`

**Sensitive Data:**
Sensitive variables like `github_oauth_token` should be set in a `terraform.tfvars` file (which is git-ignored) or passed as environment variables.

Example `infra/terraform.tfvars`:
```hcl
github_owner       = "Umer-ATU"
github_repo        = "Task-3-Continuos-Integration-and-Continous-Delivery-Pipeline"
github_oauth_token = "your-github-token"
alarm_topic_email  = "your-email@example.com"
```

## Deployment Instructions

### 1. Local Application Testing (Optional)
```bash
cd app
npm install
npm test
npm run build
```

### 2. Infrastructure Deployment
1.  Navigate to the infrastructure directory:
    ```bash
    cd infra
    ```
2.  Initialize Terraform:
    ```bash
    terraform init
    ```
3.  Plan the deployment:
    ```bash
    terraform plan -out plan.out
    ```
4.  Apply the configuration:
    ```bash
    terraform apply plan.out
    ```
    *Type `yes` when prompted.*

### 3. Post-Deployment
1.  **Confirm Subscription:** Check your email for a subscription confirmation from AWS SNS and click the link to receive alerts.
2.  **Access Application:**
    *   Get the ALB DNS name from the AWS Console (EC2 -> Load Balancers).
    *   Visit `http://<ALB-DNS-NAME>/health` to verify the app is running.

## CI/CD Workflow Details

1.  **Commit:** Developer pushes code to the `main` branch.
2.  **Trigger:** CodePipeline detects the change via Webhook.
3.  **Verify:** CodeBuild checks out the code, installs dependencies, runs linting, and executes unit tests. If this fails, the pipeline stops.
4.  **Package:**
    *   CodeBuild builds the Docker image.
    *   Tags the image with the commit hash and timestamp.
    *   Pushes the image to Amazon ECR.
    *   Updates `k8s/deployment.yaml` replacing `${IMAGE_URI}` with the new image location.
5.  **Deploy:**
    *   CodeBuild assumes a role with access to the EKS cluster.
    *   Updates the `kubeconfig`.
    *   Applies the updated manifests (`kubectl apply`).
    *   Verifies the rollout status (`kubectl rollout status`).

## Design Decisions & Justification

*   **EKS vs ECS:** EKS was chosen to demonstrate Kubernetes expertise, a critical skill in modern DevOps, allowing for granular control over orchestration and scaling.
*   **Private Nodes:** Worker nodes are placed in private subnets for security, preventing direct internet access. Outbound traffic is routed via NAT Gateways.
*   **Immutable Infrastructure:** Docker images are tagged uniquely per build, ensuring that every deployment is traceable to a specific version of the code.
*   **Infrastructure as Code:** Terraform allows the entire environment to be spun up or torn down in minutes, eliminating configuration drift.

## License

This project is for educational purposes as part of the Masters in DevOps program at ATU.
