import 'dart:math' as math;
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../models/pose_data_model.dart';

class PoseDetectionService {
  PoseDetector? _poseDetector;
  bool _isProcessing = false;
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  // Initialize pose detector — safe to call multiple times
  void initialize() {
    if (_isInitialized) return;
    _poseDetector = PoseDetector(
      options: PoseDetectorOptions(
        mode: PoseDetectionMode.stream,
        model: PoseDetectionModel.accurate,
      ),
    );
    _isInitialized = true;
  }

  // Detect pose from camera image
  Future<PoseDataModel?> detectPose(CameraImage image, int sensorOrientation) async {
    if (_isProcessing) return null;
    if (!_isInitialized || _poseDetector == null) {
      initialize(); // Auto-init if not done
    }

    _isProcessing = true;
    try {
      final inputImage = _convertCameraImage(image, sensorOrientation);
      if (inputImage == null) {
        _isProcessing = false;
        return null;
      }

      final List<Pose> poses = await _poseDetector!.processImage(inputImage);
      if (poses.isEmpty) {
        _isProcessing = false;
        return null;
      }

      final Pose pose = poses.first;
      final List<KeypointData> keypoints = [];

      // Build keypoints sorted by landmark index for consistent access
      final sortedLandmarks = pose.landmarks.entries.toList()
        ..sort((a, b) => a.key.index.compareTo(b.key.index));

      for (final landmark in sortedLandmarks) {
        keypoints.add(KeypointData(
          name: landmark.key.name,
          x: landmark.value.x,
          y: landmark.value.y,
          visibility: landmark.value.likelihood,
        ));
      }

      _isProcessing = false;
      return PoseDataModel(
        keypoints: keypoints,
        averageConfidence: _calculateAverageConfidence(keypoints),
      );
    } catch (e) {
      _isProcessing = false;
      debugPrint('PoseDetection error: $e');
      return null;
    }
  }

  InputImage? _convertCameraImage(CameraImage image, int sensorOrientation) {
    try {
      final WriteBuffer allBytes = WriteBuffer();
      for (final Plane plane in image.planes) {
        allBytes.putUint8List(plane.bytes);
      }
      final bytes = allBytes.done().buffer.asUint8List();

      final imageSize = Size(image.width.toDouble(), image.height.toDouble());
      final imageRotation = InputImageRotationValue.fromRawValue(sensorOrientation)
          ?? InputImageRotation.rotation0deg;
      final inputImageFormat = InputImageFormatValue.fromRawValue(image.format.raw)
          ?? InputImageFormat.nv21;

      final metadata = InputImageMetadata(
        size: imageSize,
        rotation: imageRotation,
        format: inputImageFormat,
        bytesPerRow: image.planes[0].bytesPerRow,
      );

      return InputImage.fromBytes(bytes: bytes, metadata: metadata);
    } catch (e) {
      debugPrint('CameraImage conversion error: $e');
      return null;
    }
  }

  double _calculateAverageConfidence(List<KeypointData> keypoints) {
    if (keypoints.isEmpty) return 0.0;
    double sum = 0.0;
    for (final kp in keypoints) {
      sum += kp.visibility;
    }
    return sum / keypoints.length;
  }

  double calculateAngle(KeypointData a, KeypointData b, KeypointData c) {
    final radians = math.atan2(c.y - b.y, c.x - b.x) -
        math.atan2(a.y - b.y, a.x - b.x);
    double angle = radians.abs() * 180.0 / math.pi;
    if (angle > 180.0) angle = 360.0 - angle;
    return angle;
  }

  void dispose() {
    _poseDetector?.close();
    _poseDetector = null;
    _isInitialized = false;
    _isProcessing = false;
  }
}
