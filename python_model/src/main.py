"""
main.py
--------------------
Launches the AI Fitness Coach posture detection system.
Combines:
 - Real-time Mediapipe-based posture tracking
 - Hybrid AI classifier (Good/Bad form detection)
 - Conditional logic feedback system
"""

from tensorflow.keras.models import load_model
from models.Pose_detection import start_posture_feedback


def main():
    print("\n🤖 Welcome to AI Fitness Coach!")
    print("This system gives real-time posture feedback using your webcam.")
    print("-------------------------------------------------------------")
    print("Available exercises: push-up, squat, bicep curl\n")

    # Ask user which exercise to start
    exercise = input("Enter exercise name: ").strip().lower()

    # Load the trained neural network model
    try:
        model_path = "models/exercise_classifier_nn.h5"  # update if you saved in .keras format
        print("\n📦 Loading AI posture classification model...")
        model = load_model(model_path)
        print("✅ Model loaded successfully!\n")
    except Exception as e:
        print(f"⚠️ Could not load AI model: {e}")
        print("➡️ Running only with rule-based (conditional logic) feedback.")
        model = None

    # Start the posture detection and feedback system
    print(f"🎥 Starting {exercise.upper()} posture detection...")
    print("💡 Press 'q' to quit at any time.\n")

    start_posture_feedback(exercise, model)


if __name__ == "__main__":
    main()
