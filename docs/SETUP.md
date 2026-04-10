# Setup Guide — AI Fitness Coach

## Table of Contents
1. [Firebase Setup](#firebase-setup)
2. [Flutter App Setup](#flutter-app-setup)
3. [Python Model Setup](#python-model-setup)
4. [Running Together](#running-together)

---

## Firebase Setup

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Create a new project named `ai-fitness-coach`
3. Enable **Authentication** → Email/Password and Phone providers
4. Enable **Cloud Firestore** (start in test mode, secure later)
5. Enable **Firebase Analytics**
6. Add an Android and/or iOS app to your Firebase project
7. Download `google-services.json` (Android) → place in `flutter_app/android/app/`
8. Download `GoogleService-Info.plist` (iOS) → place in `flutter_app/ios/Runner/`
9. Run `flutterfire configure` inside the `flutter_app/` directory to generate `firebase_options.dart`

### Firestore Security Rules (recommended for production)
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    match /workouts/{workoutId} {
      allow read, write: if request.auth != null && resource.data.userId == request.auth.uid;
    }
    match /progress/{progressId} {
      allow read, write: if request.auth != null && resource.data.userId == request.auth.uid;
    }
  }
}
```

---

## Flutter App Setup

### Requirements
- Flutter SDK ≥ 3.9.2
- Android Studio or Xcode
- Physical device recommended (camera required for live pose detection)

### Steps

```bash
# Navigate to the Flutter app directory
cd flutter_app

# Install all dependencies
flutter pub get

# Verify setup
flutter doctor

# Run on connected device or emulator
flutter run
```

### Android Permissions
Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.INTERNET" />
```

### iOS Permissions
Add to `ios/Runner/Info.plist`:
```xml
<key>NSCameraUsageDescription</key>
<string>This app uses your camera for real-time pose detection during workouts.</string>
```

---

## Python Model Setup

### Requirements
- Python ≥ 3.9
- Webcam (for desktop testing)
- GPU optional (speeds up NN inference)

### Steps

```bash
# Navigate to the python model directory
cd python_model

# Create and activate virtual environment
python -m venv venv
source venv/bin/activate       # macOS/Linux
# OR
venv\Scripts\activate          # Windows

# Install all dependencies
pip install -r src/requirements.txt

# Run desktop standalone (webcam required)
python src/main.py

# Start REST API server (for Flutter integration)
python src/api_server.py
```

### Retrain Models (Optional)

```bash
# Basic training (Random Forest only)
python src/train_model.py --csv data/dataset.csv

# Full training with neural networks
python src/train_model.py --csv data/dataset.csv --use_nn --epochs 30

# Quick test with 10% of data
python src/train_model.py --csv data/dataset.csv --sample 0.1
```

---

## Running Together

For full integration (Flutter app + Python AI server):

1. **Start Python server** on your development machine:
   ```bash
   cd python_model
   python src/api_server.py
   ```
   Server runs at `http://localhost:8000`

2. **Find your machine's local IP** (for physical device testing):
   ```bash
   # macOS/Linux
   ifconfig | grep inet
   # Windows
   ipconfig
   ```

3. **Update the server URL** in `flutter_app/lib/services/ai_model_service.dart`:
   ```dart
   static const String _baseUrl = 'http://YOUR_LOCAL_IP:8000';
   ```

4. **Run the Flutter app** on your physical device connected to the same WiFi network:
   ```bash
   cd flutter_app
   flutter run
   ```

> **Note**: When the Python server is unreachable, the app automatically falls back to on-device Google ML Kit pose detection. The AI model integration is additive — the app fully works without it.
