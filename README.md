# 🏋️ AI Fitness Coach — Complete Project

A full-stack AI fitness app combining a **Flutter mobile app** (UI + on-device pose detection via Google ML Kit) with a **Python ML backend** (model training + REST API server).

---

## 📁 Project Structure

```
AI_Fitness_Coach/
│
├── ai_fitness-coach/                     Flutter Mobile Application
│   ├── lib/
│   │   ├── core/
│   │   │   ├── constants/           colors.dart, app_constants.dart
│   │   │   ├── routes/              app_routes.dart
│   │   │   └── theme/               app_theme.dart (dark athletic)
│   │   ├── models/                  user, workout, pose, exercise, progress
│   │   ├── providers/               7 state providers (Provider pattern)
│   │   ├── screens/                 19 screens across all features
│   │   │   ├── auth/                Login, Signup (3-step), Phone OTP
│   │   │   ├── home/                Dashboard (bottom-tab shell)
│   │   │   ├── workout/             Selection + Live workout with HUD
│   │   │   ├── progress/            Analytics + chart
│   │   │   ├── profile/             Editable profile
│   │   │   ├── meal_plan/           AI meal plan generator
│   │   │   └── settings/            Settings, Security, Privacy
│   │   ├── services/                11 services incl. AI bridge
│   │   ├── widgets/                 5 reusable components
│   │   └── utils/                   validators, helpers
│   ├── assets/images/
│   └── pubspec.yaml
│
├── python_model/                    Python AI/ML Backend
│   ├── models/                      Trained .h5 and .pkl files
│   ├── src/
│   │   ├── main.py                  Desktop standalone (webcam)
│   │   ├── api_server.py            FastAPI REST server
│   │   ├── train_model.py           Model training pipeline
│   │   ├── angle_utils.py           Joint angle utilities
│   │   ├── posture_rules.py         Rule-based feedback
│   │   └── requirements.txt
│   ├── data/dataset.csv
│   └── scripts/
│
└── docs/
    ├── SETUP.md
    ├── ARCHITECTURE.md
    └── API.md
```

---

## 🐛 Bug Fixes Applied

| # | Bug | Fix |
|---|-----|-----|
| 1 | `LateInitializationError` — PoseDetector used before init | `initialize()` now called inside `startPoseDetection()` |
| 2 | Zero-division crash in CalorieService when duration = 0 | Added `.clamp(1, 99999)` guard |
| 3 | `_isBodyHorizontal()` comparing normalized coords (0–1) to pixel threshold (50) | Fixed threshold to `0.1` |
| 4 | Workout always saved 0 reps — `endWorkout()` never received counts | `repCount` and `formScore` passed explicitly |
| 5 | Null crash on `setDetails` in `WorkoutModel.fromMap()` | Added null-safe fallback `<SetData>[]` |
| 6 | `app_theme.dart` syntax error — `GoogleFonts.barlow TextTheme(` | Fixed to correct `TextTheme(...)` constructor |
| 7 | `ThemeSwitcher` crashed referencing missing asset images | Replaced with standard Flutter `Switch` widget |
| 8 | Wrong import paths in `splash_screen.dart` | Fixed `../../` to `../` (file is in `lib/screens/`, not a subdirectory) |
| 9 | Deprecated `WillPopScope` in Flutter 3.x | Replaced with `PopScope` |
| 10 | Workout sets always 0 — `completeSet()` was never called | `endWorkout()` now auto-creates one `SetData` from session |
| 11 | `Colors.white15` doesn't exist in Flutter | Fixed to `Colors.white.withOpacity(0.15)` |
| 12 | Meal plan service had syntax error `'recipe\\'':` | Fixed key to `'recipe':` |
| 13 | No fallback when Firebase not configured | `endWorkout()` uses anonymous `UserModel` if `currentUser` is null |
| 14 | Keypoints had no stable ordering (HashMap iteration order) | Sorted landmarks by `.index` before building keypoints list |
| 15 | Exercise recognition used per-exercise `_isInDownPosition` shared across exercises | Added `setTargetExercise()` to lock recognition + reset state |

---

## 🎨 UI Redesign

**Design Language:** Dark Athletic — inspired by elite sports tech (Whoop, Nike Training, Strava)

- **Palette:** Near-black backgrounds (`#0A0A12`) with electric green (`#00E676`), cyan (`#00D4FF`), and fire orange (`#FF6B00`) accents
- **Typography:** Barlow Condensed — bold, athletic, high-impact weight hierarchy (900 for display, 700 for headings, 400 for body)
- **Layout:** Bottom tab navigation (Home, Workout, Progress, Profile), hero gradient cards, compact grid stats
- **Live Workout HUD:** Glassmorphism overlay panel, animated rep counter (spring scale on new rep), color-coded form bar, real-time feedback bubbles
- **Pose Overlay:** Colored skeleton with exercise-specific accent colors, joint circles with white outline
- **Onboarding:** 3-step signup with animated progress bar and radio card selectors

---

## 🚀 Quick Start

### Flutter App
```bash
cd flutter_app
flutter pub get
# Configure Firebase (see docs/SETUP.md)
flutter run
```

### Python Model Server
```bash
cd python_model
python -m venv venv && source venv/bin/activate
pip install -r src/requirements.txt
python src/api_server.py   # Starts at http://localhost:8000
```

---

## 🤖 Supported Exercises

| Exercise | Rep Counting | Form Feedback | Calorie Estimation |
|----------|:-----------:|:------------:|:-----------------:|
| Squats | ✅ | ✅ | ✅ |
| Push-ups | ✅ | ✅ | ✅ |
| Bicep Curls | ✅ | ✅ | ✅ |
| Shoulder Press | ✅ | ✅ | ✅ |
| Lunges | ✅ | Basic | ✅ |
| Planks | ⏱ Timed | ✅ | ✅ |

---

## 🔐 Security
- AES-256 encryption for biometric fields (age, height, weight, calories)
- Encryption key stored in device keychain via `flutter_secure_storage`
- Firebase Auth with email/password + phone OTP 2FA
- GDPR-compliant data export & deletion

---

See `docs/SETUP.md` for Firebase configuration and full setup instructions.
