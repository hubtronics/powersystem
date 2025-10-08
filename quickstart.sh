#!/bin/bash

# Power Tune Auto Garage - Quick Start Script
# This script helps you get started immediately

echo "🚀 Power Tune Auto Garage - Quick Start"
echo "======================================="
echo ""

# Check if we're in the right directory
if [ ! -f "app.py" ]; then
    echo "❌ Error: app.py not found. Please run this script from the application directory."
    exit 1
fi

echo "📋 Current Status:"
echo "=================="
echo "📂 Directory: $(pwd)"
echo "🐍 Python: $(python3 --version 2>/dev/null || echo 'Not found')"
echo "💾 Database: $([ -f 'garage.db' ] && echo 'Exists' || echo 'Will be created')"
echo ""

echo "🔧 Choose your setup option:"
echo "============================"
echo "1. 🏠 Local Development (Quick test)"
echo "2. 🌐 Production Deployment (Safaricom domain)"
echo "3. 🔍 Check Current Deployment Status"
echo "4. 📖 View Full Documentation"
echo ""

read -p "Enter your choice (1-4): " choice

case $choice in
    1)
        echo ""
        echo "🏠 Setting up Local Development..."
        echo "================================="
        
        # Check for virtual environment
        if [ ! -d "venv" ]; then
            echo "📦 Creating virtual environment..."
            python3 -m venv venv
        fi
        
        # Activate virtual environment
        echo "🔄 Activating virtual environment..."
        source venv/bin/activate
        
        # Install requirements
        echo "📥 Installing requirements..."
        pip install -q -r requirements.txt
        
        # Start the application
        echo "🚀 Starting Power Tune Auto Garage..."
        echo "=================================="
        echo ""
        echo "✅ Application will start in a moment..."
        echo "🌐 Open your browser to: http://127.0.0.1:5000"
        echo "👤 Login with: admin / admin"
        echo "⚠️  Change the password after first login!"
        echo ""
        echo "Press Ctrl+C to stop the application"
        echo ""
        
        python app.py
        ;;
        
    2)
        echo ""
        echo "🌐 Production Deployment Setup..."
        echo "================================"
        echo ""
        echo "📖 Opening detailed deployment guide..."
        echo ""
        
        if command -v less >/dev/null 2>&1; then
            less DEPLOYMENT_GUIDE.md
        else
            cat DEPLOYMENT_GUIDE.md
        fi
        
        echo ""
        echo "📞 Next Steps:"
        echo "============="
        echo "1. Contact Safaricom IT for DNS setup"
        echo "2. Prepare your Linux server"
        echo "3. Follow the deployment guide above"
        echo "4. Run: chmod +x deploy.sh && sudo ./deploy.sh"
        ;;
        
    3)
        echo ""
        echo "🔍 Checking Deployment Status..."
        echo "==============================="
        
        if [ -f "check_deployment.sh" ]; then
            chmod +x check_deployment.sh
            ./check_deployment.sh
        else
            echo "❌ Deployment checker not found."
        fi
        ;;
        
    4)
        echo ""
        echo "📖 Documentation Overview..."
        echo "==========================="
        echo ""
        
        echo "📄 Available Documentation:"
        echo "  • README.md - Quick overview"
        echo "  • DEPLOYMENT_GUIDE.md - Step-by-step deployment"
        echo "  • requirements.txt - Local development dependencies"
        echo "  • requirements_prod.txt - Production dependencies"
        echo ""
        
        echo "🔧 Configuration Files:"
        echo "  • gunicorn.conf.py - Production server settings"
        echo "  • nginx_powertune.conf - Web server configuration"
        echo "  • powertune.service - System service configuration"
        echo ""
        
        echo "🛠️ Utility Scripts:"
        echo "  • deploy.sh - Automated deployment"
        echo "  • setup_subdomain.sh - Domain setup helper"
        echo "  • check_deployment.sh - Status verification"
        echo ""
        
        if [ -f "README.md" ]; then
            echo "📖 README Contents:"
            echo "=================="
            head -20 README.md
            echo "..."
            echo "(See README.md for complete information)"
        fi
        ;;
        
    *)
        echo "❌ Invalid choice. Please select 1, 2, 3, or 4."
        exit 1
        ;;
esac

echo ""
echo "🎯 Power Tune Auto Garage Features:"
echo "=================================="
echo "  👥 Customer Management"
echo "  🚗 Vehicle Tracking" 
echo "  🔧 Service Visit Management"
echo "  🔩 Parts Inventory"
echo "  📊 Reporting & Analytics"
echo "  📄 Invoice Generation"
echo "  🖨️ Print-ready Templates"
echo ""
echo "✅ Quick start completed!"
