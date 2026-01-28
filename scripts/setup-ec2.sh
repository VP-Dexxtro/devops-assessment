#!/bin/bash

# DevOps Assessment - EC2 Setup Script
# Run this script on a fresh Ubuntu 22.04 EC2 instance
# Usage: curl -sSL https://raw.githubusercontent.com/your-username/devops-assessment/main/scripts/setup-ec2.sh | bash

set -e

echo "=========================================="
echo "DevOps Assessment - EC2 Setup Script"
echo "=========================================="

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

# Update system
print_status "Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Install Docker
print_status "Installing Docker..."
sudo apt install -y docker.io

# Install Docker Compose
print_status "Installing Docker Compose..."
sudo apt install -y docker-compose

# Install Git
print_status "Installing Git..."
sudo apt install -y git

# Install other utilities
print_status "Installing utilities..."
sudo apt install -y curl wget vim htop

# Add current user to docker group
print_status "Adding user to docker group..."
sudo usermod -aG docker $USER

# Enable and start Docker
print_status "Enabling Docker service..."
sudo systemctl enable docker
sudo systemctl start docker

# Install Certbot for SSL
print_status "Installing Certbot..."
sudo apt install -y certbot

# Install Java for Jenkins
print_status "Installing Java for Jenkins..."
sudo apt install -y openjdk-11-jdk

# Install Jenkins
print_status "Installing Jenkins..."
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt update
sudo apt install -y jenkins

# Enable Jenkins
sudo systemctl enable jenkins
sudo systemctl start jenkins

echo ""
echo "=========================================="
echo "EC2 Setup Complete!"
echo "=========================================="
echo ""
echo "IMPORTANT: Log out and log back in for docker group changes to take effect."
echo ""
echo "Next steps:"
echo "1. Clone your repository:"
echo "   git clone https://github.com/VP-Dexxtro/devops-assessment.git"
echo "   cd devops-assessment"
echo ""
echo "2. Deploy the application:"
echo "   docker-compose up -d --build"
echo ""
echo "3. Get Jenkins initial password:"
echo "   sudo cat /var/lib/jenkins/secrets/initialAdminPassword"
echo ""
echo "4. Access Jenkins at: http://<EC2-PUBLIC-IP>:8080"
echo ""
