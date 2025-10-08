# Power Tune Auto Garage - PythonAnywhere WSGI Configuration

import sys
import os

# Add your project directory to sys.path
# Replace 'yourusername' with your actual PythonAnywhere username
project_home = '/home/yourusername/powersystem'
if project_home not in sys.path:
    sys.path = [project_home] + sys.path

# Import your Flask app
from app import app as application

# Set the secret key for production
application.secret_key = 'powertune-garage-secret-2024'

# Ensure database path is absolute
import os
if not os.path.isabs(application.config.get('DATABASE', '')):
    application.config['DATABASE'] = os.path.join(project_home, 'garage.db')

if __name__ == "__main__":
    application.run()
