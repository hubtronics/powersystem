#!/bin/bash

# Power Tune Auto Garage - Deploy from GitHub to Safaricom
# This script deploys directly from GitHub to your Safaricom server

echo "🚀 Power Tune Auto Garage - GitHub to Safaricom Deployment"
echo "=========================================================="
echo ""

# Variables - UPDATE THESE
GITHUB_REPO=""
DOMAIN="powertune.safaricom.co.ke"
APP_DIR="/var/www/powertune"
SERVICE_NAME="powertune"

echo "📋 Configuration:"
echo "================"
read -p "GitHub repository URL (https://github.com/user/repo.git): " GITHUB_REPO
read -p "Domain name (default: $DOMAIN): " DOMAIN_INPUT
DOMAIN=${DOMAIN_INPUT:-$DOMAIN}

echo ""
echo "🔧 Deployment Configuration:"
echo "============================"
echo "📦 Repository: $GITHUB_REPO"
echo "🌐 Domain: $DOMAIN"
echo "📁 App Directory: $APP_DIR"
echo "⚙️  Service: $SERVICE_NAME"
echo ""

read -p "🚀 Proceed with deployment? (y/n): " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Deployment cancelled."
    exit 1
fi

echo ""
echo "🚀 Starting deployment..."
echo "========================"

# Update system
echo "📦 Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Install required packages
echo "📥 Installing required packages..."
sudo apt install -y python3 python3-venv python3-pip nginx git certbot python3-certbot-nginx

# Create application user and directories
echo "👤 Setting up application user..."
sudo useradd --system --gid www-data --shell /bin/bash --home $APP_DIR powertune 2>/dev/null || true

echo "📁 Creating directories..."
sudo mkdir -p $APP_DIR
sudo mkdir -p /var/log/powertune
sudo mkdir -p /var/run/powertune

# Clone repository
echo "📥 Cloning repository from GitHub..."
if [ -d "$APP_DIR/.git" ]; then
    echo "📄 Repository exists, pulling latest changes..."
    cd $APP_DIR
    sudo -u www-data git pull
else
    echo "📥 Cloning fresh repository..."
    sudo rm -rf $APP_DIR/*
    sudo -u www-data git clone $GITHUB_REPO $APP_DIR
fi

cd $APP_DIR

# Set permissions
echo "🔒 Setting permissions..."
sudo chown -R www-data:www-data $APP_DIR
sudo chown -R www-data:www-data /var/log/powertune
sudo chown -R www-data:www-data /var/run/powertune

# Setup Python virtual environment
echo "🐍 Setting up Python environment..."
sudo -u www-data python3 -m venv venv
sudo -u www-data $APP_DIR/venv/bin/pip install --upgrade pip
sudo -u www-data $APP_DIR/venv/bin/pip install -r requirements_prod.txt

# Create environment file
echo "⚙️  Configuring environment..."
sudo cp .env.example .env
sudo chown www-data:www-data .env

# Update environment file
sudo tee .env > /dev/null << EOF
FLASK_ENV=production
SECRET_KEY=$(openssl rand -hex 32)
DOMAIN=$DOMAIN
DATABASE_URL=sqlite:///garage.db
SESSION_COOKIE_SECURE=True
SESSION_COOKIE_HTTPONLY=True
SESSION_COOKIE_SAMESITE=Lax
EOF

# Install systemd service
echo "⚙️  Installing systemd service..."
sudo cp powertune.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable $SERVICE_NAME

# Configure Nginx
echo "🌐 Configuring Nginx..."
# Update domain in nginx config
sudo sed "s/powertune\.safaricom\.co\.ke/$DOMAIN/g" nginx_powertune.conf > /tmp/nginx_powertune_updated.conf
sudo cp /tmp/nginx_powertune_updated.conf /etc/nginx/sites-available/powertune
sudo ln -sf /etc/nginx/sites-available/powertune /etc/nginx/sites-enabled/

# Test nginx configuration
sudo nginx -t

# Start services
echo "🚀 Starting services..."
sudo systemctl start $SERVICE_NAME
sudo systemctl reload nginx

# Check service status
echo "🔍 Checking service status..."
sudo systemctl status $SERVICE_NAME --no-pager

echo ""
echo "🔒 SSL Certificate Setup"
echo "========================"
echo "⚠️  IMPORTANT: Make sure DNS for $DOMAIN points to this server!"
echo ""

read -p "🌐 Is DNS configured and pointing to this server? (y/n): " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🔒 Installing SSL certificate..."
    sudo certbot --nginx -d $DOMAIN --non-interactive --agree-tos --email admin@$DOMAIN
    
    # Test auto-renewal
    sudo certbot renew --dry-run
    
    echo "✅ SSL certificate installed!"
else
    echo "⚠️  SSL certificate skipped. Run this command after DNS is configured:"
    echo "   sudo certbot --nginx -d $DOMAIN"
fi

echo ""
echo "🎉 DEPLOYMENT COMPLETED!"
echo "========================"
echo ""
echo "🌐 Your site should be available at:"
if [ -f "/etc/letsencrypt/live/$DOMAIN/fullchain.pem" ]; then
    echo "   https://$DOMAIN"
else
    echo "   http://$DOMAIN (HTTP only - configure SSL)"
fi
echo ""
echo "👤 Default login:"
echo "   Username: admin"
echo "   Password: admin"
echo "   ⚠️  CHANGE PASSWORD IMMEDIATELY!"
echo ""
echo "🔧 Management commands:"
echo "   Status: sudo systemctl status powertune"
echo "   Logs:   sudo journalctl -u powertune -f"
echo "   Restart: sudo systemctl restart powertune"
echo ""
echo "🔄 To update from GitHub:"
echo "   cd $APP_DIR"
echo "   sudo -u www-data git pull"
echo "   sudo systemctl restart powertune"
echo ""
echo "✅ Power Tune Auto Garage is now live!"
