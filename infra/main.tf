terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.33"
    }
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = local.tags
  }
}

locals {
  tags = {
    Project     = "DevOpsPipelineDemo"
    Environment = "Dev"
    ManagedBy   = "Terraform"
    Owner       = "Umer Karachiwala"
    Purpose     = "University DevOps Assignment"
  }
}

resource "aws_s3_bucket" "codepipeline_artifacts" {
  bucket        = "${var.project_name}-artifacts-${var.aws_account_id}"
  force_destroy = true

  tags = local.tags
}

resource "aws_s3_bucket_versioning" "codepipeline" {
  bucket = aws_s3_bucket.codepipeline_artifacts.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "codepipeline" {
  bucket = aws_s3_bucket.codepipeline_artifacts.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_cloudwatch_log_group" "codebuild" {
  name              = "/aws/codebuild/${var.project_name}"
  retention_in_days = 30
  tags              = local.tags
}
