import mediapipe as mp

from src.angle_utils import calculate_angle

# Initialize mediapipe pose module
mp_drawing = mp.solutions.drawing_utils
mp_pose = mp.solutions.pose
# Function to provide exercise-based feedback
def get_feedback(exercise, landmarks):
    feedback = "Hold position..."
    status = "UP"
    good_form = False

    # Body landmarks
    left_shoulder = [landmarks[mp_pose.PoseLandmark.LEFT_SHOULDER.value].x,
                     landmarks[mp_pose.PoseLandmark.LEFT_SHOULDER.value].y]
    left_elbow = [landmarks[mp_pose.PoseLandmark.LEFT_ELBOW.value].x,
                  landmarks[mp_pose.PoseLandmark.LEFT_ELBOW.value].y]
    left_wrist = [landmarks[mp_pose.PoseLandmark.LEFT_WRIST.value].x,
                  landmarks[mp_pose.PoseLandmark.LEFT_WRIST.value].y]
    left_hip = [landmarks[mp_pose.PoseLandmark.LEFT_HIP.value].x,
                landmarks[mp_pose.PoseLandmark.LEFT_HIP.value].y]
    left_knee = [landmarks[mp_pose.PoseLandmark.LEFT_KNEE.value].x,
                 landmarks[mp_pose.PoseLandmark.LEFT_KNEE.value].y]
    left_ankle = [landmarks[mp_pose.PoseLandmark.LEFT_ANKLE.value].x,
                  landmarks[mp_pose.PoseLandmark.LEFT_ANKLE.value].y]

    elbow_angle = calculate_angle(left_shoulder, left_elbow, left_wrist)
    knee_angle = calculate_angle(left_hip, left_knee, left_ankle)
    hip_angle = calculate_angle(left_shoulder, left_hip, left_knee)

    # Exercise-based logic
    if exercise.lower() == "push-up":
        if elbow_angle > 160:
            feedback = "Lower your body"
            status = "UP"
        elif elbow_angle < 70:
            feedback = "Push up!"
            status = "DOWN"
        elif hip_angle < 150:
            feedback = "Keep your back straight!"
        else:
            feedback = "Good form!"
            good_form = True

    elif exercise.lower() == "squat":
        if knee_angle > 170:
            feedback = "Go lower!"
            status = "UP"
        elif knee_angle < 70:
            feedback = "Too low!"
            status = "DOWN"
        else:
            feedback = "Good form!"
            good_form = True

    elif exercise.lower() == "bicep curl":
        if elbow_angle > 160:
            feedback = "Lift your arm up"
            status = "DOWN"
        elif elbow_angle < 40:
            feedback = "Lower your arm slowly"
            status = "UP"
        else:
            feedback = "Nice curl!"
            good_form = True

    return feedback, status, good_form, elbow_angle, knee_angle, hip_angle
