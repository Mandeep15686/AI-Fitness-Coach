#!/bin/bash
# start_server.sh — Start the FastAPI REST API server

echo "🚀 AI Fitness Coach — API Server"
echo "================================="

cd "$(dirname "$0")/.."

# Activate virtual environment if it exists
if [ -d "venv" ]; then
    source venv/bin/activate
fi

echo "Starting server at http://0.0.0.0:8000"
echo "API docs at http://localhost:8000/docs"
echo ""
python src/api_server.py
