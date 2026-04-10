import 'dart:collection';
import 'dart:math' as math;
import '../models/pose_data_model.dart';
import '../core/constants/app_constants.dart';

class ExerciseRecognitionService {
  final Queue<PoseDataModel> _poseSequence = Queue<PoseDataModel>();
  String? _currentExercise;
  int _repetitionCount = 0;
  bool _isInDownPosition = false;
  // Per-exercise state tracking to avoid cross-exercise state bugs
  String? _targetExercise;

  String? get currentExercise => _currentExercise;
  int get repetitionCount => _repetitionCount;

  void setTargetExercise(String exerciseName) {
    _targetExercise = exerciseName;
    _currentExercise = exerciseName;
  }

  void processPose(PoseDataModel poseData) {
    _poseSequence.add(poseData);
    if (_poseSequence.length > AppConstants.frameSequenceLength) {
      _poseSequence.removeFirst();
    }

    // Use target exercise if set (from workout selection), otherwise auto-detect
    if (_targetExercise != null) {
      _currentExercise = _targetExercise;
    } else {
      _currentExercise = _recognizeExerciseType(poseData);
    }

    if (_currentExercise != null && poseData.keypoints.length >= 29) {
      _countRepetitions(_currentExercise!, poseData);
    }
  }

  String? _recognizeExerciseType(PoseDataModel poseData) {
    if (poseData.keypoints.length < 29) return _currentExercise;

    final hipAngle = _getHipAngle(poseData);
    final kneeAngle = _getKneeAngle(poseData);
    final elbowAngle = _getElbowAngle(poseData);
    final shoulderAngle = _getShoulderAngle(poseData);

    if (kneeAngle < 120 && hipAngle < 100) return 'Squats';
    if (elbowAngle < 90 && _isBodyHorizontal(poseData)) return 'Push-ups';
    if (elbowAngle < 90 && shoulderAngle > 150) return 'Bicep Curls';
    if (shoulderAngle < 90 && elbowAngle > 150) return 'Shoulder Press';

    return _currentExercise;
  }

  void _countRepetitions(String exerciseType, PoseDataModel poseData) {
    if (poseData.keypoints.length < 29) return;

    switch (exerciseType) {
      case 'Squats': _countSquatReps(poseData); break;
      case 'Push-ups': _countPushUpReps(poseData); break;
      case 'Bicep Curls': _countBicepCurlReps(poseData); break;
      case 'Shoulder Press': _countShoulderPressReps(poseData); break;
      case 'Lunges': _countLungeReps(poseData); break;
    }
  }

  void _countSquatReps(PoseDataModel poseData) {
    final kneeAngle = _getKneeAngle(poseData);
    if (kneeAngle < 100 && !_isInDownPosition) {
      _isInDownPosition = true;
    } else if (kneeAngle > 160 && _isInDownPosition) {
      _repetitionCount++;
      _isInDownPosition = false;
    }
  }

  void _countPushUpReps(PoseDataModel poseData) {
    final elbowAngle = _getElbowAngle(poseData);
    if (elbowAngle < 80 && !_isInDownPosition) {
      _isInDownPosition = true;
    } else if (elbowAngle > 155 && _isInDownPosition) {
      _repetitionCount++;
      _isInDownPosition = false;
    }
  }

  void _countBicepCurlReps(PoseDataModel poseData) {
    final elbowAngle = _getElbowAngle(poseData);
    if (elbowAngle < 55 && !_isInDownPosition) {
      _isInDownPosition = true;
    } else if (elbowAngle > 155 && _isInDownPosition) {
      _repetitionCount++;
      _isInDownPosition = false;
    }
  }

  void _countShoulderPressReps(PoseDataModel poseData) {
    final shoulderAngle = _getShoulderAngle(poseData);
    if (shoulderAngle < 75 && !_isInDownPosition) {
      _isInDownPosition = true;
    } else if (shoulderAngle > 145 && _isInDownPosition) {
      _repetitionCount++;
      _isInDownPosition = false;
    }
  }

  void _countLungeReps(PoseDataModel poseData) {
    final kneeAngle = _getKneeAngle(poseData);
    if (kneeAngle < 95 && !_isInDownPosition) {
      _isInDownPosition = true;
    } else if (kneeAngle > 160 && _isInDownPosition) {
      _repetitionCount++;
      _isInDownPosition = false;
    }
  }

  // Keypoint indices per MediaPipe/ML Kit spec:
  // 11=left_shoulder, 13=left_elbow, 15=left_wrist
  // 23=left_hip, 25=left_knee, 27=left_ankle
  KeypointData? _safeKp(PoseDataModel p, int idx) {
    if (idx < p.keypoints.length && p.keypoints[idx].visibility > 0.3) {
      return p.keypoints[idx];
    }
    return null;
  }

  double _getKneeAngle(PoseDataModel p) {
    final hip = _safeKp(p, 23);
    final knee = _safeKp(p, 25);
    final ankle = _safeKp(p, 27);
    if (hip == null || knee == null || ankle == null) return 180;
    return _calculateAngle(hip, knee, ankle);
  }

  double _getHipAngle(PoseDataModel p) {
    final shoulder = _safeKp(p, 11);
    final hip = _safeKp(p, 23);
    final knee = _safeKp(p, 25);
    if (shoulder == null || hip == null || knee == null) return 180;
    return _calculateAngle(shoulder, hip, knee);
  }

  double _getElbowAngle(PoseDataModel p) {
    final shoulder = _safeKp(p, 11);
    final elbow = _safeKp(p, 13);
    final wrist = _safeKp(p, 15);
    if (shoulder == null || elbow == null || wrist == null) return 180;
    return _calculateAngle(shoulder, elbow, wrist);
  }

  double _getShoulderAngle(PoseDataModel p) {
    final hip = _safeKp(p, 23);
    final shoulder = _safeKp(p, 11);
    final elbow = _safeKp(p, 13);
    if (hip == null || shoulder == null || elbow == null) return 180;
    return _calculateAngle(hip, shoulder, elbow);
  }

  // BUG FIX: Landmarks are normalized (0.0-1.0), so threshold is 0.1 not 50
  bool _isBodyHorizontal(PoseDataModel p) {
    final shoulder = _safeKp(p, 11);
    final hip = _safeKp(p, 23);
    if (shoulder == null || hip == null) return false;
    return (shoulder.y - hip.y).abs() < 0.1;
  }

  double _calculateAngle(KeypointData a, KeypointData b, KeypointData c) {
    final radians = math.atan2(c.y - b.y, c.x - b.x) -
        math.atan2(a.y - b.y, a.x - b.x);
    double angle = radians.abs() * 180.0 / math.pi;
    if (angle > 180.0) angle = 360.0 - angle;
    return angle;
  }

  String? getFeedbackMessage(PoseDataModel poseData) {
    if (_currentExercise == null || poseData.keypoints.length < 29) return null;

    switch (_currentExercise) {
      case 'Squats':
        final knee = _getKneeAngle(poseData);
        if (knee > 165) return 'Lower your body — go deeper!';
        if (knee < 70) return 'Too deep — rise slightly';
        if (_getHipAngle(poseData) < 90) return 'Keep your chest up!';
        return _isInDownPosition ? 'Good depth — push back up!' : 'Great form!';

      case 'Push-ups':
        final elbow = _getElbowAngle(poseData);
        if (elbow > 165) return 'Lower your body!';
        if (!_isBodyHorizontal(poseData)) return 'Keep your body straight!';
        return _isInDownPosition ? 'Good — push up!' : 'Great form!';

      case 'Bicep Curls':
        final elbow = _getElbowAngle(poseData);
        if (elbow > 160) return 'Curl up — lift your arm!';
        if (elbow < 40) return 'Slowly lower the weight';
        return 'Excellent curl!';

      case 'Shoulder Press':
        final shoulder = _getShoulderAngle(poseData);
        if (shoulder > 150) return 'Press overhead!';
        return 'Great press!';

      default:
        return 'Keep going!';
    }
  }

  void resetCounter() {
    _repetitionCount = 0;
    _isInDownPosition = false;
  }

  void clear() {
    _poseSequence.clear();
    _currentExercise = null;
    _targetExercise = null;
    resetCounter();
  }
}
