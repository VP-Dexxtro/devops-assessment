#!/bin/bash

# DevOps Assessment - SSL Setup Script
# Usage: ./scripts/setup-ssl.sh yourdomain.com

set -e

if [ -z "$1" ]; then
    echo "Usage: ./scripts/setup-ssl.sh yourdomain.com"
    exit 1
fi

DOMAIN=$1

echo "=========================================="
echo "DevOps Assessment - SSL Setup"
echo "Domain: $DOMAIN"
echo "=========================================="

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if certbot is installed
if ! command -v certbot &> /dev/null; then
    print_status "Installing Certbot..."
    sudo apt update
    sudo apt install -y certbot
fi

# Stop nginx container to free port 80
print_status "Stopping nginx container..."
docker-compose stop nginx || true

# Request SSL certificate
print_status "Requesting SSL certificate for $DOMAIN..."
sudo certbot certonly --standalone -d $DOMAIN --non-interactive --agree-tos --register-unsafely-without-email

# Check if certificate was created
if [ -d "/etc/letsencrypt/live/$DOMAIN" ]; then
    print_status "SSL certificate created successfully!"
    
    # Update nginx.conf with the domain
    print_status "Updating nginx configuration..."
    sed -i "s/yourdomain.com/$DOMAIN/g" nginx/nginx.conf
    
    # Uncomment HTTPS server block
    print_warning "Please manually uncomment the HTTPS server block in nginx/nginx.conf"
    
    # Restart nginx
    print_status "Starting nginx container..."
    docker-compose up -d nginx
    
    echo ""
    echo "=========================================="
    echo "SSL Setup Complete!"
    echo "=========================================="
    echo ""
    echo "Your site should now be accessible at:"
    echo "  https://$DOMAIN"
    echo ""
    echo "Certificate location:"
    echo "  /etc/letsencrypt/live/$DOMAIN/"
    echo ""
    echo "Don't forget to set up auto-renewal:"
    echo "  sudo certbot renew --dry-run"
    echo ""
else
    print_error "Failed to create SSL certificate. Check the Certbot output above."
    exit 1
fi
