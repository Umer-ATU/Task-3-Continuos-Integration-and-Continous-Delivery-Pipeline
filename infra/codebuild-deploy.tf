resource "aws_codebuild_project" "deploy" {
  name         = "${var.project_name}-deploy"
  description  = "Applies Kubernetes manifests to EKS"
  service_role = aws_iam_role.codebuild_deploy.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/standard:7.0"
    type         = "LINUX_CONTAINER"

    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = var.region
    }

    environment_variable {
      name  = "EKS_CLUSTER_NAME"
      value = var.cluster_name
    }

    environment_variable {
      name  = "K8S_NAMESPACE"
      value = var.kubernetes_namespace
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "buildspec-deploy.yml"
  }

  logs_config {
    cloudwatch_logs {
      group_name  = aws_cloudwatch_log_group.codebuild.name
      stream_name = "deploy"
    }
  }

  tags = local.tags
}
