# Source Code Management

## Overview

Source Code Management (SCM) is the foundational stage of any DevOps pipeline, serving as the single source of truth for application code, configuration files, and infrastructure definitions. For this project, **GitHub** was selected as the primary SCM platform due to its robust version control capabilities, seamless integration with AWS services, and industry-standard collaborative features.

## GitHub as the SCM Platform

### What is GitHub?

GitHub is a cloud-based Git repository hosting service that provides distributed version control and source code management functionality. Built on top of Git, GitHub extends basic version control with powerful collaboration features, including pull requests, code reviews, issue tracking, and project management tools.

### Key Features Utilized

1. **Version Control**: Git-based distributed version control system enabling multiple developers to work simultaneously
2. **Branch Management**: Support for feature branches, release branches, and hotfix workflows
3. **Collaboration**: Pull request workflows for code review and quality assurance
4. **Security**: Access control, branch protection rules, and secrets management
5. **Integration**: Native webhooks and APIs for CI/CD pipeline integration

### Repository Structure

The project repository was organized following best practices:

```
project-root/
├── src/                    # Application source code
├── Dockerfile             # Container image definition
├── buildspec.yml          # AWS CodeBuild configuration
├── kubernetes/            # Kubernetes manifests for EKS deployment
│   ├── deployment.yaml
│   └── service.yaml
├── taskdef.json          # ECS task definition
└── README.md             # Project documentation
```

## Integration with AWS CodePipeline

### GitHub and AWS Connection

The integration between GitHub and AWS CodePipeline was established using **AWS CodeStar Connections** (formerly GitHub OAuth), which provides a secure and managed way to connect AWS services with third-party repositories.

#### Connection Setup Process

1. **Creating the Connection**
   - Navigated to AWS CodePipeline console
   - Selected "Settings" → "Connections"
   - Created a new connection with provider type "GitHub"
   - Authenticated with GitHub account credentials
   - Authorized AWS Connector for GitHub application

2. **Authorization and Permissions**
   - Granted AWS CodePipeline access to specific repositories
   - Configured repository access scope (public/private repositories)
   - Established OAuth token for secure communication

3. **Connection Configuration**
   ```
   Connection Name: github-connection
   Provider: GitHub
   Status: Available
   Connection ARN: arn:aws:codestar-connections:region:account-id:connection/connection-id
   ```

### Pipeline Source Stage Configuration

The source stage of the AWS CodePipeline was configured to monitor the GitHub repository for changes:

#### Source Action Configuration

```yaml
Source Stage:
  Action Name: Source
  Action Provider: CodeStarSourceConnection
  Configuration:
    ConnectionArn: arn:aws:codestar-connections:region:account-id:connection/connection-id
    FullRepositoryId: username/repository-name
    BranchName: main
    OutputArtifactFormat: CODE_ZIP
    DetectChanges: true
```

#### Key Configuration Parameters

- **ConnectionArn**: Reference to the CodeStar connection established with GitHub
- **FullRepositoryId**: Complete repository identifier (owner/repository)
- **BranchName**: Target branch to monitor (e.g., `main`, `develop`, `production`)
- **OutputArtifactFormat**: Format of the source artifact (`CODE_ZIP` or `CODEBUILD_CLONE_REF`)
- **DetectChanges**: Enables automatic pipeline triggering on code commits

### Webhook Mechanism

When the connection is established, AWS automatically creates a webhook in the GitHub repository:

1. **Webhook Creation**: AWS registers a webhook endpoint in GitHub repository settings
2. **Event Monitoring**: Webhook listens for push events on the specified branch
3. **Pipeline Triggering**: On code commit, GitHub sends a POST request to AWS webhook endpoint
4. **Execution Initiation**: CodePipeline receives the event and starts pipeline execution

#### Webhook Configuration Details

```
Payload URL: https://webhooks.aws.amazon.com/trigger
Content Type: application/json
Events: Push events
Active: Yes
SSL Verification: Enabled
```

## Version Control Workflow

### Branching Strategy

A **Git Flow** branching strategy was implemented to maintain code quality and enable parallel development:

1. **Main Branch**: Production-ready code
2. **Develop Branch**: Integration branch for features
3. **Feature Branches**: Individual feature development (`feature/*`)
4. **Release Branches**: Release preparation (`release/*`)
5. **Hotfix Branches**: Emergency production fixes (`hotfix/*`)

### Commit and Deployment Flow

```mermaid
graph LR
    A[Developer Commits Code] --> B[Push to GitHub]
    B --> C[GitHub Webhook Triggered]
    C --> D[AWS CodePipeline Activated]
    D --> E[Source Stage: Fetch Code]
    E --> F[Build Stage: CodeBuild]
    F --> G[Deploy Stage: ECS/EKS]
```

### Code Review Process

Before merging to the main branch:

1. Developer creates a feature branch
2. Implements changes and commits code
3. Opens a Pull Request (PR) to main branch
4. Team members review code changes
5. Automated checks run (if configured)
6. PR is approved and merged
7. Merge to main triggers the pipeline

## Security Considerations

### Access Control

- **Repository Permissions**: Configured team-based access control in GitHub
- **Branch Protection**: Enabled branch protection rules on main branch
  - Require pull request reviews before merging
  - Require status checks to pass
  - Prevent force pushes
  - Prevent deletion

### Secrets Management

- **GitHub Secrets**: Stored sensitive data (AWS credentials, API keys) as encrypted secrets
- **AWS Secrets Manager**: Referenced secrets in buildspec.yml without hardcoding
- **IAM Roles**: Used IAM roles for CodePipeline instead of access keys

### Connection Security

- **OAuth Authentication**: Secure token-based authentication
- **Encrypted Communication**: All data transfer over HTTPS/TLS
- **Least Privilege**: Connection granted minimum required permissions

## Benefits of GitHub Integration

1. **Automation**: Automatic pipeline triggering eliminates manual intervention
2. **Traceability**: Complete audit trail of code changes and deployments
3. **Reliability**: Managed connection service ensures high availability
4. **Scalability**: Handles multiple repositories and pipelines
5. **Developer Experience**: Familiar Git workflow with minimal learning curve

## Challenges and Solutions

### Challenge 1: Connection Authentication
**Issue**: Initial connection setup failed due to organization permissions  
**Solution**: Requested organization admin to approve AWS Connector application

### Challenge 2: Webhook Reliability
**Issue**: Occasional webhook delivery failures  
**Solution**: Enabled CloudWatch Events as backup trigger mechanism

### Challenge 3: Large Repository Size
**Issue**: Source artifact download timeout for large repositories  
**Solution**: Used `CODEBUILD_CLONE_REF` format for Git clone instead of ZIP download

## Monitoring and Logging

### Pipeline Execution Tracking

- **CodePipeline Console**: Visual representation of pipeline execution
- **CloudWatch Logs**: Detailed logs of source stage execution
- **GitHub Commit History**: Correlation between commits and deployments

### Metrics Monitored

- Pipeline execution success/failure rate
- Source stage duration
- Webhook delivery latency
- Failed webhook deliveries

## Conclusion

The integration of GitHub with AWS CodePipeline established a robust and automated source code management foundation for the DevOps pipeline. The CodeStar Connections service provided a secure, managed, and reliable mechanism to bridge the gap between GitHub's version control capabilities and AWS's CI/CD services. This integration enabled true continuous integration and continuous deployment, where every code commit automatically triggered the build, test, and deployment processes, significantly reducing time-to-market and improving development efficiency.

The combination of GitHub's collaborative features and AWS CodePipeline's automation capabilities created a seamless developer experience while maintaining security, traceability, and reliability throughout the software delivery lifecycle.
