#!/bin/bash

# Power Tune Auto Garage - GitHub Setup Script
# Run this script to initialize GitHub repository

echo "🚀 Power Tune Auto Garage - GitHub Setup"
echo "========================================"
echo ""

# Check if git is installed
if ! command -v git &> /dev/null; then
    echo "❌ Git is not installed. Please install Git first."
    exit 1
fi

# Check if we're in the right directory
if [ ! -f "app.py" ]; then
    echo "❌ Error: app.py not found. Please run this script from the application directory."
    exit 1
fi

echo "📋 Current directory: $(pwd)"
echo ""

# Initialize git repository if not already initialized
if [ ! -d ".git" ]; then
    echo "🔧 Initializing Git repository..."
    git init
    echo "✅ Git repository initialized"
else
    echo "✅ Git repository already exists"
fi

# Add .gitignore if it doesn't exist
if [ ! -f ".gitignore" ]; then
    echo "📝 Creating .gitignore file..."
    cat > .gitignore << 'EOF'
# Python
__pycache__/
*.py[cod]
*$py.class
venv/
*.db
.env
.vscode/settings.json
*.log
EOF
    echo "✅ .gitignore created"
fi

# Add all files
echo "📦 Adding files to Git..."
git add .

# Check if there are any changes to commit
if git diff --staged --quiet; then
    echo "ℹ️  No changes to commit"
else
    # Commit files
    echo "💾 Committing files..."
    git commit -m "Initial commit - Power Tune Auto Garage Management System

Features:
- Customer management
- Vehicle tracking
- Service visit management
- Parts inventory
- Invoice generation
- Print-ready templates
- Production deployment ready"
    echo "✅ Files committed to Git"
fi

echo ""
echo "🌐 Next Steps:"
echo "=============="
echo ""
echo "1. 📱 Create GitHub Repository:"
echo "   - Go to https://github.com/new"
echo "   - Repository name: powertune-auto-garage"
echo "   - Description: Power Tune Auto Garage Management System"
echo "   - Set to Public or Private (your choice)"
echo "   - DO NOT initialize with README (we already have files)"
echo ""

echo "2. 🔗 Connect to GitHub:"
read -p "   Enter your GitHub username: " GITHUB_USER
read -p "   Enter repository name (default: powertune-auto-garage): " REPO_NAME
REPO_NAME=${REPO_NAME:-powertune-auto-garage}

echo ""
echo "3. 📤 Push to GitHub:"
echo "   Run these commands:"
echo ""
echo "   git remote add origin https://github.com/$GITHUB_USER/$REPO_NAME.git"
echo "   git branch -M main"
echo "   git push -u origin main"
echo ""

# Ask if user wants to run these commands now
read -p "🚀 Would you like to run these commands now? (y/n): " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🔗 Adding GitHub remote..."
    git remote add origin https://github.com/$GITHUB_USER/$REPO_NAME.git
    
    echo "🌿 Setting main branch..."
    git branch -M main
    
    echo "📤 Pushing to GitHub..."
    git push -u origin main
    
    if [ $? -eq 0 ]; then
        echo ""
        echo "🎉 SUCCESS! Your repository is now on GitHub!"
        echo "🌐 View at: https://github.com/$GITHUB_USER/$REPO_NAME"
        echo ""
        echo "🚀 For Safaricom deployment:"
        echo "1. Set up your server"
        echo "2. Clone from GitHub on server: git clone https://github.com/$GITHUB_USER/$REPO_NAME.git"
        echo "3. Run deployment script: ./deploy.sh"
        echo ""
        echo "📝 GitHub Actions will auto-deploy when you push changes!"
    else
        echo ""
        echo "❌ Push failed. Please check:"
        echo "   - Repository exists on GitHub"
        echo "   - You have push access"
        echo "   - GitHub credentials are correct"
    fi
else
    echo ""
    echo "📝 Manual setup required:"
    echo "========================"
    echo "git remote add origin https://github.com/$GITHUB_USER/$REPO_NAME.git"
    echo "git branch -M main"
    echo "git push -u origin main"
fi

echo ""
echo "✅ GitHub setup completed!"
echo ""
echo "💡 VS Code Integration:"
echo "======================"
echo "   - Use Ctrl+Shift+P → 'Tasks: Run Task' → 'Start Power Tune Server'"
echo "   - Use Ctrl+Shift+P → 'Tasks: Run Task' → 'Git Push to Deploy'"
echo "   - Use F5 to start debugging"
echo ""
