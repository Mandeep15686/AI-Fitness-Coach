import 'package:flutter/material.dart';
import '../models/pose_data_model.dart';
import '../services/pose_detection_service.dart';
import '../services/exercise_recognition_service.dart';

class PoseProvider with ChangeNotifier {
  final PoseDetectionService _poseDetectionService = PoseDetectionService();
  final ExerciseRecognitionService _exerciseRecognitionService = ExerciseRecognitionService();

  PoseDataModel? _currentPose;
  String? _detectedExercise;
  int _repCount = 0;
  bool _isPoseDetectionActive = false;
  double _formScore = 0.0;

  PoseDataModel? get currentPose => _currentPose;
  String? get detectedExercise => _detectedExercise;
  int get repCount => _repCount;
  bool get isPoseDetectionActive => _isPoseDetectionActive;
  double get formScore => _formScore;

  // Initialize pose detection
  void initialize() {
    _poseDetectionService.initialize();
  }

  // Start pose detection
  void startPoseDetection() {
    _isPoseDetectionActive = true;
    _repCount = 0;
    _exerciseRecognitionService.clear();
    notifyListeners();
  }

  // Stop pose detection
  void stopPoseDetection() {
    _isPoseDetectionActive = false;
    notifyListeners();
  }

  // Process pose from camera
  Future<void> processPose(dynamic cameraImage, int sensorOrientation) async {
    if (!_isPoseDetectionActive) return;

    try {
      // FIX: The 'detectPose' method expects both the camera image and the sensor orientation.
      PoseDataModel? pose = await _poseDetectionService.detectPose(cameraImage, sensorOrientation);

      // Ensure pose is not null before proceeding
      if (pose != null) {
        double visibilityScore = 0.0;

        // Calculate the visibility score from keypoints
        for (var keypoint in pose.keypoints) {
          visibilityScore += keypoint.visibility;
        }

        // Normalize the visibility score to a percentage (0-100)
        if (pose.keypoints.isNotEmpty) {
          visibilityScore = (visibilityScore / pose.keypoints.length) * 100;
        }

        // Use the calculated score as a confidence threshold
        if (visibilityScore > 50) {
          _currentPose = pose;

          // Process for exercise recognition
          _exerciseRecognitionService.processPose(pose);

          // Update detected exercise and rep count
          _detectedExercise = _exerciseRecognitionService.currentExercise;
          _repCount = _exerciseRecognitionService.repetitionCount;

          // Calculate form score
          _formScore = _calculateFormScore(pose);

          notifyListeners();
        }
      }
    } catch (e) {
      // Handle error silently to avoid disrupting the stream
      // You might want to log the error for debugging purposes, e.g., print(e);
    }
  }

  // Calculate form score based on pose quality
  double _calculateFormScore(PoseDataModel pose) {
    // Basic form scoring based on:
    // 1. Keypoint visibility
    // 2. Pose symmetry
    // 3. Joint angles (exercise-specific)

    double visibilityScore = 0.0;
    if (pose.keypoints.isEmpty) {
      return 0.0;
    }

    for (var keypoint in pose.keypoints) {
      visibilityScore += keypoint.visibility;
    }
    visibilityScore = (visibilityScore / pose.keypoints.length) * 100;

    // TODO: Add more sophisticated form analysis
    // For now, return visibility score as form score
    return visibilityScore.clamp(0.0, 100.0);
  }

  // Reset rep counter
  void resetRepCounter() {
    _repCount = 0;
    _exerciseRecognitionService.resetCounter();
    notifyListeners();
  }

  // Get specific keypoint
  KeypointData? getKeypoint(int index) {
    if (_currentPose == null || index < 0 || _currentPose!.keypoints.length <= index) {
      return null;
    }
    return _currentPose!.keypoints[index];
  }

  // Dispose resources
  @override
  void dispose() {
    _poseDetectionService.dispose();
    super.dispose();
  }
}
