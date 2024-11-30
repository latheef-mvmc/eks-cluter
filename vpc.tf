# VPC and Networking#############
resource "aws_vpc" "eks-cluster-vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "eks-cluster-vpc"
  }
}

# Subnets
data "aws_availability_zones" "available" {}

resource "aws_subnet" "public" {
  count                   = length(var.subnet_cidr_blocks)
  vpc_id                  = aws_vpc.eks-cluster-vpc.id
  cidr_block              = var.subnet_cidr_blocks[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet-${count.index}"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.eks-cluster-vpc.id
  tags = {
    Name = "eks-igw"
  }
}

# Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.eks-cluster-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}
