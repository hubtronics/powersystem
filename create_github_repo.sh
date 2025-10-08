#!/bin/bash

# Power Tune Auto Garage - GitHub Repository Setup
# Repository name: powersystem

echo "🚀 Power Tune Auto Garage - GitHub Repository Setup"
echo "===================================================="
echo ""

REPO_NAME="powersystem"
REPO_DESCRIPTION="Power Tune Auto Garage Management System - Complete garage management solution with invoicing, customer management, and vehicle tracking"

echo "📋 Repository Configuration:"
echo "==========================="
echo "📦 Repository Name: $REPO_NAME"
echo "📝 Description: $REPO_DESCRIPTION"
echo "🔒 Visibility: Public"
echo ""

echo "🔧 Setting up local repository..."
echo "================================"

# Configure git if not already configured
echo "⚙️  Configuring Git..."
read -p "Enter your GitHub username: " GITHUB_USERNAME
read -p "Enter your email: " GITHUB_EMAIL

git config --global user.name "$GITHUB_USERNAME"
git config --global user.email "$GITHUB_EMAIL"

echo ""
echo "🌐 Creating GitHub Repository"
echo "============================="
echo ""
echo "⚠️  MANUAL STEPS REQUIRED:"
echo ""
echo "1. Go to https://github.com/new"
echo "2. Repository name: $REPO_NAME"
echo "3. Description: $REPO_DESCRIPTION"
echo "4. Set to Public"
echo "5. Do NOT initialize with README (we already have files)"
echo "6. Click 'Create repository'"
echo ""

read -p "✅ Have you created the repository on GitHub? (y/n): " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Please create the repository first, then run this script again."
    exit 1
fi

echo ""
echo "🔗 Connecting to GitHub..."
echo "=========================="

# Add GitHub remote
GITHUB_URL="https://github.com/$GITHUB_USERNAME/$REPO_NAME.git"
echo "📡 Adding remote: $GITHUB_URL"

git remote add origin "$GITHUB_URL"

# Push to GitHub
echo "📤 Pushing to GitHub..."
git branch -M main
git push -u origin main

echo ""
echo "🎉 SUCCESS!"
echo "==========="
echo ""
echo "✅ Repository created and code pushed to GitHub!"
echo "🌐 Repository URL: https://github.com/$GITHUB_USERNAME/$REPO_NAME"
echo ""
echo "🔄 Future updates:"
echo "=================="
echo "   git add ."
echo "   git commit -m \"Your commit message\""
echo "   git push"
echo ""
echo "📋 Next Steps for Safaricom Deployment:"
echo "======================================="
echo "1. Update deployment scripts with your GitHub URL"
echo "2. Configure GitHub Actions secrets for automatic deployment"
echo "3. Follow the COMPLETE_DEPLOYMENT_GUIDE.md for Safaricom hosting"
echo ""
echo "🚀 Your Power Tune Auto Garage system is now on GitHub!"
