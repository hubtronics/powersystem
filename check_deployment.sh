#!/bin/bash

# Power Tune Auto Garage - Deployment Status Checker
# Run this script to check each step of the deployment

echo "🔍 Power Tune Auto Garage - Deployment Status Checker"
echo "======================================================"
echo ""

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to check status
check_status() {
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ PASS${NC}"
    else
        echo -e "${RED}❌ FAIL${NC}"
    fi
}

echo "🏗️  PHASE 1: System Requirements"
echo "================================"

echo -n "Python 3 installed: "
python3 --version > /dev/null 2>&1
check_status

echo -n "Nginx installed: "
nginx -v > /dev/null 2>&1
check_status

echo -n "Systemctl available: "
systemctl --version > /dev/null 2>&1
check_status

echo ""
echo "🌐 PHASE 2: Network & DNS"
echo "========================="

read -p "Enter your domain (e.g., powertune.safaricom.co.ke): " DOMAIN

if [ ! -z "$DOMAIN" ]; then
    echo -n "DNS resolution for $DOMAIN: "
    nslookup $DOMAIN > /dev/null 2>&1
    check_status
    
    echo -n "HTTP connectivity to $DOMAIN: "
    curl -s -o /dev/null -w "%{http_code}" http://$DOMAIN | grep -q "200\|301\|302"
    check_status
fi

echo ""
echo "📁 PHASE 3: Application Files"
echo "=============================="

echo -n "Application directory exists: "
[ -d "/var/www/powertune" ]
check_status

echo -n "Virtual environment exists: "
[ -d "/var/www/powertune/venv" ]
check_status

echo -n "Requirements installed: "
/var/www/powertune/venv/bin/pip list | grep -q "Flask"
check_status

echo -n "Database file exists: "
[ -f "/var/www/powertune/garage.db" ]
check_status

echo ""
echo "⚙️  PHASE 4: Services"
echo "===================="

echo -n "PowerTune service active: "
systemctl is-active --quiet powertune
check_status

echo -n "Nginx service active: "
systemctl is-active --quiet nginx
check_status

echo -n "PowerTune service enabled: "
systemctl is-enabled --quiet powertune
check_status

echo ""
echo "🔒 PHASE 5: Security & SSL"
echo "=========================="

if [ ! -z "$DOMAIN" ]; then
    echo -n "SSL certificate exists: "
    [ -f "/etc/letsencrypt/live/$DOMAIN/fullchain.pem" ]
    check_status
    
    echo -n "HTTPS connectivity: "
    curl -s -o /dev/null https://$DOMAIN
    check_status
fi

echo ""
echo "📊 PHASE 6: Application Health"
echo "=============================="

echo -n "Application responding: "
if [ ! -z "$DOMAIN" ]; then
    curl -s https://$DOMAIN | grep -q "Power Tune\|Login"
    check_status
else
    curl -s http://localhost:5000 | grep -q "Power Tune\|Login"
    check_status
fi

echo ""
echo "📋 SUMMARY"
echo "=========="

if [ ! -z "$DOMAIN" ]; then
    echo "🌐 Website URL: https://$DOMAIN"
else
    echo "🌐 Local URL: http://localhost:5000"
fi

echo "📝 Default Login: admin / admin"
echo "⚠️  Remember to change default password!"
echo ""

echo "🔧 Useful Commands:"
echo "  Status: sudo systemctl status powertune"
echo "  Logs:   sudo journalctl -u powertune -f"
echo "  Restart: sudo systemctl restart powertune"
echo ""

echo "✅ Deployment check completed!"
