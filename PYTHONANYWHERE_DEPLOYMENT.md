# Power Tune Auto Garage - PythonAnywhere Deployment Guide

## 🚀 Deploy to PythonAnywhere - Super Easy!

### Why PythonAnywhere?
- ✅ **Built for Python/Flask** - Perfect for your garage system
- ✅ **Free tier available** - Great for getting started
- ✅ **No complex configuration** - Just upload and run
- ✅ **Built-in file manager** - Edit files directly in browser
- ✅ **Console access** - Full terminal access
- ✅ **Custom domains** - Connect your Safaricom domain

## 📋 Step-by-Step Deployment

### Step 1: Create PythonAnywhere Account
1. Go to [pythonanywhere.com](https://www.pythonanywhere.com)
2. Sign up for free account
3. Choose "Beginner" plan (free)

### Step 2: Upload Your Code
**Option A: Git Clone (Recommended)**
```bash
# In PythonAnywhere console
git clone https://github.com/hubtronics/powersystem.git
cd powersystem
```

**Option B: Upload Files**
- Use PythonAnywhere file manager
- Upload your project folder

### Step 3: Install Dependencies
```bash
# In PythonAnywhere console
cd powersystem
pip3.10 install --user -r requirements.txt
```

### Step 4: Create Web App
1. Go to "Web" tab in PythonAnywhere dashboard
2. Click "Add a new web app"
3. Choose "Manual configuration"
4. Select "Python 3.10"

### Step 5: Configure WSGI File
Edit `/var/www/yourusername_pythonanywhere_com_wsgi.py`:

```python
import sys
import os

# Add your project directory to sys.path
project_home = '/home/yourusername/powersystem'
if project_home not in sys.path:
    sys.path = [project_home] + sys.path

# Import your Flask app
from app import app as application

# Set the secret key
application.secret_key = 'powertune-garage-secret-2024'

if __name__ == "__main__":
    application.run()
```

### Step 6: Set Static Files
In PythonAnywhere web app settings:
- **Static files mapping:**
  - URL: `/static/`
  - Directory: `/home/yourusername/powersystem/static/`

### Step 7: Reload and Test
1. Click "Reload" button in web app
2. Visit: `https://yourusername.pythonanywhere.com`

## 🌐 Your App Will Be Live At:
`https://yourusername.pythonanywhere.com`

## 🔧 Database Setup
Your SQLite database will work automatically! PythonAnywhere supports SQLite out of the box.

## 🎯 Custom Domain (Optional)
For paid accounts, you can connect your Safaricom domain:
1. Point your domain CNAME to `yourusername.pythonanywhere.com`
2. Configure in PythonAnywhere web settings

## 🔄 Updates
To update your app:
```bash
cd powersystem
git pull
# Click "Reload" in web app
```

## 💡 PythonAnywhere Benefits:
- ✅ **Perfect for Flask** - Built for Python web apps
- ✅ **Free SSL** - HTTPS included
- ✅ **Always-on tasks** - For background processes
- ✅ **Console access** - Full Linux terminal
- ✅ **File editor** - Edit code in browser
- ✅ **Database support** - SQLite, MySQL, PostgreSQL

## 🎉 Result:
Your **Power Tune Auto Garage** running professionally on PythonAnywhere! 🚗✨

Much simpler than other hosting options!
