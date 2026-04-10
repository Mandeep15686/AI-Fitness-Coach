#!/bin/bash
# retrain.sh — Retrain all AI models

echo "🤖 AI Fitness Coach — Model Retraining"
echo "======================================="

cd "$(dirname "$0")/.."

# Activate virtual environment if it exists
if [ -d "venv" ]; then
    source venv/bin/activate
fi

echo "Starting training pipeline..."
python src/train_model.py --csv data/dataset.csv --use_nn --epochs 25

echo ""
echo "✅ Training complete. Models saved in models/"
