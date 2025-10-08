# Power Tune Auto Garage - Deta Deployment Entry Point

from app import app

# Deta requires the Flask app to be accessible
# This file serves as the entry point for Deta

if __name__ == "__main__":
    app.run(debug=False)

# Export the app for Deta
application = app
