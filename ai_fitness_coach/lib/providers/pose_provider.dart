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
  double _elbowAngle = 0.0;
  double _kneeAngle = 0.0;
  double _hipAngle = 0.0;

  PoseDataModel? get currentPose => _currentPose;
  String? get detectedExercise => _detectedExercise;
  int get repCount => _repCount;
  bool get isPoseDetectionActive => _isPoseDetectionActive;
  double get formScore => _formScore;
  String? get feedbackMessage => _feedbackMessage;
  double get elbowAngle => _elbowAngle;
  double get kneeAngle => _kneeAngle;
  double get hipAngle => _hipAngle;

  // FIX: Always initialize before starting
  void startPoseDetection({String? targetExercise}) {
    _poseDetectionService.initialize(); // <-- was missing, causing LateInitializationError
    _isPoseDetectionActive = true;
    _repCount = 0;
    _formScore = 0.0;
    _feedbackMessage = null;
    _currentPose = null;
    _elbowAngle = 0.0;
    _kneeAngle = 0.0;
    _hipAngle = 0.0;
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
          _updateAngles(pose);
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('PoseProvider.processPose error: $e');
    }
  }

  void _updateAngles(PoseDataModel pose) {
    if (pose.keypoints.length < 29) return;
    final svc = _poseDetectionService;
    KeypointData? kp(int i) => i < pose.keypoints.length ? pose.keypoints[i] : null;
    final shoulder = kp(11);
    final elbow = kp(13);
    final wrist = kp(15);
    final hip = kp(23);
    final knee = kp(25);
    final ankle = kp(27);
    if (shoulder != null && elbow != null && wrist != null) {
      _elbowAngle = svc.calculateAngle(shoulder, elbow, wrist);
    }
    if (hip != null && knee != null && ankle != null) {
      _kneeAngle = svc.calculateAngle(hip, knee, ankle);
    }
    if (shoulder != null && hip != null && knee != null) {
      _hipAngle = svc.calculateAngle(shoulder, hip, knee);
    }
  }

  double _calculateFormScore(PoseDataModel pose) {
    if (pose.keypoints.isEmpty) return 0.0;
    // Weight key exercise joints more heavily than face/hands for form scoring
    const highWeightIndices = [11, 12, 13, 14, 15, 16, 23, 24, 25, 26, 27, 28]; // shoulders, elbows, wrists, hips, knees, ankles
    double sum = 0.0;
    int count = 0;
    for (int i = 0; i < pose.keypoints.length; i++) {
      final kp = pose.keypoints[i];
      final weight = highWeightIndices.contains(i) ? 2.0 : 1.0;
      sum += kp.visibility * weight;
      count += weight.toInt();
    }
    return ((sum / count) * 100).clamp(0.0, 100.0);
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
