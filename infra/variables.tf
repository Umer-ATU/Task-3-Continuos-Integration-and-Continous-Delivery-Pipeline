variable "region" {
  description = "AWS region for all resources"
  type        = string
  default     = "eu-west-1"
}

variable "aws_account_id" {
  description = "Target AWS account ID"
  type        = string
  default     = "123456789012"
}

variable "project_name" {
  description = "Human friendly name used for tagging and resource names"
  type        = string
  default     = "devops-pipeline-demo"
}

variable "cluster_name" {
  description = "Amazon EKS cluster name"
  type        = string
  default     = "devops-pipeline-demo"
}

variable "eks_version" {
  description = "Amazon EKS control plane version"
  type        = string
  default     = "1.29"
}

variable "vpc_cidr" {
  description = "Primary CIDR block for the VPC"
  type        = string
  default     = "10.20.0.0/16"
}

variable "public_subnets" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default = [
    "10.20.1.0/24",
    "10.20.2.0/24"
  ]
}

variable "private_subnets" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default = [
    "10.20.11.0/24",
    "10.20.12.0/24"
  ]
}

variable "github_owner" {
  description = "GitHub repository owner"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
}

variable "github_branch" {
  description = "Branch to monitor for changes"
  type        = string
  default     = "main"
}

variable "github_oauth_token" {
  description = "GitHub personal access token for CodePipeline"
  type        = string
  sensitive   = true
}

variable "kubernetes_namespace" {
  description = "Namespace used for deploying the workload"
  type        = string
  default     = "devops-demo"
}

variable "alarm_topic_email" {
  description = "Email address to receive CloudWatch alerts"
  type        = string
}

variable "application_load_balancer_name" {
  description = "Name of the load balancer used for CloudWatch 5xx alarms"
  type        = string
  default     = "app/devops-demo"
}
