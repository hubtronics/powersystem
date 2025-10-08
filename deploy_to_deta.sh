#!/bin/bash

# Power Tune Auto Garage - Deta Space Deployment Script

echo "🚀 Power Tune Auto Garage - Deta Space Deployment"
echo "=================================================="
echo ""

# Check if space CLI is available
if ! command -v space &> /dev/null; then
    echo "❌ Deta Space CLI not found!"
    echo ""
    echo "📥 Please install Deta Space CLI:"
    echo "1. Download from: https://github.com/deta/space-cli/releases/latest"
    echo "2. Get: space-windows-amd64.exe"
    echo "3. Rename to: space.exe"
    echo "4. Place in this folder"
    echo ""
    echo "🔄 Then run this script again!"
    exit 1
fi

echo "✅ Deta Space CLI found!"
echo ""

# Login check
echo "🔐 Checking Deta Space authentication..."
if ! space auth show &> /dev/null; then
    echo "🔑 Please login to Deta Space:"
    space login
fi

echo "✅ Authenticated with Deta Space!"
echo ""

# Initialize project if needed
if [ ! -f ".space/meta" ]; then
    echo "🆕 Initializing new Deta Space project..."
    space new
else
    echo "✅ Deta Space project already initialized!"
fi

echo ""
echo "📤 Deploying Power Tune Auto Garage..."
echo "======================================"

# Push the application
space push

echo ""
echo "🚀 Releasing application..."
echo "=========================="

# Release the application
space release

echo ""
echo "🎉 DEPLOYMENT COMPLETE!"
echo "======================"
echo ""
echo "✅ Your Power Tune Auto Garage is now live on Deta Space!"
echo ""
echo "🌐 Access your app at your Deta Space dashboard:"
echo "   https://deta.space"
echo ""
echo "🔧 To update your app in the future:"
echo "   1. Make your changes"
echo "   2. Run: space push"
echo "   3. Run: space release"
echo ""
echo "🚗 Happy garage management! ✨"
