import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pose_data_model.dart';

/// Service that bridges the Flutter app with the Python ML model API server.
/// 
/// The Python server (python_model/src/api_server.py) runs locally and
/// provides enhanced AI-based exercise classification and form analysis
/// beyond what the on-device ML Kit can do.
/// 
/// Usage:
/// 1. Start the Python server: `python python_model/src/api_server.py`
/// 2. Set the server URL below to your machine's local IP address
/// 3. Call methods from PoseProvider when enhanced predictions are needed

class AIModelService {
  /// Update this to your machine's local IP when testing on a physical device.
  /// Default is localhost for emulator testing.
  static const String _baseUrl = 'http://10.0.2.2:8000'; // Android emulator → host
  // static const String _baseUrl = 'http://localhost:8000'; // iOS simulator

  final http.Client _client;
  bool _isServerAvailable = false;

  AIModelService({http.Client? client}) : _client = client ?? http.Client();

  bool get isServerAvailable => _isServerAvailable;

  /// Check if the Python API server is running and reachable.
  Future<bool> checkHealth() async {
    try {
      final response = await _client
          .get(Uri.parse('$_baseUrl/health'))
          .timeout(const Duration(seconds: 3));
      _isServerAvailable = response.statusCode == 200;
      return _isServerAvailable;
    } catch (_) {
      _isServerAvailable = false;
      return false;
    }
  }

  /// Predict which exercise is being performed from pose landmarks.
  Future<ExercisePrediction?> predictExercise(PoseDataModel pose) async {
    if (!_isServerAvailable) return null;

    try {
      final body = jsonEncode({
        'landmarks': pose.keypoints.map((kp) => {
          'x': kp.x,
          'y': kp.y,
          'z': 0.0,
          'visibility': kp.visibility,
        }).toList(),
      });

      final response = await _client.post(
        Uri.parse('$_baseUrl/predict/exercise'),
        headers: {'Content-Type': 'application/json'},
        body: body,
      ).timeout(const Duration(seconds: 2));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ExercisePrediction(
          exercise: data['exercise'] ?? 'Unknown',
          confidence: (data['confidence'] ?? 0.0).toDouble(),
        );
      }
    } catch (_) {
      // Server unreachable — fall back to on-device detection
      _isServerAvailable = false;
    }
    return null;
  }

  /// Predict form quality (Good/Bad) from pose landmarks.
  Future<FormPrediction?> predictForm(PoseDataModel pose) async {
    if (!_isServerAvailable) return null;

    try {
      final body = jsonEncode({
        'landmarks': pose.keypoints.map((kp) => {
          'x': kp.x,
          'y': kp.y,
          'z': 0.0,
          'visibility': kp.visibility,
        }).toList(),
      });

      final response = await _client.post(
        Uri.parse('$_baseUrl/predict/form'),
        headers: {'Content-Type': 'application/json'},
        body: body,
      ).timeout(const Duration(seconds: 2));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return FormPrediction(
          formQuality: data['form_quality'] ?? 'Unknown',
          confidence: (data['confidence'] ?? 0.0).toDouble(),
          isGoodForm: data['is_good_form'] ?? false,
        );
      }
    } catch (_) {
      _isServerAvailable = false;
    }
    return null;
  }

  /// Get combined rule-based + AI feedback for a specific exercise.
  Future<FeedbackResult?> getFeedback(
    PoseDataModel pose,
    String exerciseName,
  ) async {
    if (!_isServerAvailable) return null;

    try {
      final body = jsonEncode({
        'exercise_name': exerciseName,
        'landmarks': pose.keypoints.map((kp) => {
          'x': kp.x,
          'y': kp.y,
          'z': 0.0,
          'visibility': kp.visibility,
        }).toList(),
      });

      final response = await _client.post(
        Uri.parse('$_baseUrl/feedback'),
        headers: {'Content-Type': 'application/json'},
        body: body,
      ).timeout(const Duration(seconds: 2));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return FeedbackResult(
          feedback: data['feedback'] ?? 'Hold position...',
          status: data['status'] ?? 'UP',
          isGoodForm: data['good_form'] ?? false,
          elbowAngle: (data['angles']?['elbow'] ?? 0.0).toDouble(),
          kneeAngle: (data['angles']?['knee'] ?? 0.0).toDouble(),
          hipAngle: (data['angles']?['hip'] ?? 0.0).toDouble(),
          aiFormQuality: data['ai_form_quality'],
          aiConfidence: data['ai_confidence'] != null
              ? (data['ai_confidence']).toDouble()
              : null,
        );
      }
    } catch (_) {
      _isServerAvailable = false;
    }
    return null;
  }

  void dispose() {
    _client.close();
  }
}

// -------------------------
// Response Models
// -------------------------

class ExercisePrediction {
  final String exercise;
  final double confidence;

  const ExercisePrediction({required this.exercise, required this.confidence});
}

class FormPrediction {
  final String formQuality;
  final double confidence;
  final bool isGoodForm;

  const FormPrediction({
    required this.formQuality,
    required this.confidence,
    required this.isGoodForm,
  });
}

class FeedbackResult {
  final String feedback;
  final String status;
  final bool isGoodForm;
  final double elbowAngle;
  final double kneeAngle;
  final double hipAngle;
  final String? aiFormQuality;
  final double? aiConfidence;

  const FeedbackResult({
    required this.feedback,
    required this.status,
    required this.isGoodForm,
    required this.elbowAngle,
    required this.kneeAngle,
    required this.hipAngle,
    this.aiFormQuality,
    this.aiConfidence,
  });
}
