#!/bin/bash
set -e
sudo yum update -y  
sudo wget -O /etc/yum.repos.d/jenkins.repo \
            https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
sudo yum upgrade -y
sudo yum install unzip -y
sudo dnf install java-17-amazon-corretto -y
sudo yum install jenkins -y
sudo systemctl enable jenkins
sudo systemctl start jenkins
sudo systemctl status jenkins
sudo curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
sudo echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check
sudo sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
sudo chmod +x kubectl
sudo curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv.zip"
sudo unzip awscliv.zip
sudo ./aws/install
sudo curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin
sudo eksctl version
sudo  cat /var/lib/jenkins/secrets/initialAdminPassword > /home/ec2-user/jenkins-password.txt
sudo chown ec2-user:ec2-user /home/ec2-user/jenkins-password.txt
  
