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
  String? _feedbackMessage;

  PoseDataModel? get currentPose => _currentPose;
  String? get detectedExercise => _detectedExercise;
  int get repCount => _repCount;
  bool get isPoseDetectionActive => _isPoseDetectionActive;
  double get formScore => _formScore;
  String? get feedbackMessage => _feedbackMessage;

  // FIX: Always initialize before starting
  void startPoseDetection({String? targetExercise}) {
    _poseDetectionService.initialize(); // <-- was missing, causing LateInitializationError
    _isPoseDetectionActive = true;
    _repCount = 0;
    _formScore = 0.0;
    _feedbackMessage = null;
    _currentPose = null;
    _exerciseRecognitionService.clear();
    if (targetExercise != null) {
      _exerciseRecognitionService.setTargetExercise(targetExercise);
    }
    notifyListeners();
  }

  void stopPoseDetection() {
    _isPoseDetectionActive = false;
    notifyListeners();
  }

  Future<void> processPose(dynamic cameraImage, int sensorOrientation) async {
    if (!_isPoseDetectionActive) return;

    try {
      final PoseDataModel? pose = await _poseDetectionService.detectPose(
        cameraImage, sensorOrientation,
      );

      if (pose != null && pose.keypoints.isNotEmpty) {
        final double avgVisibility = pose.averageConfidence;

        if (avgVisibility > 0.4) {
          _currentPose = pose;
          _exerciseRecognitionService.processPose(pose);
          _detectedExercise = _exerciseRecognitionService.currentExercise;
          _repCount = _exerciseRecognitionService.repetitionCount;
          _formScore = _calculateFormScore(pose);
          _feedbackMessage = _exerciseRecognitionService.getFeedbackMessage(pose);
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('PoseProvider.processPose error: $e');
    }
  }

  double _calculateFormScore(PoseDataModel pose) {
    if (pose.keypoints.isEmpty) return 0.0;
    double sum = 0.0;
    for (final kp in pose.keypoints) {
      sum += kp.visibility;
    }
    return ((sum / pose.keypoints.length) * 100).clamp(0.0, 100.0);
  }

  void resetRepCounter() {
    _repCount = 0;
    _exerciseRecognitionService.resetCounter();
    notifyListeners();
  }

  KeypointData? getKeypoint(int index) {
    if (_currentPose == null || index < 0 || _currentPose!.keypoints.length <= index) {
      return null;
    }
    return _currentPose!.keypoints[index];
  }

  @override
  void dispose() {
    _poseDetectionService.dispose();
    super.dispose();
  }
}
