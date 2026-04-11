"""
api_server.py
--------------------
FastAPI REST API server that exposes the Python AI pose detection models
as HTTP endpoints, enabling integration with the Flutter mobile app
or any other client over a local network.

Usage:
    python src/api_server.py

Endpoints:
    POST /predict/exercise  - Classify exercise type from pose landmarks
    POST /predict/form      - Evaluate form quality from pose landmarks
    POST /feedback          - Get combined rule-based + AI feedback
    GET  /health            - Health check
"""

import numpy as np
import os
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List, Optional
import uvicorn

# -------------------------
# Load pre-trained models
# -------------------------
exercise_model = None
form_model = None
exercise_scaler = None
form_scaler = None
exercise_label_encoder = None
form_label_encoder = None

def load_models():
    global exercise_model, form_model, exercise_scaler, form_scaler
    global exercise_label_encoder, form_label_encoder

    models_dir = os.path.join(os.path.dirname(__file__), "..", "models")

    try:
        import joblib
        exercise_scaler = joblib.load(os.path.join(models_dir, "exercise_scaler.pkl"))
        form_scaler = joblib.load(os.path.join(models_dir, "form_scaler.pkl"))
        exercise_label_encoder = joblib.load(os.path.join(models_dir, "exercise_label_encoder.pkl"))
        form_label_encoder = joblib.load(os.path.join(models_dir, "form_label_encoder.pkl"))
        print("✅ Scalers and label encoders loaded.")
    except Exception as e:
        print(f"⚠️ Could not load scalers: {e}")

    # Try neural network models first, fall back to random forest
    try:
        from tensorflow.keras.models import load_model
        exercise_model = load_model(os.path.join(models_dir, "exercise_classifier_nn.h5"))
        print("✅ Keras exercise model loaded.")
    except Exception:
        try:
            import joblib
            exercise_model = joblib.load(os.path.join(models_dir, "exercise_classifier_rf.pkl"))
            print("✅ RandomForest exercise model loaded.")
        except Exception as e:
            print(f"⚠️ No exercise model found: {e}")

    try:
        from tensorflow.keras.models import load_model
        form_model = load_model(os.path.join(models_dir, "form_classifier_nn.h5"))
        print("✅ Keras form model loaded.")
    except Exception:
        try:
            import joblib
            form_model = joblib.load(os.path.join(models_dir, "form_classifier_rf.pkl"))
            print("✅ RandomForest form model loaded.")
        except Exception as e:
            print(f"⚠️ No form model found: {e}")


# -------------------------
# FastAPI App
# -------------------------
app = FastAPI(
    title="AI Fitness Coach API",
    description="REST API bridge between Flutter app and Python ML models",
    version="1.0.0"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Restrict in production
    allow_methods=["*"],
    allow_headers=["*"],
)


# -------------------------
# Pydantic Schemas
# -------------------------
class Landmark(BaseModel):
    x: float
    y: float
    z: float = 0.0
    visibility: float = 1.0


class PoseRequest(BaseModel):
    landmarks: List[Landmark]           # 33 pose landmarks from MediaPipe / ML Kit
    exercise_hint: Optional[str] = None # Optional hint from client


class AngleData(BaseModel):
    elbow_angle: float
    knee_angle: float
    hip_angle: float
    shoulder_angle: Optional[float] = None


class FeedbackRequest(BaseModel):
    exercise_name: str
    landmarks: List[Landmark]


# -------------------------
# Utility functions
# -------------------------
def landmarks_to_array(landmarks: List[Landmark]) -> np.ndarray:
    """Convert landmark list to flat numpy array [x0,y0,x1,y1,...]"""
    arr = []
    for lm in landmarks:
        arr.extend([lm.x, lm.y, lm.z])
    return np.array(arr).reshape(1, -1)


def calculate_angle(a, b, c) -> float:
    """Calculate angle at joint b."""
    a, b, c = np.array(a), np.array(b), np.array(c)
    radians = np.arctan2(c[1] - b[1], c[0] - b[0]) - np.arctan2(a[1] - b[1], a[0] - b[0])
    angle = abs(radians * 180.0 / np.pi)
    if angle > 180.0:
        angle = 360 - angle
    return angle


def extract_angles(landmarks: List[Landmark]) -> dict:
    """Extract key joint angles from MediaPipe landmarks."""
    if len(landmarks) < 33:
        return {}

    def lm(idx):
        return [landmarks[idx].x, landmarks[idx].y]

    return {
        "elbow_angle": calculate_angle(lm(11), lm(13), lm(15)),   # shoulder-elbow-wrist
        "knee_angle": calculate_angle(lm(23), lm(25), lm(27)),    # hip-knee-ankle
        "hip_angle": calculate_angle(lm(11), lm(23), lm(25)),     # shoulder-hip-knee
        "shoulder_angle": calculate_angle(lm(23), lm(11), lm(13)) # hip-shoulder-elbow
    }


# -------------------------
# Endpoints
# -------------------------
@app.get("/health")
def health():
    return {
        "status": "ok",
        "exercise_model_loaded": exercise_model is not None,
        "form_model_loaded": form_model is not None,
    }


@app.post("/predict/exercise")
def predict_exercise(request: PoseRequest):
    """Classify which exercise the user is performing."""
    if exercise_model is None:
        raise HTTPException(status_code=503, detail="Exercise model not loaded")

    try:
        pose_array = landmarks_to_array(request.landmarks)

        if exercise_scaler is not None:
            pose_array = exercise_scaler.transform(pose_array)

        # Handle both Keras and sklearn models
        if hasattr(exercise_model, 'predict_proba'):
            # sklearn
            proba = exercise_model.predict_proba(pose_array)[0]
            predicted_idx = int(np.argmax(proba))
            confidence = float(proba[predicted_idx])
        else:
            # Keras
            proba = exercise_model.predict(pose_array, verbose=0)[0]
            predicted_idx = int(np.argmax(proba))
            confidence = float(proba[predicted_idx])

        label = exercise_label_encoder.classes_[predicted_idx] if exercise_label_encoder else str(predicted_idx)

        return {
            "exercise": label,
            "confidence": round(confidence, 4),
            "all_probabilities": {
                cls: round(float(p), 4)
                for cls, p in zip(
                    exercise_label_encoder.classes_ if exercise_label_encoder else [str(i) for i in range(len(proba))],
                    proba
                )
            }
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/predict/form")
def predict_form(request: PoseRequest):
    """Evaluate if the user's form is Good or Bad."""
    if form_model is None:
        raise HTTPException(status_code=503, detail="Form model not loaded")

    try:
        pose_array = landmarks_to_array(request.landmarks)

        if form_scaler is not None:
            pose_array = form_scaler.transform(pose_array)

        if hasattr(form_model, 'predict_proba'):
            proba = form_model.predict_proba(pose_array)[0]
            predicted_idx = int(np.argmax(proba))
            confidence = float(proba[predicted_idx])
        else:
            proba = form_model.predict(pose_array, verbose=0)[0]
            predicted_idx = int(np.argmax(proba))
            confidence = float(proba[predicted_idx])

        label = form_label_encoder.classes_[predicted_idx] if form_label_encoder else ("Good Form" if predicted_idx == 0 else "Bad Form")

        return {
            "form_quality": label,
            "confidence": round(confidence, 4),
            "is_good_form": "good" in label.lower(),
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/feedback")
def combined_feedback(request: FeedbackRequest):
    """
    Get hybrid feedback combining rule-based logic and AI model.
    Returns feedback text, form status, and joint angles.
    """
    try:
        from src.posture_rules import get_feedback as rule_get_feedback

        # Extract angles and rule-based feedback
        angles = extract_angles(request.landmarks)

        # Simulate mediapipe landmarks object for posture_rules
        class MockLandmark:
            def __init__(self, x, y):
                self.x = x
                self.y = y

        class MockLandmarks:
            def __init__(self, lms):
                self._lms = lms
            def __getitem__(self, idx):
                return MockLandmark(self._lms[idx].x, self._lms[idx].y)

        mock_lms = MockLandmarks(request.landmarks)
        rule_feedback, status, good_form, elbow_angle, knee_angle, hip_angle = rule_get_feedback(
            request.exercise_name, mock_lms
        )

        response = {
            "exercise": request.exercise_name,
            "feedback": rule_feedback,
            "status": status,
            "good_form": good_form,
            "angles": {
                "elbow": round(elbow_angle, 1),
                "knee": round(knee_angle, 1),
                "hip": round(hip_angle, 1),
            }
        }

        # Optionally add AI model prediction
        if form_model is not None:
            try:
                pose_array = landmarks_to_array(request.landmarks)
                if form_scaler is not None:
                    pose_array = form_scaler.transform(pose_array)
                if hasattr(form_model, 'predict_proba'):
                    proba = form_model.predict_proba(pose_array)[0]
                else:
                    proba = form_model.predict(pose_array, verbose=0)[0]
                predicted_idx = int(np.argmax(proba))
                ai_label = form_label_encoder.classes_[predicted_idx] if form_label_encoder else ("Good Form" if predicted_idx == 0 else "Bad Form")
                response["ai_form_quality"] = ai_label
                response["ai_confidence"] = round(float(np.max(proba)), 4)
            except Exception:
                pass

        return response
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# -------------------------
# Run server
# -------------------------
if __name__ == "__main__":
    print("\n🤖 AI Fitness Coach API Server")
    print("================================")
    load_models()
    print("\n🚀 Starting server at http://0.0.0.0:8000")
    print("📖 API docs at http://localhost:8000/docs\n")
    uvicorn.run(app, host="0.0.0.0", port=8000)
