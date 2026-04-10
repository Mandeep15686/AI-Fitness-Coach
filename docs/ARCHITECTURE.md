# System Architecture — AI Fitness Coach

## Overview

The AI Fitness Coach is a hybrid application combining:
- A **Flutter mobile app** for UI, camera access, and on-device ML inference
- A **Python ML backend** for advanced model training and server-side AI inference

Both components can work **independently**. The Flutter app functions fully standalone using Google ML Kit. The Python server adds enhanced accuracy when available.

---

## Component Diagram

```
┌──────────────────────────────────────────────────────────────┐
│                     USER DEVICE (Mobile)                     │
│                                                              │
│  ┌─────────────────────────────────────────────────────┐    │
│  │                  Flutter App                         │    │
│  │                                                      │    │
│  │   ┌──────────┐    ┌──────────────────────────────┐  │    │
│  │   │  Camera   │───▶│  PoseDetectionService        │  │    │
│  │   │ (Device)  │    │  (Google ML Kit on-device)   │  │    │
│  │   └──────────┘    └──────────────┬───────────────┘  │    │
│  │                                  │ PoseDataModel     │    │
│  │                   ┌──────────────▼───────────────┐  │    │
│  │                   │  ExerciseRecognitionService   │  │    │
│  │                   │  • Rule-based rep counting    │  │    │
│  │                   │  • Joint angle analysis       │  │    │
│  │                   └──────────────┬───────────────┘  │    │
│  │                                  │                   │    │
│  │                   ┌──────────────▼───────────────┐  │    │
│  │                   │       PoseProvider            │  │    │
│  │                   │  • repCount, formScore        │  │    │
│  │                   │  • currentPose                │  │    │
│  │                   └──────────────┬───────────────┘  │    │
│  │                                  │                   │    │
│  │   ┌──────────────────────────────▼────────────────┐ │    │
│  │   │              UI Layer                          │ │    │
│  │   │  LiveWorkoutScreen  DashboardScreen            │ │    │
│  │   │  PoseOverlayPainter RepCounterWidget           │ │    │
│  │   └──────────────────────────────────────────────┘ │    │
│  │                                                      │    │
│  │   ┌────────────────────────────────────────────┐    │    │
│  │   │  AIModelService (optional bridge)          │    │    │
│  │   │  • Falls back gracefully if offline         │    │    │
│  │   └──────────────────┬─────────────────────────┘    │    │
│  └─────────────────────-│──────────────────────────────┘    │
└────────────────────────-│────────────────────────────────────┘
                          │ HTTP (local WiFi)
                          │ REST API calls
┌─────────────────────────▼────────────────────────────────────┐
│               DEVELOPMENT MACHINE (Python Server)             │
│                                                              │
│  ┌────────────────────────────────────────────────────┐     │
│  │              FastAPI Server (api_server.py)         │     │
│  │                                                     │     │
│  │   POST /predict/exercise  POST /predict/form        │     │
│  │   POST /feedback          GET  /health              │     │
│  └───────────────────┬────────────────────────────────┘     │
│                       │                                       │
│   ┌───────────────────▼──────────────────────────────┐      │
│   │           Model Inference Pipeline                 │      │
│   │                                                    │      │
│   │  Landmarks → Scaler → ┌─ RandomForest Classifier  │      │
│   │                        └─ Keras NN Classifier      │      │
│   │                            ↓                       │      │
│   │                    Prediction + Confidence         │      │
│   └────────────────────────────────────────────────────┘      │
│                                                               │
│   Models: exercise_classifier_nn.h5  form_classifier_nn.h5   │
│           exercise_classifier_rf.pkl form_classifier_rf.pkl   │
└───────────────────────────────────────────────────────────────┘
                          │
┌─────────────────────────▼────────────────────────────────────┐
│                         Firebase (Cloud)                      │
│                                                              │
│   Firebase Auth        Cloud Firestore                       │
│   • Email/Password     • users collection                    │
│   • Phone OTP          • workouts collection                 │
│                        • progress collection                 │
└──────────────────────────────────────────────────────────────┘
```

---

## Data Flow: Live Workout Session

```
1. Camera captures frame (30 FPS)
         ↓
2. CameraService.startImageStream() emits CameraImage
         ↓
3. PoseProvider.processPose() called per frame
         ↓
4. PoseDetectionService.detectPose()
   → Converts CameraImage to InputImage
   → Google ML Kit processes frame
   → Returns 33 body landmarks (x, y, visibility)
         ↓
5. ExerciseRecognitionService.processPose()
   → Calculates joint angles (elbow, knee, hip, shoulder)
   → Classifies exercise type via rule logic
   → Counts repetitions via state machine (up/down phases)
         ↓
6. [Optional] AIModelService.getFeedback()
   → Sends landmarks to Python server
   → Returns AI-enhanced form quality + feedback text
         ↓
7. PoseProvider notifies listeners:
   repCount, formScore, currentPose, detectedExercise
         ↓
8. LiveWorkoutScreen rebuilds:
   → CameraPreview with PoseOverlayPainter (skeleton overlay)
   → RepCounterWidget (rep count, form score)
         ↓
9. On workout end → WorkoutProvider.endWorkout()
   → CalorieService calculates calories (MET formula)
   → FirebaseService.saveWorkout() persists to Firestore
```

---

## State Management

Provider pattern with the following providers:

| Provider | Responsibility |
|----------|---------------|
| `AuthProvider` | Authentication state, user data |
| `PoseProvider` | Pose detection, rep counting, form score |
| `WorkoutProvider` | Active workout session, history |
| `ThemeProvider` | Light/dark mode |
| `OnboardingProvider` | First-time user flow state |
| `MealPlanProvider` | AI meal plan generation |
| `PrivacyProvider` | Consent, data settings |

---

## Security Architecture

```
User Input → EncryptionService (AES-256)
                ↓
           FlutterSecureStorage (device keychain)
                ↓
           Encrypted Firestore fields:
           • user.age
           • user.height  
           • user.weight
           • workout.caloriesBurned
           • workout.averageFormScore
```

All sensitive biometric data is encrypted before being written to Firebase, ensuring data privacy even if Firestore credentials are compromised.

---

## Pose Detection Technical Details

- **On-device**: Google ML Kit Pose Detection (accurate mode, stream)
  - 33 landmarks per frame
  - ~25-30 FPS on modern devices
  - Works fully offline
  
- **Server-side**: MediaPipe (Python)
  - Same 33 landmark schema
  - Enhanced with trained classifiers
  - Used for desktop testing and advanced inference

### Landmark Indices (MediaPipe/ML Kit)

| Index | Landmark | Used For |
|-------|----------|---------|
| 11 | left_shoulder | Elbow angle, shoulder angle, hip angle |
| 13 | left_elbow | Elbow angle |
| 15 | left_wrist | Elbow angle |
| 23 | left_hip | Knee angle, hip angle, shoulder angle |
| 25 | left_knee | Knee angle |
| 27 | left_ankle | Knee angle |
