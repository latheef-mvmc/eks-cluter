# IAM Role for Node Group
resource "aws_iam_role" "node_group" {
  name = "eks-node-group-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action    = "sts:AssumeRole",
        Effect    = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# Attach IAM Policies to Node Group Role
resource "aws_iam_role_policy_attachment" "node_group_policies" {
  count      = 3
  role       = aws_iam_role.node_group.name
  policy_arn = element([
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  ], count.index)
}

# EKS Cluster Module
module "eks" {
  source                  = "terraform-aws-modules/eks/aws"
  version                 = "~> 19.0"
  cluster_name            = var.cluster_name
  cluster_version         = var.cluster_version
  vpc_id                  = aws_vpc.eks-cluster-vpc.id
  subnet_ids              = aws_subnet.public[*].id
  create_aws_auth_configmap = false # Disable auto-creation of aws-auth
}

# EKS Node Group
resource "aws_eks_node_group" "worker_nodes" {
  cluster_name    = module.eks.cluster_name
  node_group_name = "worker-group"
  node_role_arn   = aws_iam_role.node_group.arn
  subnet_ids      = aws_subnet.public[*].id

  scaling_config {
    desired_size = var.desired_size
    max_size     = var.max_size
    min_size     = var.min_size
  }

  instance_types = var.instance_types

  # Tags applied to the Node Group (and propagated to the instances)
  tags = {
    Name             = "eks-worker-group"
    #environment      = var.environment
    #application      = var.application
    managed-by       = "terraform"
  }

  # Additional labels for Kubernetes nodes
  labels = {
    "node-type" = "worker"
  }

  }



# resource "aws_eks_node_group" "worker_nodes" {
#   cluster_name    = module.eks.cluster_name
#   node_group_name = "worker-group"
#   node_role_arn   = aws_iam_role.node_group.arn
#   subnet_ids      = aws_subnet.public[*].id

#   scaling_config {
#     desired_size = var.desired_size
#     max_size     = var.max_size
#     min_size     = var.min_size
#   }

#   instance_types = var.instance_types

#   tags = {
#     Name = "eks-worker-group"
#   }
# }






# Outputs
output "vpc_id" {
  value = aws_vpc.eks-cluster-vpc.id
}

output "subnet_ids" {
  value = aws_subnet.public[*].id
}

output "eks_cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "eks_cluster_name" {
  value = module.eks.cluster_name
}
