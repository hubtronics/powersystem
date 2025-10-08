# Power Tune Auto Garage - Step-by-Step Safaricom Domain Setup
===============================================================

## PHASE 1: PREPARE YOUR SYSTEM FOR DEPLOYMENT

### Step 1.1: Check Current System Status
```bash
# First, let's see what we have
pwd
ls -la
python --version
```

### Step 1.2: Create Production Package
```bash
# Create a deployment package
mkdir powertune-deployment
cp -r . powertune-deployment/
cd powertune-deployment
```

### Step 1.3: Test Local System First
```bash
# Activate virtual environment
source venv/bin/activate  # Linux/Mac
# OR
venv\Scripts\activate     # Windows

# Install production requirements
pip install -r requirements_prod.txt

# Test the application
python app.py
# Should see: "Running on http://127.0.0.1:5000"
```

## PHASE 2: SAFARICOM DOMAIN CONFIGURATION

### Step 2.1: Contact Safaricom IT Department
**Who to contact:**
- Safaricom IT Support Desk
- Domain Administrator
- Infrastructure Team

**Request Details:**
```
Subject: DNS Subdomain Configuration Request

Dear Safaricom IT Team,

I need to configure a subdomain for a garage management application:

Requested Domain: powertune.safaricom.co.ke
Purpose: Internal garage management system
Server IP: [YOUR_SERVER_IP]
DNS Record Type: A Record
TTL: 300 seconds

Please configure the following DNS record:
- Name: powertune
- Type: A
- Value: [YOUR_SERVER_IP]
- TTL: 300

Thank you.
```

### Step 2.2: Get Server Information
**You need to know:**
- Server IP address
- Server access credentials (SSH)
- Domain/subdomain to use

## PHASE 3: SERVER PREPARATION

### Step 3.1: Connect to Your Server
```bash
# SSH to your server
ssh username@your-server-ip

# Update the system
sudo apt update && sudo apt upgrade -y
```

### Step 3.2: Install Required Software
```bash
# Install Python and web server components
sudo apt install python3 python3-venv python3-pip nginx supervisor git -y

# Install certbot for SSL certificates
sudo apt install certbot python3-certbot-nginx -y
```

### Step 3.3: Create Application User
```bash
# Create dedicated user for the application
sudo useradd --system --gid www-data --shell /bin/bash --home /var/www/powertune powertune

# Create necessary directories
sudo mkdir -p /var/www/powertune
sudo mkdir -p /var/log/powertune
sudo mkdir -p /var/run/powertune

# Set permissions
sudo chown -R www-data:www-data /var/www/powertune
sudo chown -R www-data:www-data /var/log/powertune
sudo chown -R www-data:www-data /var/run/powertune
```

## PHASE 4: DEPLOY APPLICATION

### Step 4.1: Upload Application Files
```bash
# From your local machine, upload files
scp -r powertune-deployment/* username@your-server-ip:/tmp/

# On the server, move files to application directory
sudo cp -r /tmp/powertune-deployment/* /var/www/powertune/
sudo chown -R www-data:www-data /var/www/powertune
```

### Step 4.2: Setup Python Environment
```bash
# Switch to application directory
cd /var/www/powertune

# Create virtual environment
sudo -u www-data python3 -m venv venv

# Install dependencies
sudo -u www-data ./venv/bin/pip install --upgrade pip
sudo -u www-data ./venv/bin/pip install -r requirements_prod.txt
```

### Step 4.3: Configure Environment Variables
```bash
# Copy and edit environment file
sudo cp .env.example .env
sudo nano .env

# Update with your values:
# SECRET_KEY=your-super-secret-key-here
# FLASK_ENV=production
# DOMAIN=powertune.safaricom.co.ke
```

### Step 4.4: Test Application
```bash
# Test the application works
sudo -u www-data ./venv/bin/python app.py
# Should see: "Running on http://0.0.0.0:5000"
# Press Ctrl+C to stop
```

## PHASE 5: CONFIGURE WEB SERVER

### Step 5.1: Install Systemd Service
```bash
# Copy service file
sudo cp powertune.service /etc/systemd/system/

# Reload systemd and enable service
sudo systemctl daemon-reload
sudo systemctl enable powertune

# Start the service
sudo systemctl start powertune

# Check status
sudo systemctl status powertune
```

### Step 5.2: Configure Nginx
```bash
# Copy nginx configuration
sudo cp nginx_powertune.conf /etc/nginx/sites-available/powertune

# Enable the site
sudo ln -s /etc/nginx/sites-available/powertune /etc/nginx/sites-enabled/

# Test nginx configuration
sudo nginx -t

# Restart nginx
sudo systemctl restart nginx
```

## PHASE 6: SSL CERTIFICATE SETUP

### Step 6.1: Verify DNS Resolution
```bash
# Check if DNS is working
nslookup powertune.safaricom.co.ke
# Should return your server IP
```

### Step 6.2: Install SSL Certificate
```bash
# Get Let's Encrypt certificate
sudo certbot --nginx -d powertune.safaricom.co.ke

# Test auto-renewal
sudo certbot renew --dry-run
```

## PHASE 7: FINAL VERIFICATION

### Step 7.1: Test Website Access
```bash
# Test HTTP (should redirect to HTTPS)
curl -I http://powertune.safaricom.co.ke

# Test HTTPS
curl -I https://powertune.safaricom.co.ke
```

### Step 7.2: Monitor Services
```bash
# Check all services are running
sudo systemctl status powertune
sudo systemctl status nginx

# View application logs
sudo journalctl -u powertune -f
```

### Step 7.3: Access Admin Panel
- Open browser: https://powertune.safaricom.co.ke
- Login: admin / admin
- **IMMEDIATELY change the password!**

## PHASE 8: ONGOING MAINTENANCE

### Daily Operations
```bash
# Check service status
sudo systemctl status powertune

# View logs
sudo journalctl -u powertune -n 50

# Restart if needed
sudo systemctl restart powertune
```

### Updates
```bash
# To update the application
cd /var/www/powertune
sudo -u www-data git pull  # if using git
sudo systemctl restart powertune
```

### Backup
```bash
# Backup database
sudo cp /var/www/powertune/garage.db /backup/garage-$(date +%Y%m%d).db

# Backup application
sudo tar -czf /backup/powertune-$(date +%Y%m%d).tar.gz /var/www/powertune
```

## TROUBLESHOOTING

### Common Issues:

1. **Service won't start:**
   ```bash
   sudo journalctl -u powertune -n 20
   ```

2. **Website not accessible:**
   ```bash
   sudo systemctl status nginx
   sudo nginx -t
   ```

3. **SSL certificate issues:**
   ```bash
   sudo certbot certificates
   sudo certbot renew
   ```

4. **Database errors:**
   ```bash
   sudo -u www-data /var/www/powertune/venv/bin/python -c "from app import init_db; init_db()"
   ```

## SUPPORT CONTACTS

- **Safaricom IT Support:** [Contact number]
- **Server Administrator:** [Your contact]
- **Application Support:** [Your contact]

===============================================================
Ready to proceed? Start with Phase 1!
