#!/usr/bin/env python3
"""
WSGI configuration for Power Tune Auto Garage Management System
"""

import os
import sys

# Add the project directory to Python path
sys.path.insert(0, os.path.dirname(__file__))

from app import app

# Initialize database on startup
with app.app_context():
    from app import init_db
    init_db()

if __name__ == "__main__":
    app.run()
