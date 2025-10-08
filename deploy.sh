#!/bin/bash

# Power Tune Auto Garage - Deployment Script
# This script deploys the application to a Linux server

set -e

echo "🚀 Starting Power Tune Auto Garage Deployment..."

# Variables
APP_NAME="powertune"
APP_DIR="/var/www/powertune"
NGINX_CONF="/etc/nginx/sites-available/powertune"
SERVICE_FILE="/etc/systemd/system/powertune.service"
LOG_DIR="/var/log/powertune"
RUN_DIR="/var/run/powertune"

# Create application directory
echo "📁 Creating application directory..."
sudo mkdir -p $APP_DIR
sudo mkdir -p $LOG_DIR
sudo mkdir -p $RUN_DIR

# Set permissions
echo "🔐 Setting permissions..."
sudo chown -R www-data:www-data $APP_DIR
sudo chown -R www-data:www-data $LOG_DIR
sudo chown -R www-data:www-data $RUN_DIR

# Copy application files
echo "📋 Copying application files..."
sudo cp -r . $APP_DIR/
sudo chown -R www-data:www-data $APP_DIR

# Create virtual environment
echo "🐍 Setting up Python virtual environment..."
cd $APP_DIR
sudo -u www-data python3 -m venv venv
sudo -u www-data $APP_DIR/venv/bin/pip install --upgrade pip
sudo -u www-data $APP_DIR/venv/bin/pip install -r requirements_prod.txt

# Copy service file
echo "⚙️ Installing systemd service..."
sudo cp powertune.service $SERVICE_FILE
sudo systemctl daemon-reload
sudo systemctl enable powertune

# Copy nginx configuration
echo "🌐 Configuring Nginx..."
sudo cp nginx_powertune.conf $NGINX_CONF
sudo ln -sf $NGINX_CONF /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx

# Start the service
echo "🔄 Starting Power Tune service..."
sudo systemctl start powertune
sudo systemctl status powertune

echo "✅ Deployment completed successfully!"
echo "🌍 Your application should now be available at: https://powertune.safaricom.co.ke"
echo ""
echo "📊 Useful commands:"
echo "  Status: sudo systemctl status powertune"
echo "  Logs:   sudo journalctl -u powertune -f"
echo "  Restart: sudo systemctl restart powertune"
