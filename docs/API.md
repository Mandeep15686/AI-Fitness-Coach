# API Documentation — AI Fitness Coach Python Server

Base URL: `http://localhost:8000`

Interactive docs (when server is running): `http://localhost:8000/docs`

---

## GET /health

Check if the server and models are loaded correctly.

**Response**
```json
{
  "status": "ok",
  "exercise_model_loaded": true,
  "form_model_loaded": true
}
```

---

## POST /predict/exercise

Classify which exercise a user is performing based on their pose landmarks.

**Request Body**
```json
{
  "landmarks": [
    { "x": 0.512, "y": 0.234, "z": 0.001, "visibility": 0.99 },
    ...
  ],
  "exercise_hint": "Squats"
}
```

- `landmarks`: Array of 33 pose landmarks (MediaPipe format)
- `exercise_hint`: Optional string to bias prediction

**Response**
```json
{
  "exercise": "Squats",
  "confidence": 0.9412,
  "all_probabilities": {
    "Bicep Curls": 0.0213,
    "Push-ups": 0.0175,
    "Squats": 0.9412,
    "Shoulder Press": 0.0200
  }
}
```

---

## POST /predict/form

Evaluate whether the user's current pose represents good or bad form.

**Request Body**
```json
{
  "landmarks": [
    { "x": 0.512, "y": 0.234, "z": 0.001, "visibility": 0.99 },
    ...
  ]
}
```

**Response**
```json
{
  "form_quality": "Good Form",
  "confidence": 0.8731,
  "is_good_form": true
}
```

---

## POST /feedback

Get hybrid (rule-based + AI) real-time coaching feedback for a specific exercise.

**Request Body**
```json
{
  "exercise_name": "push-up",
  "landmarks": [
    { "x": 0.512, "y": 0.234, "z": 0.001, "visibility": 0.99 },
    ...
  ]
}
```

**Response**
```json
{
  "exercise": "push-up",
  "feedback": "Keep your back straight!",
  "status": "UP",
  "good_form": false,
  "angles": {
    "elbow": 162.4,
    "knee": 178.1,
    "hip": 143.2
  },
  "ai_form_quality": "Bad Form",
  "ai_confidence": 0.8121
}
```

### Supported exercise_name values
- `push-up`
- `squat`
- `bicep curl`

---

## Flutter Integration Example

```dart
import 'package:ai_fitness_coach/services/ai_model_service.dart';

final aiService = AIModelService();

// Check server availability
final isAvailable = await aiService.checkHealth();

// Get feedback during workout
if (isAvailable && currentPose != null) {
  final result = await aiService.getFeedback(currentPose!, 'push-up');
  if (result != null) {
    print('Feedback: ${result.feedback}');
    print('Good form: ${result.isGoodForm}');
    print('Elbow angle: ${result.elbowAngle}°');
  }
}
```

---

## Error Responses

| Status | Meaning |
|--------|---------|
| 200 | Success |
| 500 | Internal server error (model inference failed) |
| 503 | Service unavailable (model not loaded) |

All errors return:
```json
{
  "detail": "Error description here"
}
```
