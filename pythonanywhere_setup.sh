#!/bin/bash

# Power Tune Auto Garage - PythonAnywhere Quick Setup Script
# Run this in PythonAnywhere console after uploading your code

echo "🚀 Power Tune Auto Garage - PythonAnywhere Setup"
echo "==============================================="
echo ""

# Get current directory
CURRENT_DIR=$(pwd)
echo "📁 Current directory: $CURRENT_DIR"

# Check if we're in the right directory
if [ ! -f "app.py" ]; then
    echo "❌ app.py not found!"
    echo "Please navigate to your powersystem directory first:"
    echo "   cd powersystem"
    exit 1
fi

echo "✅ Found app.py - we're in the right directory!"
echo ""

# Install Python dependencies
echo "📦 Installing Python dependencies..."
pip3.10 install --user Flask SQLAlchemy Flask-Login Werkzeug

echo ""
echo "🔧 Setting up database..."

# Create database if it doesn't exist
python3.10 -c "
from app import db
try:
    db.create_all()
    print('✅ Database created successfully!')
except Exception as e:
    print(f'Database already exists or error: {e}')
"

echo ""
echo "📝 Next Steps:"
echo "============="
echo ""
echo "1. Go to PythonAnywhere Web tab"
echo "2. Click 'Add a new web app'"
echo "3. Choose 'Manual configuration'"
echo "4. Select 'Python 3.10'"
echo ""
echo "5. Edit your WSGI file with this content:"
echo "   (Copy from pythonanywhere_wsgi.py in your project)"
echo ""
echo "6. Set static files mapping:"
echo "   URL: /static/"
echo "   Directory: $CURRENT_DIR/static/"
echo ""
echo "7. Click 'Reload' and visit your site!"
echo ""
echo "🌐 Your app will be at: https://yourusername.pythonanywhere.com"
echo ""
echo "🎉 Power Tune Auto Garage setup complete! 🚗✨"
