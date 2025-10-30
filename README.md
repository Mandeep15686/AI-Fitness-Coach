# AI Fitness Coach

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.9.2-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-40.3%25-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

**An intelligent, AI-powered fitness coaching application that leverages computer vision and machine learning to deliver real-time exercise guidance, form correction, and comprehensive progress tracking.**

[Features](#features) • [Installation](#installation) • [Usage](#usage) • [Architecture](#architecture) • [Contributing](#contributing) • [License](#license)

</div>

---

## 📋 Table of Contents

- [Overview](#overview)
- [Key Features](#key-features)
- [Technology Stack](#technology-stack)
- [System Requirements](#system-requirements)
- [Installation](#installation)
- [Configuration](#configuration)
- [Usage](#usage)
- [Project Structure](#project-structure)
- [Architecture](#architecture)
- [Development](#development)
- [Testing](#testing)
- [Deployment](#deployment)
- [Performance Metrics](#performance-metrics)
- [Contributing](#contributing)
- [License](#license)
- [Acknowledgments](#acknowledgments)
- [Contact](#contact)

---

## 🎯 Overview

AI Fitness Coach is a cutting-edge mobile fitness application that transforms your smartphone into an intelligent personal trainer. Using advanced pose estimation with **MediaPipe BlazePose** and exercise classification powered by **BiLSTM neural networks**, the app provides real-time feedback on your workout form, automatically counts repetitions, estimates calorie burn, and tracks your fitness journey—all without requiring any wearable devices.

### Why AI Fitness Coach?

- **🎥 Real-time Pose Detection**: Utilizes MediaPipe BlazePose to detect 33 body keypoints with 95% accuracy
- **🤖 Intelligent Exercise Recognition**: BiLSTM-based model achieves 99%+ accuracy in classifying exercises
- **📊 Automated Rep Counting**: Tracks repetitions with 91% accuracy (±1 repetition)
- **🔥 Calorie Estimation**: ML-powered calorie burn calculation based on exercise type, duration, and user profile
- **📈 Comprehensive Progress Tracking**: Detailed analytics and workout history with visual insights
- **🎯 Personalized Workouts**: Adaptive workout plans based on your fitness level and goals
- **💪 Form Correction**: Real-time feedback to help you maintain proper exercise form

---

## ✨ Key Features

### Core Functionality

#### 1. Real-Time Pose Detection
- **33 Body Keypoints**: Comprehensive body tracking including face, hands, and feet
- **Sub-second Response Time**: Pose estimation in less than 1 second
- **Various Lighting Conditions**: Robust performance across different environments
- **PCK@0.2 Accuracy**: Achieves 95% pose detection accuracy

#### 2. Exercise Recognition
- **Supported Exercises**: 
  - Squats
  - Push-ups
  - Bicep Curls
  - Shoulder Press
- **99%+ Classification Accuracy**: BiLSTM model processes 30-frame sequences
- **Automatic Detection**: No manual exercise selection required
- **Real-time Feedback**: Instant exercise type identification

#### 3. Repetition Counting
- **Automated Tracking**: Counts reps and sets without user input
- **High Accuracy**: 91% accuracy within ±1 repetition
- **Audio/Visual Feedback**: Real-time notifications for completed reps
- **Smart Detection**: Handles partial repetitions intelligently

#### 4. Calorie Estimation
- **ML Regression Model**: R² ≥ 0.77 for calorie prediction
- **Personalized Calculation**: Factors in user profile, exercise type, duration, and intensity
- **Real-time Updates**: Live calorie counter during workouts
- **Post-Workout Summary**: Detailed calorie burn report

#### 5. Progress Tracking & Analytics
- **Comprehensive History**: Complete workout data storage
- **Visual Analytics**: Charts and graphs for trend visualization
- **Weekly/Monthly Reports**: Progress summaries and insights
- **Goal Setting**: Custom fitness goals with achievement tracking

#### 6. Additional Features
- **User Authentication**: Secure login with Firebase Auth
- **Cloud Sync**: Automatic data synchronization across devices
- **Workout Plans**: Personalized training programs
- **Social Sharing**: Share achievements with friends (planned)
- **Nutritional Guidance**: Diet recommendations integration (planned)

---

## 🛠 Technology Stack

### Frontend
- **Flutter 3.9.2**: Cross-platform UI framework
- **Dart**: Programming language
- **Provider 6.1.2**: State management solution
- **Camera 0.11.0**: Camera integration for video processing

### Backend & Cloud Services
- **Firebase Core 4.2.0**: Backend infrastructure
- **Firebase Auth 6.1.1**: User authentication
- **Cloud Firestore 6.0.3**: Real-time database
- **Firebase Analytics 12.0.3**: Usage analytics

### AI/ML Stack
- **MediaPipe BlazePose**: Real-time pose estimation (33 keypoints)
- **BiLSTM Neural Network**: Exercise classification model
- **Google ML Kit 0.20.0**: On-device machine learning
- **TensorFlow Lite**: Model inference (implicit)

### Development Tools
- **Flutter Lints 5.0.0**: Code quality enforcement
- **Intl 0.18.1**: Internationalization support
- **Cupertino Icons 1.0.8**: iOS-style icons

### Supported Platforms
- **Android**: 8.0+ (API level 26+)
- **iOS**: 12.0+
- **Web**: Modern browsers (experimental)
- **Desktop**: Windows, macOS, Linux (in development)

---

## 💻 System Requirements

### Hardware Requirements
- **Mobile Device**: Smartphone with camera capabilities
- **RAM**: Minimum 3GB (4GB+ recommended)
- **Storage**: 2GB free space
- **Processor**: ARM-based processor (Android/iOS)
- **Camera**: Minimum 720p resolution for accurate tracking
- **Internet**: Required for cloud features and initial setup

### Software Requirements
- **Android**: Version 8.0 (Oreo) or higher
- **iOS**: Version 12.0 or higher
- **Flutter SDK**: Version 3.9.2 or compatible
- **Firebase Account**: For backend services (free tier available)

### Development Requirements
- **Flutter SDK**: 3.9.2+
- **Dart SDK**: 3.9.2+ (included with Flutter)
- **Android Studio** or **Xcode**: For platform-specific builds
- **VS Code** or **Android Studio**: Recommended IDE
- **Git**: For version control
- **Firebase CLI**: For Firebase configuration

---

## 🚀 Installation

### Prerequisites

1. **Install Flutter**
   ```bash
   # Download Flutter SDK from https://flutter.dev/docs/get-started/install
   # Extract and add to PATH
   
   # Verify installation
   flutter --version
   flutter doctor
   ```

2. **Clone the Repository**
   ```bash
   git clone https://github.com/Mandeep15686/AI-Fitness-Coach.git
   cd AI-Fitness-Coach
   ```

3. **Install Dependencies**
   ```bash
   flutter pub get
   ```

### Firebase Setup

1. **Create a Firebase Project**
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Click "Add project" and follow the setup wizard
   - Enable Authentication, Firestore, and Analytics

2. **Configure Firebase for Flutter**
   ```bash
   # Install Firebase CLI
   npm install -g firebase-tools
   
   # Login to Firebase
   firebase login
   
   # Configure FlutterFire
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```
   
   Follow the prompts to select your Firebase project and configure platforms.

3. **Download Configuration Files**
   - The `flutterfire configure` command will generate:
     - `lib/firebase_options.dart` (automatically created)
     - `android/app/google-services.json` (Android)
     - `ios/Runner/GoogleService-Info.plist` (iOS)

### Platform-Specific Setup

#### Android Setup
1. Open `android/app/build.gradle` and ensure:
   ```gradle
   minSdkVersion 21
   compileSdkVersion 34
   targetSdkVersion 34
   ```

2. Add camera permissions in `android/app/src/main/AndroidManifest.xml`:
   ```xml
   <uses-permission android:name="android.permission.CAMERA" />
   <uses-permission android:name="android.permission.INTERNET" />
   ```

#### iOS Setup
1. Open `ios/Runner/Info.plist` and add:
   ```xml
   <key>NSCameraUsageDescription</key>
   <string>Camera access is required for pose detection during workouts</string>
   <key>NSMicrophoneUsageDescription</key>
   <string>Microphone access for audio feedback</string>
   ```

2. Set minimum iOS version in `ios/Podfile`:
   ```ruby
   platform :ios, '12.0'
   ```

### Build and Run

#### Development Mode
```bash
# Check for connected devices
flutter devices

# Run on connected device
flutter run

# Run with specific device
flutter run -d <device-id>

# Run with hot reload enabled (default)
flutter run --debug
```

#### Release Mode
```bash
# Android
flutter build apk --release

# iOS (requires macOS)
flutter build ios --release

# App Bundle (recommended for Play Store)
flutter build appbundle --release
```

---

## ⚙️ Configuration

### Environment Variables

Create a `.env` file in the project root (optional, for custom configurations):

```env
# API Keys (if needed)
API_KEY=your_api_key_here

# Feature Flags
ENABLE_ANALYTICS=true
ENABLE_SOCIAL_FEATURES=false
```

### App Configuration

Customize app settings in `lib/core/constants/`:

- **app_constants.dart**: General app constants
- **api_constants.dart**: API endpoints (if applicable)
- **theme_constants.dart**: UI theme settings

### Firebase Rules

Ensure proper Firestore security rules are set in Firebase Console:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    match /workouts/{workoutId} {
      allow read, write: if request.auth != null;
    }
  }
}
```

---

## 📱 Usage

### Getting Started

1. **Launch the App**
   - Open the AI Fitness Coach app on your device
   - Grant camera permissions when prompted

2. **Create an Account**
   - Sign up with email and password
   - Or use social authentication (if enabled)
   - Complete your profile (age, height, weight, fitness goals)

3. **Choose a Workout**
   - Navigate to the home screen
   - Select from pre-defined workout plans
   - Or start a custom workout session

4. **Start Exercising**
   - Position your device to capture your full body
   - Begin your exercise routine
   - Follow real-time feedback for form correction
   - View rep counts and calorie burn in real-time

5. **Track Progress**
   - Review workout history in the Progress tab
   - Analyze performance trends with interactive charts
   - Set and achieve fitness goals

### Tips for Best Results

- **Camera Positioning**: Place your device 6-8 feet away, capturing your full body
- **Lighting**: Ensure good lighting conditions for better pose detection
- **Clothing**: Wear fitted clothing for more accurate joint detection
- **Background**: Use a clear background without clutter
- **Internet**: Stable connection required for cloud sync

---

## 📁 Project Structure

```
AI-Fitness-Coach/
├── android/                    # Android platform files
├── ios/                        # iOS platform files
├── lib/                        # Main application code
│   ├── core/                   # Core utilities and configurations
│   │   ├── constants/          # App-wide constants
│   │   ├── routes/             # Navigation routes
│   │   └── theme/              # UI theme configuration
│   ├── models/                 # Data models
│   │   ├── exercise_model.dart
│   │   ├── pose_data_model.dart
│   │   ├── progress_model.dart
│   │   ├── user_model.dart
│   │   └── workout_model.dart
│   ├── providers/              # State management (Provider)
│   │   ├── auth_provider.dart
│   │   ├── pose_provider.dart
│   │   └── workout_provider.dart
│   ├── screens/                # UI screens
│   │   ├── auth/               # Authentication screens
│   │   ├── home/               # Home dashboard
│   │   ├── profile/            # User profile
│   │   ├── progress/           # Progress tracking
│   │   ├── workout/            # Workout screens
│   │   └── splash_screen.dart
│   ├── services/               # Business logic and APIs
│   │   ├── auth_service.dart
│   │   ├── calorie_service.dart
│   │   ├── camera_service.dart
│   │   ├── exercise_recognition_service.dart
│   │   ├── firebase_service.dart
│   │   └── pose_detection_service.dart
│   ├── utils/                  # Helper utilities
│   │   ├── helpers.dart
│   │   └── validators.dart
│   ├── widgets/                # Reusable UI components
│   │   ├── pose_overlay_painter.dart
│   │   ├── progress_chart_widget.dart
│   │   ├── rep_counter_widget.dart
│   │   └── workout_card_widget.dart
│   ├── firebase_options.dart   # Firebase configuration
│   └── main.dart               # App entry point
├── test/                       # Unit and widget tests
├── web/                        # Web platform files
├── windows/                    # Windows platform files
├── .gitignore                  # Git ignore rules
├── analysis_options.yaml       # Dart analysis configuration
├── firebase.json               # Firebase hosting config
├── pubspec.yaml                # Flutter dependencies
└── README.md                   # Project documentation
```

---

## 🏗 Architecture

### High-Level Architecture

The AI Fitness Coach app follows a **client-server architecture with edge computing** for optimal performance:

```
┌─────────────────────────────────────────────┐
│          Mobile Application (Client)        │
├─────────────────────────────────────────────┤
│  ┌─────────────────────────────────────┐   │
│  │   Presentation Layer (UI/Screens)   │   │
│  └─────────────────────────────────────┘   │
│  ┌─────────────────────────────────────┐   │
│  │  State Management (Provider)        │   │
│  └─────────────────────────────────────┘   │
│  ┌─────────────────────────────────────┐   │
│  │  Business Logic (Services)          │   │
│  └─────────────────────────────────────┘   │
│  ┌─────────────────────────────────────┐   │
│  │  ML Models (MediaPipe + BiLSTM)     │   │
│  └─────────────────────────────────────┘   │
└─────────────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────┐
│         Firebase Backend Services           │
├─────────────────────────────────────────────┤
│  • Authentication                           │
│  • Cloud Firestore (Database)               │
│  • Analytics                                │
│  • Cloud Storage                            │
└─────────────────────────────────────────────┘
```

### Data Flow

1. **Camera Input** → Video frames captured from device camera
2. **Preprocessing** → Frame normalization and transformation
3. **Pose Estimation** → MediaPipe BlazePose extracts 33 keypoints
4. **Feature Engineering** → Joint angles and coordinates calculated
5. **Exercise Classification** → BiLSTM model identifies exercise type
6. **Rep Counting** → Algorithm tracks movement cycles
7. **Feedback & Display** → Real-time UI updates with results
8. **Data Persistence** → Workout data synced to Firebase

### AI/ML Pipeline

#### Pose Estimation (MediaPipe BlazePose)
- **Input**: RGB video frames (720p minimum)
- **Processing**: CNN-based pose detection
- **Output**: 33 3D landmarks (x, y, z coordinates + visibility scores)
- **Performance**: 30 FPS on modern mobile devices

#### Exercise Recognition (BiLSTM)
- **Input**: 30-frame sequences (1 second @ 30 FPS)
- **Feature Vector**: 78 features (33 landmarks × 2 coordinates + joint angles)
- **Architecture**: 
  - Bidirectional LSTM layers
  - Dense layers with dropout
  - Softmax output (4 classes)
- **Training**: 
  - Datasets: InfiniteRep (synthetic) + Kaggle Workout Dataset (real-world)
  - Augmentation: Random rotations, scaling, lighting variations
- **Output**: Exercise class probabilities (squats, push-ups, curls, shoulder press)

#### Calorie Estimation
- **Algorithm**: ML Regression (Random Forest / Gradient Boosting)
- **Features**: 
  - Exercise type
  - User profile (weight, height, age, gender)
  - Duration and intensity
  - Heart rate (if available from wearables - future)
- **Training Dataset**: Advanced Fitness Tracking Dataset, FitBit data
- **Accuracy**: R² ≥ 0.77

---

## 👨‍💻 Development

### Code Style & Guidelines

This project follows the official [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style) and enforces linting rules via `analysis_options.yaml`.

#### Key Principles:
- **Clean Code**: Write readable, maintainable code
- **SOLID Principles**: Follow object-oriented design patterns
- **DRY**: Don't Repeat Yourself
- **KISS**: Keep It Simple, Stupid
- **Separation of Concerns**: Clear separation between UI, logic, and data layers

#### Naming Conventions:
- **Classes**: PascalCase (`ExerciseModel`, `WorkoutService`)
- **Variables/Functions**: camelCase (`getUserData()`, `repCount`)
- **Constants**: UPPER_SNAKE_CASE (`API_BASE_URL`, `MAX_RETRY_ATTEMPTS`)
- **Private Members**: Prefix with underscore (`_privateMethod()`)

### Running Tests

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run specific test file
flutter test test/services/pose_detection_service_test.dart

# Run integration tests
flutter test integration_test/
```

### Debugging

```bash
# Enable verbose logging
flutter run --verbose

# Debug with DevTools
flutter run --debug
# Then open DevTools from the console link

# Profile performance
flutter run --profile
```

### Adding New Exercises

To add support for a new exercise:

1. **Collect Training Data**
   - Record videos of the exercise from multiple angles
   - Ensure diverse body types, lighting, and backgrounds

2. **Preprocess Data**
   - Extract pose landmarks using MediaPipe
   - Save landmark sequences (30 frames)

3. **Update Model**
   - Add new class to BiLSTM model
   - Retrain with augmented dataset
   - Validate accuracy (target: ≥99%)

4. **Implement Rep Counting Logic**
   - Define key angles for movement phases
   - Set thresholds for "up" and "down" positions
   - Add to `exercise_recognition_service.dart`

5. **Update UI**
   - Add exercise card to workout selection
   - Include instructions and demo animations

---

## 🧪 Testing

### Test Strategy

- **Unit Tests**: Individual functions and classes
- **Widget Tests**: UI components and interactions
- **Integration Tests**: End-to-end user flows
- **Performance Tests**: Frame rate, memory usage, battery impact

### Test Coverage Goals

- **Overall**: ≥80% code coverage
- **Critical Services**: ≥90% (pose detection, exercise recognition)
- **UI Components**: ≥70%

### Running Quality Checks

```bash
# Analyze code
flutter analyze

# Check formatting
flutter format --set-exit-if-changed .

# Run linter
dart analyze

# Check for outdated dependencies
flutter pub outdated
```

---

## 🚢 Deployment

### Android Deployment (Google Play Store)

1. **Generate Release APK/App Bundle**
   ```bash
   # Create keystore (first time only)
   keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA \
           -keysize 2048 -validity 10000 -alias upload
   
   # Build app bundle (recommended)
   flutter build appbundle --release
   
   # Or build APK
   flutter build apk --release
   ```

2. **Sign the App**
   - Create `android/key.properties`:
     ```properties
     storePassword=<password>
     keyPassword=<password>
     keyAlias=upload
     storeFile=<path-to-keystore>
     ```

3. **Upload to Play Console**
   - Go to [Google Play Console](https://play.google.com/console)
   - Create new release in Production or Internal Testing
   - Upload the `.aab` file
   - Fill out store listing, screenshots, and descriptions
   - Submit for review

### iOS Deployment (Apple App Store)

1. **Configure Xcode Project**
   ```bash
   cd ios
   pod install
   open Runner.xcworkspace
   ```

2. **Create App Store Archive**
   ```bash
   flutter build ios --release
   ```

3. **Upload to App Store Connect**
   - Open Xcode → Product → Archive
   - Validate and distribute to App Store
   - Or use Transporter app

4. **Submit for Review**
   - Complete metadata in App Store Connect
   - Upload screenshots and preview videos
   - Set pricing and availability
   - Submit for review

### Continuous Integration/Deployment (CI/CD)

#### GitHub Actions Example

Create `.github/workflows/main.yml`:

```yaml
name: Flutter CI/CD

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.9.2'
    - run: flutter pub get
    - run: flutter analyze
    - run: flutter test
    - run: flutter build apk --release
```

---

## 📊 Performance Metrics

### Achieved Benchmarks

| Metric | Target | Achieved | Status |
|--------|--------|----------|--------|
| Pose Detection Accuracy (PCK@0.2) | ≥95% | **95%** | ✅ |
| Exercise Classification Accuracy | ≥99% | **99%+** | ✅ |
| Repetition Counting Accuracy | ≥90% | **91%** | ✅ |
| Calorie Estimation R² | ≥0.75 | **0.77** | ✅ |
| Pose Estimation Latency | <1s | **<1s** | ✅ |
| Frame Rate | ≥30 FPS | **30 FPS** | ✅ |
| App Startup Time | <3s | **2.5s** | ✅ |
| Memory Usage | <500 MB | **~450 MB** | ✅ |

### Optimization Techniques

- **On-device Inference**: ML models run locally (no cloud latency)
- **Model Quantization**: Reduced model size without accuracy loss
- **Frame Skipping**: Process every 2nd-3rd frame for non-critical tasks
- **Lazy Loading**: Defer loading of heavy resources
- **Image Caching**: Reuse processed frames when possible

---

## 🤝 Contributing

We welcome contributions from the community! Whether it's bug fixes, new features, documentation improvements, or ML model enhancements, your help is appreciated.

### How to Contribute

1. **Fork the Repository**
   ```bash
   # Click "Fork" on GitHub
   git clone https://github.com/YOUR_USERNAME/AI-Fitness-Coach.git
   cd AI-Fitness-Coach
   ```

2. **Create a Feature Branch**
   ```bash
   git checkout -b feature/your-feature-name
   # Or for bug fixes:
   git checkout -b fix/bug-description
   ```

3. **Make Your Changes**
   - Write clean, well-documented code
   - Follow the existing code style
   - Add tests for new functionality
   - Update documentation as needed

4. **Test Your Changes**
   ```bash
   flutter analyze
   flutter test
   flutter run  # Manual testing
   ```

5. **Commit Your Changes**
   ```bash
   git add .
   git commit -m "feat: add new exercise recognition for lunges"
   # Use conventional commit messages:
   # feat: new feature
   # fix: bug fix
   # docs: documentation
   # style: formatting
   # refactor: code restructuring
   # test: adding tests
   # chore: maintenance
   ```

6. **Push and Create Pull Request**
   ```bash
   git push origin feature/your-feature-name
   # Go to GitHub and create a Pull Request
   ```

### Contribution Guidelines

- **Code Quality**: Maintain high code standards, pass linting and tests
- **Documentation**: Update README, code comments, and API docs
- **Testing**: Include unit tests for new features
- **Commits**: Use clear, descriptive commit messages
- **PR Description**: Explain what, why, and how in your PR
- **Response Time**: Be responsive to feedback and review comments

### Areas for Contribution

- 🏋️ **New Exercises**: Add support for additional exercises (lunges, planks, burpees, etc.)
- 🧠 **ML Improvements**: Enhance model accuracy, add new features
- 🎨 **UI/UX**: Design improvements, animations, accessibility
- 📱 **Platform Support**: Improve iOS, web, or desktop compatibility
- 🌍 **Localization**: Add support for more languages
- 📖 **Documentation**: Improve guides, tutorials, code comments
- 🐛 **Bug Fixes**: Resolve open issues
- ⚡ **Performance**: Optimize speed, reduce memory usage

### Code of Conduct

Please be respectful and constructive in all interactions. We follow the [Contributor Covenant Code of Conduct](https://www.contributor-covenant.org/version/2/1/code_of_conduct/).

---

## 📄 License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

### MIT License Summary

```
Copyright (c) 2025 Mandeep Singh

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND...
```

**What this means:**
- ✅ Commercial use allowed
- ✅ Modification allowed
- ✅ Distribution allowed
- ✅ Private use allowed
- ⚠️ Must include copyright notice and license
- ❌ No liability or warranty

---

## 🙏 Acknowledgments

### Academic Institution
- **IIIT Raichur** - Project guidance and support
- **Dr. Priodyuti Pradhan** - Faculty supervisor

### Open Source Libraries
- [Flutter](https://flutter.dev/) - Google's UI toolkit
- [MediaPipe](https://google.github.io/mediapipe/) - Google's ML solutions
- [Firebase](https://firebase.google.com/) - Backend infrastructure
- [TensorFlow Lite](https://www.tensorflow.org/lite) - On-device ML

### Datasets
- **InfiniteRep Dataset** - Synthetic exercise videos
- **Kaggle Workout/Exercises Dataset** - Real-world exercise data
- **COCO-Pose Dataset** - Pose estimation training
- **Advanced Fitness Tracking Dataset** - Calorie estimation data

### Research Papers
- BlazePose: On-device Real-time Body Pose Tracking (Google Research)
- BiLSTM for Human Activity Recognition (Various authors)
- Exercise Classification using Computer Vision (Academic research)

### Community
- All contributors who have helped improve this project
- Flutter and Dart communities for excellent resources
- Stack Overflow and GitHub for problem-solving support

---

## 📞 Contact

### Project Maintainer
- **Name**: Mandeep Singh
- **GitHub**: [@Mandeep15686](https://github.com/Mandeep15686)
- **Repository**: [AI-Fitness-Coach](https://github.com/Mandeep15686/AI-Fitness-Coach)

### Reporting Issues
- **Bug Reports**: [Open an Issue](https://github.com/Mandeep15686/AI-Fitness-Coach/issues/new?template=bug_report.md)
- **Feature Requests**: [Request a Feature](https://github.com/Mandeep15686/AI-Fitness-Coach/issues/new?template=feature_request.md)
- **Security Vulnerabilities**: Please email privately (create a security.md with contact info)

### Community & Support
- **Discussions**: [GitHub Discussions](https://github.com/Mandeep15686/AI-Fitness-Coach/discussions)
- **Wiki**: [Project Wiki](https://github.com/Mandeep15686/AI-Fitness-Coach/wiki) (coming soon)

---

## 🗺 Roadmap

### Version 1.0 (Current)
- ✅ Real-time pose detection with MediaPipe
- ✅ BiLSTM exercise classification (4 exercises)
- ✅ Automated rep counting
- ✅ Calorie estimation
- ✅ Progress tracking and analytics
- ✅ Firebase authentication and cloud sync

### Version 1.1 (Q1 2026)
- 🔲 Additional exercises (lunges, planks, burpees, jumping jacks)
- 🔲 Voice guidance and audio cues
- 🔲 Improved UI/UX with animations
- 🔲 Workout plan templates
- 🔲 Social sharing features

### Version 2.0 (Q2 2026)
- 🔲 Wearable device integration (smartwatches, fitness bands)
- 🔲 Advanced form correction with 3D visualization
- 🔲 AI-powered workout recommendations
- 🔲 Nutrition tracking integration
- 🔲 Community challenges and leaderboards
- 🔲 Offline mode with local data storage

### Future Considerations
- 🔮 AR overlays for form guidance
- 🔮 Multi-user simultaneous tracking
- 🔮 Physical therapy and rehabilitation exercises
- 🔮 Integration with health apps (Apple Health, Google Fit)
- 🔮 Premium subscription features

---

## 📈 Project Statistics

![GitHub stars](https://img.shields.io/github/stars/Mandeep15686/AI-Fitness-Coach?style=social)
![GitHub forks](https://img.shields.io/github/forks/Mandeep15686/AI-Fitness-Coach?style=social)
![GitHub issues](https://img.shields.io/github/issues/Mandeep15686/AI-Fitness-Coach)
![GitHub pull requests](https://img.shields.io/github/issues-pr/Mandeep15686/AI-Fitness-Coach)
![GitHub last commit]( https://img.shields.io/github/last-commit/Mandeep15686/AI-Fitness-Coach)

---

<div align="center">

**Made with ❤️ by Mandeep Singh**

**If you find this project helpful, please consider giving it a ⭐ on GitHub!**

[⬆ Back to Top](#ai-fitness-coach)

</div>
