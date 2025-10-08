# Power Tune Auto Garage Management System

A comprehensive garage management system for tracking customers, vehicles, service visits, and parts inventory.

## 🚀 Production Deployment to Safaricom Subdomain

### Prerequisites

1. **Linux Server** (Ubuntu 20.04+ recommended)
2. **Python 3.8+**
3. **Nginx**
4. **Domain Access** - Access to configure DNS for `powertune.safaricom.co.ke`

### Quick Deployment

1. **Upload files to your server**
2. **Run the deployment script:**
   ```bash
   chmod +x deploy.sh
   sudo ./deploy.sh
   ```

3. **Configure environment variables:**
   ```bash
   sudo cp .env.example /var/www/powertune/.env
   sudo nano /var/www/powertune/.env
   ```

### Default Login Credentials

- **Username:** admin
- **Password:** admin

**⚠️ IMPORTANT:** Change the default password immediately after first login!

### Local Development

```bash
python -m venv venv
venv\Scripts\activate    # Windows
source venv/bin/activate # Linux/Mac
pip install -r requirements.txt
python app.py
# Open http://127.0.0.1:5000
```

### Features

- 👥 Customer Management
- 🚗 Vehicle Tracking  
- 🔧 Service Visit Management
- 🔩 Parts Inventory
- 📊 Reporting and Analytics
- 📄 Invoice Generation
- 🖨️ Print-friendly Templates
- 🌓 Theme Switching (Light/Dark)

**Power Tune Auto Garage Management System**
