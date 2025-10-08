#!/usr/bin/env python3
"""
Power Tune Auto Garage - Database Initialization for PythonAnywhere
Run this script ONCE after uploading your code to PythonAnywhere
"""

import sys
import os

# Ensure we can import the app
sys.path.insert(0, '/home/spapsit/powersystem')

from app import app, db, User
from werkzeug.security import generate_password_hash

def create_tables():
    """Create all database tables"""
    print("🔧 Creating database tables...")
    
    with app.app_context():
        try:
            # Drop existing tables (if any)
            db.drop_all()
            print("✅ Dropped existing tables")
            
            # Create all tables
            db.create_all()
            print("✅ Created all tables")
            
            # Create admin user
            admin = User(
                username='admin',
                password_hash=generate_password_hash('admin'),
                role='admin'
            )
            db.session.add(admin)
            db.session.commit()
            
            print("✅ Admin user created")
            print("   Username: admin")
            print("   Password: admin")
            print("   ⚠️  Change password after login!")
            
            # Verify
            user_count = User.query.count()
            print(f"✅ Database ready - {user_count} user(s) created")
            
        except Exception as e:
            print(f"❌ Error: {e}")
            return False
    
    return True

if __name__ == "__main__":
    print("🚀 Power Tune Auto Garage - Database Setup")
    print("==========================================")
    
    success = create_tables()
    
    if success:
        print("\n🎉 Database initialization completed!")
        print("🌐 Your app should now work correctly")
        print("📝 Login with: admin / admin")
    else:
        print("\n❌ Database initialization failed!")
        print("Check the error messages above")
