import 'package:flutter/material.dart';
import '../core/constants/colors.dart';
import '../models/pose_data_model.dart';

class PoseOverlayPainter extends CustomPainter {
  final PoseDataModel pose;
  final Size imageSize;
  final Color exerciseColor;

  PoseOverlayPainter({
    required this.pose,
    required this.imageSize,
    this.exerciseColor = AppColors.primary,
  });

  // MediaPipe/ML Kit keypoint connections
  static const List<List<String>> _connections = [
    // Arms
    ['leftShoulder', 'leftElbow'], ['leftElbow', 'leftWrist'],
    ['rightShoulder', 'rightElbow'], ['rightElbow', 'rightWrist'],
    // Torso
    ['leftShoulder', 'rightShoulder'],
    ['leftShoulder', 'leftHip'], ['rightShoulder', 'rightHip'],
    ['leftHip', 'rightHip'],
    // Legs
    ['leftHip', 'leftKnee'], ['leftKnee', 'leftAnkle'],
    ['rightHip', 'rightKnee'], ['rightKnee', 'rightAnkle'],
    // Face
    ['nose', 'leftEye'], ['nose', 'rightEye'],
    ['leftEye', 'leftEar'], ['rightEye', 'rightEar'],
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (pose.keypoints.isEmpty) return;

    final scaleX = size.width / imageSize.width;
    final scaleY = size.height / imageSize.height;

    final kpByName = {for (final kp in pose.keypoints) kp.name: kp};

    // Draw skeleton lines
    final linePaint = Paint()
      ..color = exerciseColor.withOpacity(0.7)
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    for (final conn in _connections) {
      final a = kpByName[conn[0]];
      final b = kpByName[conn[1]];
      if (a == null || b == null) continue;
      if (a.visibility < 0.4 || b.visibility < 0.4) continue;

      canvas.drawLine(
        Offset(a.x * scaleX, a.y * scaleY),
        Offset(b.x * scaleX, b.y * scaleY),
        linePaint,
      );
    }

    // Draw joints (circles)
    final jointPaint = Paint()
      ..color = exerciseColor
      ..style = PaintingStyle.fill;

    final outlinePaint = Paint()
      ..color = Colors.white.withOpacity(0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (final kp in pose.keypoints) {
      if (kp.visibility < 0.4) continue;
      final pos = Offset(kp.x * scaleX, kp.y * scaleY);
      canvas.drawCircle(pos, 6.0, jointPaint);
      canvas.drawCircle(pos, 6.0, outlinePaint);
    }
  }

  @override
  bool shouldRepaint(covariant PoseOverlayPainter old) =>
      old.pose != pose || old.exerciseColor != exerciseColor;
}
