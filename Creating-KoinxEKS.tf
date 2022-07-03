# Role for EKS Cluster
#=====================

resource "aws_iam_role" "koinx-role" {
  name = "eks-cluster-koinx"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

# EKS Cluster
#============

resource "aws_iam_role_policy_attachment" "koinx-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.koinx-role.name
}

resource "aws_iam_role_policy_attachment" "koinx-AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.koinx-role.name
}

resource "aws_iam_role_policy_attachment" "koinx-AmazonECR_FullaccessPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
  role       = aws_iam_role.koinx-role.name
}

resource "aws_eks_cluster" "koinx" {
  name     = "koinx-cluster"
  role_arn = aws_iam_role.koinx-role.arn

  vpc_config {
    subnet_ids = [aws_subnet.public-subnet-1.id,aws_subnet.public-subnet-2.id]
    endpoint_private_access = true
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.koinx-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.koinx-AmazonEKSVPCResourceController,
    aws_iam_role_policy_attachment.koinx-AmazonECR_FullaccessPolicy,
  ]
}


# Node Group
#===========

resource "aws_eks_node_group" "node-koinx" {
  cluster_name    = aws_eks_cluster.koinx.name
  node_group_name = "koinx-group"
  node_role_arn   = aws_iam_role.koinx.arn
  subnet_ids      = [aws_subnet.public-subnet-1.id]
  instance_types  = [var.instance_type_eks]
  capacity_type   = var.capacity_type_eks
  scaling_config {
    desired_size = var.desired_size
    max_size     = var.max_size
    min_size     = var.min_size
  }

update_config {
    max_unavailable = var.max_unavailable
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.koinx-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.koinx-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.koinx-AmazonEC2ContainerRegistryReadOnly,
  ]
}

# Role for the Node Group
#========================

resource "aws_iam_role" "koinx" {
  name = "eks-node-group-koinx"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "koinx-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.koinx.name
}

resource "aws_iam_role_policy_attachment" "koinx-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.koinx.name
}

resource "aws_iam_role_policy_attachment" "koinx-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.koinx.name
}
