# Power Tune Auto Garage - Vercel Deployment Entry Point

import sys
import os

# Add the parent directory to the path so we can import app
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from app import app

# Export the Flask app for Vercel (no changes to original app)
# Vercel will automatically handle the WSGI interface
