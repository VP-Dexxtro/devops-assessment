#!/bin/bash

# DevOps Assessment - Deployment Script
# Usage: ./scripts/deploy.sh

set -e

echo "=========================================="
echo "DevOps Assessment - Deployment Script"
echo "=========================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    print_error "Docker is not installed. Please install Docker first."
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    print_error "Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

print_status "Docker and Docker Compose are available."

# Stop existing containers
print_status "Stopping existing containers..."
docker-compose down || true

# Pull latest images
print_status "Pulling latest images..."
docker-compose pull

# Build and start containers
print_status "Building and starting containers..."
docker-compose up -d --build

# Wait for services to start
print_status "Waiting for services to start..."
sleep 10

# Check service status
print_status "Checking service status..."
docker-compose ps

# Health checks
print_status "Running health checks..."

# Check backend
if curl -sf http://localhost:5000/health > /dev/null; then
    print_status "Backend is healthy!"
else
    print_warning "Backend health check failed. Check logs with: docker-compose logs backend"
fi

# Check frontend
if curl -sf http://localhost:3000 > /dev/null; then
    print_status "Frontend is healthy!"
else
    print_warning "Frontend health check failed. Check logs with: docker-compose logs frontend"
fi

# Check Prometheus
if curl -sf http://localhost:9090/-/healthy > /dev/null; then
    print_status "Prometheus is healthy!"
else
    print_warning "Prometheus health check failed. Check logs with: docker-compose logs prometheus"
fi

# Check Grafana
if curl -sf http://localhost:3001/api/health > /dev/null; then
    print_status "Grafana is healthy!"
else
    print_warning "Grafana health check failed. Check logs with: docker-compose logs grafana"
fi

echo ""
echo "=========================================="
echo "Deployment Complete!"
echo "=========================================="
echo ""
echo "Access the applications at:"
echo "  - Frontend:     http://localhost:3000"
echo "  - Backend API:  http://localhost:5000/api"
echo "  - Prometheus:   http://localhost:9090"
echo "  - Grafana:      http://localhost:3001 (admin/admin123)"
echo "  - Alertmanager: http://localhost:9093"
echo ""
