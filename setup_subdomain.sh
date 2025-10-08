#!/bin/bash

# Power Tune Auto Garage - Safaricom Subdomain Setup Helper
# This script helps you prepare for hosting at powertune.safaricom.co.ke

echo "🔧 Power Tune Auto Garage - Safaricom Subdomain Setup"
echo "================================================="
echo ""

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   echo "❌ This script should not be run as root. Run as a regular user with sudo access."
   exit 1
fi

echo "📋 Pre-deployment Checklist:"
echo ""
echo "1. ✅ Ensure you have access to Safaricom DNS management"
echo "2. ✅ Have a Linux server (Ubuntu 20.04+ recommended) ready"
echo "3. ✅ Server has public IP address"
echo "4. ✅ You have sudo access on the server"
echo ""

read -p "Do you have all the above requirements? (y/n): " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Please complete the requirements before proceeding."
    exit 1
fi

echo ""
echo "🌐 DNS Configuration Required:"
echo "================================"
echo "You need to configure DNS for: powertune.safaricom.co.ke"
echo ""
echo "DNS Record Type: A"
echo "Name: powertune"
echo "Value: [YOUR_SERVER_IP]"
echo "TTL: 300 (5 minutes)"
echo ""

read -p "Enter your server's public IP address: " SERVER_IP

if [[ ! $SERVER_IP =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
    echo "❌ Invalid IP address format."
    exit 1
fi

echo ""
echo "📝 DNS Configuration Summary:"
echo "=============================="
echo "Domain: powertune.safaricom.co.ke"
echo "Type: A Record"
echo "Value: $SERVER_IP"
echo ""

echo "🔐 SSL Certificate Setup:"
echo "========================="
echo "After deployment, run this command to get SSL certificate:"
echo "sudo certbot --nginx -d powertune.safaricom.co.ke"
echo ""

echo "🚀 Deployment Steps:"
echo "==================="
echo "1. Upload all files to your server"
echo "2. SSH to your server"
echo "3. Navigate to the application directory"
echo "4. Run: chmod +x deploy.sh"
echo "5. Run: sudo ./deploy.sh"
echo "6. Configure SSL with certbot command above"
echo ""

echo "📊 After Deployment:"
echo "==================="
echo "• Your site will be available at: https://powertune.safaricom.co.ke"
echo "• Admin login: admin / admin"
echo "• Change default password immediately!"
echo "• Monitor logs: sudo journalctl -u powertune -f"
echo ""

echo "✅ Setup helper completed!"
echo "📧 For Safaricom DNS support, contact your IT administrator."
echo ""

# Generate a deployment checklist file
cat > deployment_checklist.txt << EOF
Power Tune Auto Garage - Deployment Checklist
=============================================

Pre-Deployment:
□ DNS configured for powertune.safaricom.co.ke → $SERVER_IP
□ Server has Ubuntu 20.04+
□ Server has public IP: $SERVER_IP
□ SSH access to server available
□ All application files uploaded to server

Deployment:
□ Run: chmod +x deploy.sh
□ Run: sudo ./deploy.sh
□ Configure environment variables in /var/www/powertune/.env
□ Install SSL certificate: sudo certbot --nginx -d powertune.safaricom.co.ke

Post-Deployment:
□ Test site access: https://powertune.safaricom.co.ke
□ Login with admin/admin credentials
□ Change default admin password
□ Test all functionality
□ Monitor logs: sudo journalctl -u powertune -f

Support:
□ Service status: sudo systemctl status powertune
□ Restart service: sudo systemctl restart powertune
□ Nginx status: sudo systemctl status nginx
□ SSL renewal: sudo certbot renew --dry-run
EOF

echo "📄 Deployment checklist saved to: deployment_checklist.txt"
