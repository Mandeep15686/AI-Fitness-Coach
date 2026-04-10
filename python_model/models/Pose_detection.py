import cv2
import numpy as np
import mediapipe as mp
import textwrap


# ------------------------- Utility Functions -----------------------------

def calculate_angle(a, b, c):
    """Calculate the angle between three key points."""
    a, b, c = np.array(a), np.array(b), np.array(c)
    radians = np.arctan2(c[1] - b[1], c[0] - b[0]) - np.arctan2(a[1] - b[1], a[0] - b[0])
    angle = np.abs(radians * 180.0 / np.pi)
    if angle > 180.0:
        angle = 360 - angle
    return angle


def draw_wrapped_text(image, text, position, color=(255, 255, 255), font_scale=0.8, thickness=2, max_width=800):
    """Draws multiline text neatly on image."""
    x, y = position
    line_height = int(30 * font_scale)
    wrapped_text = textwrap.wrap(text, width=int(max_width / 15))
    for i, line in enumerate(wrapped_text):
        y_offset = y + i * line_height
        cv2.putText(image, line, (x, y_offset), cv2.FONT_HERSHEY_SIMPLEX, font_scale, color, thickness, cv2.LINE_AA)


# ----------------------- Main Feedback Function -----------------------------

def start_posture_feedback(exercise_name, model=None):
    mp_pose = mp.solutions.pose
    mp_drawing = mp.solutions.drawing_utils
    pose = mp_pose.Pose(min_detection_confidence=0.6, min_tracking_confidence=0.6)

    cap = cv2.VideoCapture(0)
    cv2.namedWindow('AI Fitness Coach', cv2.WINDOW_NORMAL)
    cv2.setWindowProperty('AI Fitness Coach', cv2.WND_PROP_FULLSCREEN, cv2.WINDOW_FULLSCREEN)

    label_map = {0: "Good Form", 1: "Bad Form"}
    stage = None
    counter = 0

    while cap.isOpened():
        ret, frame = cap.read()
        if not ret:
            print("❌ Camera not detected.")
            break

        # Process frame
        image_rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        results = pose.process(image_rgb)
        image = cv2.cvtColor(image_rgb, cv2.COLOR_RGB2BGR)
        h, w, _ = image.shape

        if results.pose_landmarks:
            mp_drawing.draw_landmarks(image, results.pose_landmarks, mp_pose.POSE_CONNECTIONS)

            landmarks = results.pose_landmarks.landmark
            pose_data = np.array([[lm.x, lm.y, lm.z] for lm in landmarks]).flatten().reshape(1, -1)

            # -------------------- AI MODEL PREDICTION --------------------
            ai_feedback = ""
            if model is not None:
                prediction = model.predict(pose_data, verbose=0)
                predicted_class = np.argmax(prediction)
                confidence = np.max(prediction)
                ai_feedback = label_map[predicted_class]
                color = (0, 255, 0) if predicted_class == 0 else (0, 0, 255)
                cv2.putText(image, f"AI: {ai_feedback} ({confidence:.2f})", (30, 50),
                            cv2.FONT_HERSHEY_SIMPLEX, 1, color, 2)

            # ------------------- RULE-BASED LOGIC -----------------------
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

            feedback = "Hold position..."
            form_status = "Analyzing..."

            if exercise_name.lower() == "push-up":
                if elbow_angle > 160:
                    stage = "up"
                    form_status = "Good form" if hip_angle > 150 else "Bad form"
                    if hip_angle < 150:
                        feedback = "Keep your back straight!"
                elif elbow_angle < 70 and stage == "up":
                    stage = "down"
                    counter += 1
                    feedback = "Nice rep!"
                else:
                    feedback = "Lower your body slowly."

            elif exercise_name.lower() == "squat":
                if knee_angle > 170:
                    stage = "up"
                elif knee_angle < 90 and stage == "up":
                    stage = "down"
                    counter += 1
                    feedback = "Good squat!"
                form_status = "Good form" if 80 < knee_angle < 170 else "Bad form"
                if knee_angle >= 170:
                    feedback = "Go lower for full rep."
                elif knee_angle <= 60:
                    feedback = "Too deep, rise slightly."

            elif exercise_name.lower() == "bicep curl":
                if elbow_angle > 160:
                    stage = "down"
                elif elbow_angle < 40 and stage == "down":
                    stage = "up"
                    counter += 1
                    feedback = "Great curl!"
                form_status = "Good form" if 40 < elbow_angle < 160 else "Bad form"

            # ---------------- DISPLAY OVERLAY UI -----------------------
            banner_height = int(h * 0.10)
            cv2.rectangle(image, (0, 0), (w, banner_height), (0, 0, 0), -1)

            cv2.putText(image, f"Exercise: {exercise_name.upper()} | Reps: {counter}",
                        (30, 40), cv2.FONT_HERSHEY_SIMPLEX, 1.0, (0, 255, 255), 2)

            form_color = (0, 255, 0) if "Good" in form_status else (0, 0, 255)
            cv2.putText(image, f"Form: {form_status}", (30, 80),
                        cv2.FONT_HERSHEY_SIMPLEX, 0.9, form_color, 2)

            # Show joint angles
            # cv2.putText(image, f"Elbow: {int(elbow_angle)}°", (w - 180, 40),
            #             cv2.FONT_HERSHEY_SIMPLEX, 0.7, (255, 255, 255), 2)
            # cv2.putText(image, f"Knee: {int(knee_angle)}°", (w - 180, 70),
            #             cv2.FONT_HERSHEY_SIMPLEX, 0.7, (255, 255, 255), 2)
            # cv2.putText(image, f"Hip: {int(hip_angle)}°", (w - 180, 100),
            #             cv2.FONT_HERSHEY_SIMPLEX, 0.7, (255, 255, 255), 2)

            # Feedback suggestions
            feedback_color = (0, 255, 0) if "Nice" in feedback or "Good" in feedback else (0, 0, 255)
            draw_wrapped_text(image, f"Suggestion: {feedback}", (30, banner_height + 70),
                              color=feedback_color, font_scale=0.8, thickness=2, max_width=w - 100)

            if model is not None:
                draw_wrapped_text(image, f"AI Feedback: {ai_feedback}", (30, banner_height + 100),
                                  color=(0, 255, 255), font_scale=0.7, thickness=2, max_width=w - 100)

        cv2.imshow('AI Fitness Coach', image)

        if cv2.waitKey(5) & 0xFF == ord('q'):
            break

    cap.release()
    cv2.destroyAllWindows()
