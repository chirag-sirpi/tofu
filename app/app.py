import time
import os
from flask import Flask, request, jsonify
from prometheus_client import generate_latest, CONTENT_TYPE_LATEST, Counter, Histogram

app = Flask(__name__)

# Prometheus Metrics definition
HTTP_REQUESTS_TOTAL = Counter(
    'http_requests_total',
    'Total number of HTTP requests',
    ['method', 'endpoint', 'status']
)

HTTP_REQUEST_LATENCY = Histogram(
    'http_request_duration_seconds',
    'HTTP request duration in seconds',
    ['method', 'endpoint']
)

@app.before_request
def start_timer():
    request.start_time = time.time()

@app.after_request
def log_request(response):
    # Record metrics after request processing
    if hasattr(request, 'start_time'):
        latency = time.time() - request.start_time
        HTTP_REQUEST_LATENCY.labels(
            method=request.method,
            endpoint=request.path
        ).observe(latency)
        
    HTTP_REQUESTS_TOTAL.labels(
        method=request.method,
        endpoint=request.path,
        status=response.status_code
    ).inc()
    
    return response

@app.route('/')
def index():
    return jsonify({
        "status": "healthy",
        "message": "Welcome to Chirag GKE DevSecOps microservice!",
        "time": time.time()
    })

@app.route('/api/process', methods=['POST'])
def process():
    # Simulate processing logic
    data = request.get_json(silent=True) or {}
    duration = data.get('duration', 0.1)
    
    # Bound simulated sleep to prevent DoS
    duration = min(max(float(duration), 0.0), 2.0)
    time.sleep(duration)
    
    return jsonify({
        "status": "success",
        "processed_duration": duration
    })

@app.route('/metrics')
def metrics():
    # Prometheus scraping endpoint
    return generate_latest(), 200, {'Content-Type': CONTENT_TYPE_LATEST}

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 5000))
    # In secure configurations, bind to localhost or let the production server handle interface exposure.
    # We will bind to 0.0.0.0 inside container context.
    app.run(host='0.0.0.0', port=port)
