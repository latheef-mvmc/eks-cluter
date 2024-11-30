terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# AWS Provider Configuration
#provider "aws" {
 # region  = "ap-south-1"
 # profile = "sreenivas"
#}

# Docker Provider Configuration
provider "docker" {
  host = "unix:///var/run/docker.sock"
}

# Variables
variable "python_repo_name" {
  description = "Name of the Python ECR repository"
  type        = string
  default     = "python-app"
}

variable "java_repo_name" {
  description = "Name of the Java ECR repository"
  type        = string
  default     = "java-repo"
}

# ECR Repository for Python App
resource "aws_ecr_repository" "python_app" {
  name = var.python_repo_name
  force_delete = true
  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Environment = "POC"
    Team        = "DevOps"
  }
}

# ECR Repository for Java App
resource "aws_ecr_repository" "java_app" {
  name = var.java_repo_name
  force_delete = true
  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Environment = "POC"
    Team        = "DevOps"
  }
}

# Docker Image Build for Python App
resource "docker_image" "python_app" {
  name         = "${aws_ecr_repository.python_app.repository_url}:latest"
  build {
    context    = "/home/latheef/eks-ecs/docker/python"
    dockerfile = "Dockerfile"
  }
}

# Docker Image Build for Java App
resource "docker_image" "java_app" {
  name         = "${aws_ecr_repository.java_app.repository_url}:latest"
  build {
    context    = "/home/latheef/eks-ecs.old/docker/java"
    dockerfile = "Dockerfile"
  }
}

# ECR Login for Python App
resource "null_resource" "docker_ecr_login_python" {
  provisioner "local-exec" {
    environment = {
      "AWS_PROFILE"     = "sreenivas"  # Use your profile name
      "AWS_DEFAULT_REGION" = "ap-south-1"
    }
    command = <<EOT
      aws ecr get-login-password --region ap-south-1 | docker login --username AWS --password-stdin ${aws_ecr_repository.python_app.repository_url}
    EOT
  }
}

# ECR Login for Java App
resource "null_resource" "docker_ecr_login_java" {
  provisioner "local-exec" {
    environment = {
      "AWS_PROFILE"     = "sreenivas"  # Use your profile name
      "AWS_DEFAULT_REGION" = "ap-south-1"
    }
    command = <<EOT
      aws ecr get-login-password --region ap-south-1 | docker login --username AWS --password-stdin ${aws_ecr_repository.java_app.repository_url}
    EOT
  }
}

# Push the Python Image to ECR
resource "null_resource" "push_python_to_ecr" {
  depends_on = [
    docker_image.python_app,
    null_resource.docker_ecr_login_python
  ]

  provisioner "local-exec" {
    command = "docker push ${aws_ecr_repository.python_app.repository_url}:latest"
  }
}

# Push the Java Image to ECR
resource "null_resource" "push_java_to_ecr" {
  depends_on = [
    docker_image.java_app,
    null_resource.docker_ecr_login_java
  ]

  provisioner "local-exec" {
    command = "docker push ${aws_ecr_repository.java_app.repository_url}:latest"
  }
}

# Output ECR Repository URLs
output "python_ecr_repository_url" {
  value = aws_ecr_repository.python_app.repository_url
}

output "java_ecr_repository_url" {
  value = aws_ecr_repository.java_app.repository_url
}

# Output Docker Image URLs
output "python_docker_image_url" {
  value = docker_image.python_app.name
}

output "java_docker_image_url" {
  value = docker_image.java_app.name
}

