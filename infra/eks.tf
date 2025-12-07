locals {
  eks_cluster_security_group_name = "${var.project_name}-cluster-sg"
  eks_node_security_group_name    = "${var.project_name}-nodes-sg"
  eks_node_group_name             = "${var.project_name}-ng"
  eks_node_group_tag              = "${var.project_name}-node-group"
}

resource "aws_security_group" "eks_cluster" {
  name        = local.eks_cluster_security_group_name
  description = "Security group for EKS control plane"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.tags, { Name = local.eks_cluster_security_group_name })
}

resource "aws_security_group" "eks_nodes" {
  name        = local.eks_node_security_group_name
  description = "Security group for worker nodes"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow pods to communicate with each other"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  ingress {
    description     = "Allow API server to talk to nodes"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.eks_cluster.id]
  }

  ingress {
    description     = "Allow ALB to reach NodePort traffic"
    from_port       = 30000
    to_port         = 32767
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.tags, { Name = local.eks_node_security_group_name })
}

resource "aws_security_group_rule" "cluster_to_nodes" {
  description              = "Allow worker nodes to communicate with control plane"
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_cluster.id
  source_security_group_id = aws_security_group.eks_nodes.id
}

resource "aws_security_group_rule" "nodes_to_cluster" {
  description              = "Allow control plane to communicate with nodes"
  type                     = "egress"
  from_port                = 1025
  to_port                  = 65535
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_cluster.id
  source_security_group_id = aws_security_group.eks_nodes.id
}

resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster.arn
  version  = var.eks_version

  access_config {
    authentication_mode                         = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }

  vpc_config {
    security_group_ids      = [aws_security_group.eks_cluster.id]
    subnet_ids              = concat(aws_subnet.public[*].id, aws_subnet.private[*].id)
    endpoint_public_access  = true
    endpoint_private_access = false
  }

  enabled_cluster_log_types = ["api", "audit", "authenticator"]
  tags                      = merge(local.tags, { Name = var.cluster_name })

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.eks_cluster_AmazonEKSServicePolicy
  ]
}

resource "aws_launch_template" "eks_nodes" {
  name = "${var.project_name}-node-template"

  vpc_security_group_ids = [
    aws_security_group.eks_nodes.id,
    aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
  ]

  tag_specifications {
    resource_type = "instance"
    tags          = merge(local.tags, { Name = local.eks_node_group_tag })
  }
}

resource "aws_eks_node_group" "default" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = local.eks_node_group_name
  node_role_arn   = aws_iam_role.eks_nodes.arn
  subnet_ids      = aws_subnet.private[*].id
  
  launch_template {
    id      = aws_launch_template.eks_nodes.id
    version = "$Latest"
  }

  scaling_config {
    desired_size = var.eks_node_desired_size
    max_size     = var.eks_node_max_size
    min_size     = var.eks_node_min_size
  }

  update_config {
    max_unavailable = 1
  }

  tags = merge(local.tags, { Name = local.eks_node_group_tag })

  depends_on = [
    aws_iam_role_policy_attachment.eks_nodes_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.eks_nodes_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.eks_nodes_AmazonEC2ContainerRegistryReadOnly
  ]
}

resource "aws_eks_access_entry" "codebuild_deploy" {
  cluster_name  = aws_eks_cluster.this.name
  principal_arn = aws_iam_role.codebuild_deploy.arn
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "codebuild_deploy_admin" {
  cluster_name  = aws_eks_cluster.this.name
  principal_arn = aws_iam_role.codebuild_deploy.arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }

  depends_on = [aws_eks_access_entry.codebuild_deploy]
}
