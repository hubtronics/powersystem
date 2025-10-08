# Power Tune Auto Garage - GitHub Repository Setup (PowerShell)
# Repository name: powersystem

Write-Host "🚀 Power Tune Auto Garage - GitHub Repository Setup" -ForegroundColor Green
Write-Host "====================================================" -ForegroundColor Green
Write-Host ""

$REPO_NAME = "powersystem"
$REPO_DESCRIPTION = "Power Tune Auto Garage Management System - Complete garage management solution with invoicing, customer management, and vehicle tracking"

Write-Host "📋 Repository Configuration:" -ForegroundColor Yellow
Write-Host "===========================" -ForegroundColor Yellow
Write-Host "📦 Repository Name: $REPO_NAME"
Write-Host "📝 Description: $REPO_DESCRIPTION"
Write-Host "🔒 Visibility: Public"
Write-Host ""

# Get GitHub credentials
$GITHUB_USERNAME = Read-Host "Enter your GitHub username"
$GITHUB_EMAIL = Read-Host "Enter your email"

Write-Host ""
Write-Host "⚙️  Configuring Git..." -ForegroundColor Cyan
git config --global user.name "$GITHUB_USERNAME"
git config --global user.email "$GITHUB_EMAIL"

Write-Host ""
Write-Host "🌐 Creating GitHub Repository" -ForegroundColor Yellow
Write-Host "=============================" -ForegroundColor Yellow
Write-Host ""
Write-Host "⚠️  MANUAL STEPS REQUIRED:" -ForegroundColor Red
Write-Host ""
Write-Host "1. Go to https://github.com/new"
Write-Host "2. Repository name: $REPO_NAME"
Write-Host "3. Description: $REPO_DESCRIPTION"
Write-Host "4. Set to Public"
Write-Host "5. Do NOT initialize with README (we already have files)"
Write-Host "6. Click 'Create repository'"
Write-Host ""

$continue = Read-Host "✅ Have you created the repository on GitHub? (y/n)"

if ($continue -ne "y" -and $continue -ne "Y") {
    Write-Host "❌ Please create the repository first, then run this script again." -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "🔗 Connecting to GitHub..." -ForegroundColor Cyan
Write-Host "==========================" -ForegroundColor Cyan

# Add GitHub remote
$GITHUB_URL = "https://github.com/$GITHUB_USERNAME/$REPO_NAME.git"
Write-Host "📡 Adding remote: $GITHUB_URL"

git remote add origin $GITHUB_URL

# Push to GitHub
Write-Host "📤 Pushing to GitHub..."
git branch -M main
git push -u origin main

Write-Host ""
Write-Host "🎉 SUCCESS!" -ForegroundColor Green
Write-Host "===========" -ForegroundColor Green
Write-Host ""
Write-Host "✅ Repository created and code pushed to GitHub!" -ForegroundColor Green
Write-Host "🌐 Repository URL: https://github.com/$GITHUB_USERNAME/$REPO_NAME"
Write-Host ""
Write-Host "🔄 Future updates:" -ForegroundColor Yellow
Write-Host "=================="
Write-Host "   git add ."
Write-Host "   git commit -m `"Your commit message`""
Write-Host "   git push"
Write-Host ""
Write-Host "📋 Next Steps for Safaricom Deployment:" -ForegroundColor Yellow
Write-Host "======================================="
Write-Host "1. Update deployment scripts with your GitHub URL"
Write-Host "2. Configure GitHub Actions secrets for automatic deployment"
Write-Host "3. Follow the COMPLETE_DEPLOYMENT_GUIDE.md for Safaricom hosting"
Write-Host ""
Write-Host "🚀 Your Power Tune Auto Garage system is now on GitHub!" -ForegroundColor Green
