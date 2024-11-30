resource "aws_instance" "eks_manager" {
  ami           = "ami-0614680123427b75e" # Official Ubuntu 22.04 AMI (replace with the correct one for your region)
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public[0].id
  vpc_security_group_ids = [aws_security_group.eks_manager_sg.id]
  key_name      = "kubectl"
  iam_instance_profile = "kubectl-iam"
  user_data                    = file("script.sh") 
  tags = {
    Name = "eks-manager"
  }

     
}

output "jenkins_admin_password" {
  value       = "ssh -i ~/.ssh/kubectl.pem ubuntu@${aws_instance.eks_manager.public_ip} 'cat /home/ubuntu/jenkins-password.txt'"
  description = "Run this command to fetch the Jenkins admin password"
}

resource "aws_security_group" "eks_manager_sg" {
  name   = "eks-manager-sg"
  vpc_id = aws_vpc.eks-cluster-vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "open-all-traffic-sg"
  }
}

output "eks_manager_public_ip" {
  value       = aws_instance.eks_manager.public_ip
  description = "Public IP address of the EKS manager EC2 instance"
}
