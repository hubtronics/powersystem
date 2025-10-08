# PythonAnywhere Troubleshooting - "no such table: user" Error

## 🚨 Problem: Database Tables Not Created
You're getting `sqlite3.OperationalError: no such table: user` because the database tables haven't been created on PythonAnywhere.

## ✅ Solution: Run Database Initialization

### Step 1: Open PythonAnywhere Console
1. Go to your PythonAnywhere dashboard
2. Click "Tasks" or "Consoles"
3. Open a new Bash console

### Step 2: Navigate to Your Project
```bash
cd powersystem
ls -la  # Should see app.py, init_db.py, etc.
```

### Step 3: Run Database Setup
```bash
python3.10 init_db.py
```

You should see:
```
🚀 Power Tune Auto Garage - Database Setup
==========================================
🔧 Creating database tables...
✅ Dropped existing tables
✅ Created all tables
✅ Admin user created
   Username: admin
   Password: admin
   ⚠️  Change password after login!
✅ Database ready - 1 user(s) created

🎉 Database initialization completed!
🌐 Your app should now work correctly
📝 Login with: admin / admin
```

### Step 4: Reload Your Web App
1. Go to PythonAnywhere "Web" tab
2. Click the "Reload" button
3. Visit your site: `https://spapsit.pythonanywhere.com`

## 🔧 Alternative Method (If init_db.py fails)

Open Python console and run:
```python
import sys
sys.path.append('/home/spapsit/powersystem')

from app import app, db, User
from werkzeug.security import generate_password_hash

with app.app_context():
    db.create_all()
    admin = User(username='admin', password_hash=generate_password_hash('admin'), role='admin')
    db.session.add(admin)
    db.session.commit()
    print("Done!")
```

## 🎯 Expected Result
After running the database initialization:
- ✅ Login page should work
- ✅ Username: `admin`, Password: `admin`
- ✅ Dashboard should load without errors
- ✅ All CRUD operations should work

## 📝 Notes
- The database file `garage.db` will be created in your project directory
- You only need to run this ONCE after uploading your code
- If you get permission errors, make sure your project directory is writable
