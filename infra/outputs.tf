output "eks_cluster_name" {
  description = "Provisioned EKS cluster name"
  value       = aws_eks_cluster.this.name
}

output "ecr_repository_url" {
  description = "URL of the container image repository"
  value       = aws_ecr_repository.api.repository_url
}

output "codepipeline_name" {
  description = "Continuous delivery pipeline"
  value       = aws_codepipeline.cicd.name
}

output "alb_dns_name" {
  description = "Application Load Balancer DNS name"
  value       = aws_lb.application.dns_name
}
