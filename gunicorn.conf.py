# Gunicorn configuration file for Power Tune Auto Garage
import multiprocessing

# Server socket
bind = "0.0.0.0:5000"
backlog = 2048

# Worker processes
workers = multiprocessing.cpu_count() * 2 + 1
worker_class = "sync"
worker_connections = 1000
timeout = 30
keepalive = 2

# Restart workers after this many requests, to help prevent memory leaks
max_requests = 1000
max_requests_jitter = 50

# Logging
accesslog = "/var/log/powertune/access.log"
errorlog = "/var/log/powertune/error.log"
loglevel = "info"
access_log_format = '%(h)s %(l)s %(u)s %(t)s "%(r)s" %(s)s %(b)s "%(f)s" "%(a)s"'

# Process naming
proc_name = "powertune_garage"

# Server mechanics
daemon = False
pidfile = "/var/run/powertune/powertune.pid"
user = "www-data"
group = "www-data"
tmp_upload_dir = None

# SSL (if using HTTPS)
# keyfile = "/path/to/keyfile"
# certfile = "/path/to/certfile"
