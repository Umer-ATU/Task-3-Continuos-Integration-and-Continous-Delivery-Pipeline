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
  description = "Name used for tagging and resource names"
  type        = string
  default     = "l00196895-devops-pipeline-demo"
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

variable "eks_node_instance_types" {
  description = "Instance types for the managed node group"
  type        = list(string)
  default     = ["t3.small"]
}

variable "eks_node_min_size" {
  description = "Minimum number of worker nodes in the node group"
  type        = number
  default     = 1
}

variable "eks_node_desired_size" {
  description = "Desired number of worker nodes in the node group"
  type        = number
  default     = 2
}

variable "eks_node_max_size" {
  description = "Maximum number of worker nodes in the node group"
  type        = number
  default     = 3
}

variable "vpc_cidr" {
  description = "Primary CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnets" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default = [
    "10.0.1.0/24",
    "10.0.2.0/24"
  ]
}

variable "private_subnets" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default = [
    "10.0.10.0/24",
    "10.0.20.0/24"
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

variable "alb_ingress_cidrs" {
  description = "CIDR blocks allowed to reach the ALB listener"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "alb_listener_port" {
  description = "Listening port for the ALB"
  type        = number
  default     = 80
}

variable "alb_target_port" {
  description = "Target group port for downstream traffic"
  type        = number
  default     = 30080
}
