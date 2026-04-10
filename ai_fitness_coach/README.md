# AI Fitness Coach 🏋️‍♂️🤖

An AI-powered fitness application built with Flutter and Firebase that provides real-time pose detection, rep counting, and personalized coaching.

## ✨ Features

- **🤖 AI Pose Detection**: Real-time body tracking using advanced pose estimation.
- **🔁 Automatic Rep Counting**: Tracks your sets and reps automatically with high accuracy.
- **🔥 Calorie Tracking**: MET-based estimation to monitor your energy expenditure.
- **📊 Progress Analytics**: Detailed insights into your fitness journey and improvements.
- **🍱 Meal Planning**: Personalized meal suggestions based on your fitness goals.
- **🔒 Secure Data**: User data is encrypted before being stored in the cloud.

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (latest version recommended)
- Dart SDK
- Android Studio / VS Code
- A Firebase Project

### Setup Instructions

1.  **Clone the Repository**
    ```bash
    git clone https://github.com/yourusername/ai_fitness_coach.git
    cd ai_fitness_coach
    ```

2.  **Install Dependencies**
    ```bash
    flutter pub get
    ```

3.  **Firebase Configuration**
    - Add your `google-services.json` to `android/app/`.
    - Add your `GoogleService-Info.plist` to `ios/Runner/`.
    - The `lib/firebase_options.dart` file has been pre-configured for the project, but ensure your Firebase project matches the bundle IDs:
        - Android: `com.example.ai_fitness_coach`
        - iOS: `com.example.aiFitnessCoach`

4.  **Firestore Security Rules**
    Deploy the following rules to your Firebase Console to allow users to access their own data:
    ```javascript
    service cloud.firestore {
      match /databases/{database}/documents {
        match /users/{userId} {
          allow read, write: if request.auth != null && request.auth.uid == userId;
        }
        match /workouts/{workoutId} {
          allow read, write: if request.auth != null;
        }
        match /progress/{progressId} {
          allow read, write: if request.auth != null;
        }
      }
    }
    ```

5.  **Run the App**
    ```bash
    flutter run
    ```

## 🛠 Tech Stack

- **Frontend**: Flutter & Dart
- **Backend**: Firebase Authentication, Cloud Firestore
- **State Management**: Provider
- **Design**: Material 3 with a dark-themed fitness aesthetic
- **Encryption**: AES encryption for sensitive user data

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.
