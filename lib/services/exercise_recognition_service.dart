import 'dart:collection';
import 'dart:math' as math;
import '../models/pose_data_model.dart';
import '../models/exercise_model.dart';
import '../core/constants/app_constants.dart';

class ExerciseRecognitionService {
  final Queue<PoseDataModel> _poseSequence = Queue<PoseDataModel>();
  String? _currentExercise;
  int _repetitionCount = 0;
  bool _isInDownPosition = false;

  String? get currentExercise => _currentExercise;
  int get repetitionCount => _repetitionCount;

  // Process pose for exercise recognition
  void processPose(PoseDataModel poseData) {
    // Add to sequence buffer
    _poseSequence.add(poseData);

    // Keep only last 30 frames (1 second at 30 FPS)
    if (_poseSequence.length > AppConstants.frameSequenceLength) {
      _poseSequence.removeFirst();
    }

    // Recognize exercise type
    _currentExercise = _recognizeExerciseType(poseData);

    // Count repetitions based on exercise type
    if (_currentExercise != null) {
      _countRepetitions(_currentExercise!, poseData);
    }
  }

  // Recognize exercise type from pose
  String? _recognizeExerciseType(PoseDataModel poseData) {
    if (poseData.keypoints.length < 33) return null;

    // Get key angles
    double hipAngle = _getHipAngle(poseData);
    double kneeAngle = _getKneeAngle(poseData);
    double elbowAngle = _getElbowAngle(poseData);
    double shoulderAngle = _getShoulderAngle(poseData);

    // Rule-based classification
    // Squats: Hip and knee flexion, torso relatively upright
    if (kneeAngle < 120 && hipAngle < 100 && shoulderAngle > 150) {
      return 'Squats';
    }

    // Push-ups: Elbow flexion, body horizontal
    if (elbowAngle < 90 && _isBodyHorizontal(poseData)) {
      return 'Push-ups';
    }

    // Bicep Curls: Elbow flexion, upper arm vertical
    if (elbowAngle < 90 && shoulderAngle > 160) {
      return 'Bicep Curls';
    }

    // Shoulder Press: Shoulder and elbow extension overhead
    if (shoulderAngle < 90 && elbowAngle > 160) {
      return 'Shoulder Press';
    }

    return _currentExercise; // Keep previous if no match
  }

  // Count repetitions based on exercise type
  void _countRepetitions(String exerciseType, PoseDataModel poseData) {
    switch (exerciseType) {
      case 'Squats':
        _countSquatReps(poseData);
        break;
      case 'Push-ups':
        _countPushUpReps(poseData);
        break;
      case 'Bicep Curls':
        _countBicepCurlReps(poseData);
        break;
      case 'Shoulder Press':
        _countShoulderPressReps(poseData);
        break;
    }
  }

  // Count squat repetitions
  void _countSquatReps(PoseDataModel poseData) {
    double kneeAngle = _getKneeAngle(poseData);

    // Down position: knees bent (< 100 degrees)
    if (kneeAngle < 100 && !_isInDownPosition) {
      _isInDownPosition = true;
    }

    // Up position: knees extended (> 160 degrees)
    if (kneeAngle > 160 && _isInDownPosition) {
      _repetitionCount++;
      _isInDownPosition = false;
    }
  }

  // Count push-up repetitions
  void _countPushUpReps(PoseDataModel poseData) {
    double elbowAngle = _getElbowAngle(poseData);

    // Down position: elbows bent (< 90 degrees)
    if (elbowAngle < 90 && !_isInDownPosition) {
      _isInDownPosition = true;
    }

    // Up position: elbows extended (> 160 degrees)
    if (elbowAngle > 160 && _isInDownPosition) {
      _repetitionCount++;
      _isInDownPosition = false;
    }
  }

  // Count bicep curl repetitions
  void _countBicepCurlReps(PoseDataModel poseData) {
    double elbowAngle = _getElbowAngle(poseData);

    // Up position: elbow flexed (< 60 degrees)
    if (elbowAngle < 60 && !_isInDownPosition) {
      _isInDownPosition = true;
    }

    // Down position: elbow extended (> 150 degrees)
    if (elbowAngle > 150 && _isInDownPosition) {
      _repetitionCount++;
      _isInDownPosition = false;
    }
  }

  // Count shoulder press repetitions
  void _countShoulderPressReps(PoseDataModel poseData) {
    double shoulderAngle = _getShoulderAngle(poseData);

    // Up position: arms overhead (< 80 degrees)
    if (shoulderAngle < 80 && !_isInDownPosition) {
      _isInDownPosition = true;
    }

    // Down position: arms at shoulder level (> 140 degrees)
    if (shoulderAngle > 140 && _isInDownPosition) {
      _repetitionCount++;
      _isInDownPosition = false;
    }
  }

  // Helper methods to calculate angles
  double _getKneeAngle(PoseDataModel poseData) {
    var hip = poseData.keypoints[23]; // left_hip
    var knee = poseData.keypoints[25]; // left_knee
    var ankle = poseData.keypoints[27]; // left_ankle
    return _calculateAngle(hip, knee, ankle);
  }

  double _getHipAngle(PoseDataModel poseData) {
    var shoulder = poseData.keypoints[11]; // left_shoulder
    var hip = poseData.keypoints[23]; // left_hip
    var knee = poseData.keypoints[25]; // left_knee
    return _calculateAngle(shoulder, hip, knee);
  }

  double _getElbowAngle(PoseDataModel poseData) {
    var shoulder = poseData.keypoints[11]; // left_shoulder
    var elbow = poseData.keypoints[13]; // left_elbow
    var wrist = poseData.keypoints[15]; // left_wrist
    return _calculateAngle(shoulder, elbow, wrist);
  }

  double _getShoulderAngle(PoseDataModel poseData) {
    var hip = poseData.keypoints[23]; // left_hip
    var shoulder = poseData.keypoints[11]; // left_shoulder
    var elbow = poseData.keypoints[13]; // left_elbow
    return _calculateAngle(hip, shoulder, elbow);
  }

  bool _isBodyHorizontal(PoseDataModel poseData) {
    var shoulder = poseData.keypoints[11];
    var hip = poseData.keypoints[23];
    double yDiff = (shoulder.y - hip.y).abs();
    return yDiff < 50; // Threshold for horizontal alignment
  }

  double _calculateAngle(KeypointData a, KeypointData b, KeypointData c) {
    double radians = math.atan2(c.y - b.y, c.x - b.x) - 
                     math.atan2(a.y - b.y, a.x - b.x);
    double angle = radians.abs() * 180.0 / math.pi;

    if (angle > 180.0) {
      angle = 360.0 - angle;
    }

    return angle;
  }

  // Reset counter
  void resetCounter() {
    _repetitionCount = 0;
    _isInDownPosition = false;
  }

  // Clear sequence buffer
  void clear() {
    _poseSequence.clear();
    _currentExercise = null;
    resetCounter();
  }
}

// Note: Add import 'dart:math' as math; at the top of this file
