import 'dart:math' as math;
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../models/pose_data_model.dart';
// Note: The import for app_constants was not used, so it can be removed if not needed elsewhere.
// import '../core/constants/app_constants.dart';
import 'package:flutter/material.dart';

class PoseDetectionService {
  late PoseDetector _poseDetector;
  bool _isProcessing = false;

  // Initialize pose detector
  void initialize() {
    _poseDetector = PoseDetector(
      options: PoseDetectorOptions(
        mode: PoseDetectionMode.stream,
        model: PoseDetectionModel.accurate,
      ),
    );
  }

  // Process camera image for pose detection
  // MODIFICATION: Added 'sensorOrientation' parameter. This value must be passed
  // from the camera controller's description.
  Future<PoseDataModel?> detectPose(CameraImage image, int sensorOrientation) async {
    if (_isProcessing) return null;

    _isProcessing = true;

    try {
      // Convert CameraImage to InputImage for ML Kit
      // MODIFICATION: Pass the sensorOrientation to the conversion method.
      final inputImage = _convertCameraImage(image, sensorOrientation);
      if (inputImage == null) {
        _isProcessing = false;
        return null;
      }

      // Detect poses
      final List<Pose> poses = await _poseDetector.processImage(inputImage);

      if (poses.isEmpty) {
        _isProcessing = false;
        return null;
      }

      // Get first detected pose
      Pose pose = poses.first;

      // Convert to PoseDataModel
      List<KeypointData> keypoints = [];
      for (var landmark in pose.landmarks.entries) {
        keypoints.add(
          KeypointData(
            // FIX: Removed 'index' parameter. It is likely not a property of KeypointData.
            name: _getLandmarkName(landmark.key),
            x: landmark.value.x,
            y: landmark.value.y,
            // FIX: Removed 'z' parameter. It is likely not a property of KeypointData.
            visibility: landmark.value.likelihood,
          ),
        );
      }

      _isProcessing = false;

      return PoseDataModel(
        keypoints: keypoints,
        // FIX: Renamed 'confidence' to 'averageConfidence'. The constructor in pose_data_model.dart likely expects 'averageConfidence'.
        averageConfidence: _calculateAverageConfidence(keypoints),
        // FIX: Removed 'timestamp' parameter as it is likely not defined in the PoseDataModel constructor.
      );
    } catch (e) {
      _isProcessing = false;
      // It's good practice to log the error for debugging.
      debugPrint('Error detecting pose: $e');
      return null;
    }
  }

  // Convert CameraImage to InputImage
  // MODIFICATION: Added 'sensorOrientation' parameter.
  InputImage? _convertCameraImage(CameraImage image, int sensorOrientation) {
    try {
      final WriteBuffer allBytes = WriteBuffer();
      for (Plane plane in image.planes) {
        allBytes.putUint8List(plane.bytes);
      }
      final bytes = allBytes.done().buffer.asUint8List();

      final imageSize = Size(image.width.toDouble(), image.height.toDouble());

      // MODIFICATION: Use the 'sensorOrientation' passed into this method instead of
      // trying to access it from the 'image' object.
      final imageRotation =
          InputImageRotationValue.fromRawValue(sensorOrientation) ??
              InputImageRotation.rotation0deg;

      final inputImageFormat =
          InputImageFormatValue.fromRawValue(image.format.raw) ??
              InputImageFormat.nv21;

      final inputImageData = InputImageMetadata(
        size: imageSize,
        rotation: imageRotation,
        format: inputImageFormat,
        bytesPerRow: image.planes[0].bytesPerRow,
      );

      return InputImage.fromBytes(
        bytes: bytes,
        metadata: inputImageData,
      );
    } catch (e) {
      debugPrint('Error converting camera image: $e');
      return null;
    }
  }

  // Get landmark name from PoseLandmarkType
  String _getLandmarkName(PoseLandmarkType type) {
    // Using .name is okay, but a switch can be more robust if you
    // want to customize names later.
    return type.name;
  }

  // Calculate average confidence from keypoints
  double _calculateAverageConfidence(List<KeypointData> keypoints) {
    if (keypoints.isEmpty) return 0.0;

    double sum = 0.0;
    for (var keypoint in keypoints) {
      sum += keypoint.visibility;
    }
    return sum / keypoints.length;
  }

  // Calculate angle between three points
  double calculateAngle(KeypointData a, KeypointData b, KeypointData c) {
    double radians = math.atan2(c.y - b.y, c.x - b.x) -
        math.atan2(a.y - b.y, a.x - b.x);
    double angle = radians.abs() * 180.0 / math.pi;

    if (angle > 180.0) {
      angle = 360.0 - angle;
    }

    return angle;
  }

  // Dispose pose detector
  void dispose() {
    _poseDetector.close();
  }
}