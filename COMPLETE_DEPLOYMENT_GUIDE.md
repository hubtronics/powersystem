# Power Tune Auto Garage - Complete Deployment Guide

This guide covers deploying your Power Tune Auto Garage system from GitHub to Safaricom subdomain.

## 🚀 Quick Start

### Option 1: One-Command Deployment
```bash
curl -fsSL https://raw.githubusercontent.com/your-username/powertune-garage/main/deploy_from_github.sh | bash
```

### Option 2: Manual Deployment
1. Clone your repository on the server
2. Run `./deploy_from_github.sh`
3. Follow the interactive prompts

## 📋 Prerequisites

### On Your Local Machine:
- ✅ VS Code with Python extension
- ✅ Git installed
- ✅ GitHub account

### On Safaricom Server:
- Ubuntu/Debian Linux server
- Root or sudo access
- Domain/subdomain pointing to server IP

## 🛠️ Development Workflow

### 1. Local Development
```bash
# Start development server
Ctrl+Shift+P -> "Tasks: Run Task" -> "Start Flask Server"

# Or manually:
python -m venv venv
venv\Scripts\activate  # Windows
source venv/bin/activate  # Linux/Mac
pip install -r requirements.txt
python app.py
```

### 2. Push to GitHub
```bash
# Use VS Code task
Ctrl+Shift+P -> "Tasks: Run Task" -> "Git Push to GitHub"

# Or manually:
git add .
git commit -m "Your commit message"
git push origin main
```

### 3. Automatic Deployment
GitHub Actions will automatically deploy to your Safaricom server when you push to main branch.

## 🌐 Safaricom Hosting Setup

### Step 1: Get Safaricom Hosting
1. Visit [Safaricom Business Portal](https://business.safaricom.co.ke)
2. Navigate to Digital Services > Web Hosting
3. Purchase hosting plan with subdomain support
4. Get your server details (IP, SSH access)

### Step 2: Configure DNS
1. In Safaricom control panel, add subdomain:
   - Subdomain: `powertune`
   - Points to: Your server IP
   - Type: A Record

### Step 3: Deploy Application
1. SSH to your Safaricom server
2. Run deployment script:
```bash
wget https://raw.githubusercontent.com/your-username/powertune-garage/main/deploy_from_github.sh
chmod +x deploy_from_github.sh
./deploy_from_github.sh
```

## ⚙️ GitHub Actions Setup

### 1. Repository Secrets
In your GitHub repository, go to Settings > Secrets and variables > Actions:

Add these secrets:
- `HOST`: Your Safaricom server IP
- `USERNAME`: SSH username (usually root)
- `SSH_KEY`: Your private SSH key
- `PORT`: SSH port (usually 22)

### 2. Generate SSH Key
```bash
# On your local machine
ssh-keygen -t rsa -b 4096 -c "your-email@example.com"

# Copy public key to server
ssh-copy-id user@your-server-ip

# Copy private key to GitHub secrets
cat ~/.ssh/id_rsa
```

## 📁 Project Structure

```
powertune-garage/
├── app.py                      # Main Flask application
├── requirements.txt            # Development dependencies
├── requirements_prod.txt       # Production dependencies
├── wsgi.py                    # WSGI entry point
├── gunicorn.conf.py           # Gunicorn configuration
├── powertune.service          # Systemd service file
├── nginx_powertune.conf       # Nginx configuration
├── deploy_from_github.sh      # Deployment script
├── .env.example               # Environment variables template
├── .gitignore                 # Git ignore rules
├── static/
│   └── logo.png              # Power Tune logo
├── templates/                 # Jinja2 templates
├── .github/workflows/
│   └── deploy.yml            # GitHub Actions workflow
└── .vscode/
    ├── tasks.json            # VS Code tasks
    ├── launch.json           # Debug configuration
    └── settings.json         # VS Code settings
```

## 🔧 Configuration Files

### Environment Variables (.env)
```bash
FLASK_ENV=production
SECRET_KEY=your-secret-key
DOMAIN=powertune.safaricom.co.ke
DATABASE_URL=sqlite:///garage.db
```

### Nginx Configuration
- Serves static files directly
- Proxies dynamic requests to Gunicorn
- SSL/HTTPS ready
- Gzip compression enabled

### Systemd Service
- Auto-start on boot
- Automatic restart on failure
- Proper logging
- Resource limits

## 🚀 Deployment Process

1. **Code Push**: Push to GitHub main branch
2. **GitHub Actions**: Triggers deployment workflow
3. **Server Update**: Pulls latest code, restarts services
4. **Health Check**: Verifies deployment success

## 🔍 Monitoring & Logs

### Service Status
```bash
sudo systemctl status powertune
```

### Application Logs
```bash
sudo journalctl -u powertune -f
```

### Nginx Logs
```bash
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/nginx/error.log
```

## 🔒 Security Features

- ✅ SSL/HTTPS encryption
- ✅ Secure session cookies
- ✅ CSRF protection
- ✅ SQL injection prevention
- ✅ File upload restrictions
- ✅ Rate limiting ready

## 🔄 Updates & Maintenance

### Automatic Updates
GitHub Actions handles automatic deployment on code changes.

### Manual Updates
```bash
cd /var/www/powertune
sudo -u www-data git pull
sudo systemctl restart powertune
```

### Backup Database
```bash
sudo cp /var/www/powertune/garage.db /backup/garage_$(date +%Y%m%d_%H%M%S).db
```

## 🎯 Production Checklist

- [ ] GitHub repository created and configured
- [ ] Safaricom hosting purchased and configured
- [ ] DNS subdomain pointing to server
- [ ] SSH access to server working
- [ ] GitHub Actions secrets configured
- [ ] SSL certificate installed
- [ ] Default admin password changed
- [ ] Database backup scheduled
- [ ] Monitoring configured

## 🆘 Troubleshooting

### Common Issues

**Service won't start:**
```bash
sudo journalctl -u powertune --since "5 minutes ago"
```

**Nginx errors:**
```bash
sudo nginx -t
sudo systemctl status nginx
```

**Permission issues:**
```bash
sudo chown -R www-data:www-data /var/www/powertune
```

**Database issues:**
```bash
cd /var/www/powertune
sudo -u www-data venv/bin/python -c "from app import create_tables; create_tables()"
```

## 📞 Support

For Safaricom hosting support:
- Phone: 0722 002 002
- Email: business@safaricom.co.ke
- Portal: https://business.safaricom.co.ke

## 🎉 Success!

Your Power Tune Auto Garage system should now be live at:
**https://powertune.safaricom.co.ke**

Default login:
- Username: `admin`
- Password: `admin` (⚠️ Change immediately!)

Happy garage management! 🚗✨
