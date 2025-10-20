// lib/widgets/pose_overlay_painter.dart

import 'package:flutter/material.dart';
import 'package:ai_fitness_coach/models/pose_data_model.dart';
import 'dart:ui';

class PoseOverlayPainter extends CustomPainter {
  final PoseDataModel pose;
  final Size imageSize;

  PoseOverlayPainter({
    required this.pose,
    required this.imageSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.yellow
      ..strokeWidth = 4.0
      ..style = PaintingStyle.fill;

    // --- Iterate over the list of keypoints ---
    for (final keypoint in pose.keypoints) {
      // Use 'visibility' as the confidence score
      if (keypoint.visibility > 0.5) {
        // Scaling logic remains the same
        final double scaleX = size.width / imageSize.width;
        final double scaleY = size.height / imageSize.height;

        // Create the offset for drawing
        final offset = Offset(keypoint.x * scaleX, keypoint.y * scaleY);

        // For front camera, you might need to flip the X coordinate
        // final offset = Offset((imageSize.width - keypoint.x) * scaleX, keypoint.y * scaleY);

        canvas.drawCircle(offset, 5.0, paint);
      }
    }

    // --- Logic for drawing connection lines ---
    final linePaint = Paint()
      ..color = Colors.lightGreenAccent
      ..strokeWidth = 3.0;

    // Define connections using the keypoint names from your model
    final connections = {
      // Arms
      'left_shoulder': 'left_elbow',
      'left_elbow': 'left_wrist',
      'right_shoulder': 'right_elbow',
      'right_elbow': 'right_wrist',
      // Torso
      'left_shoulder': 'right_shoulder',
      'left_hip': 'right_hip',
      'left_shoulder': 'left_hip',
      'right_shoulder': 'right_hip',
      // Legs
      'left_hip': 'left_knee',
      'left_knee': 'left_ankle',
      'right_hip': 'right_knee',
      'right_knee': 'right_ankle',
    };

    // Create a map of keypoints by name for easy lookup
    final keypointsByName = {for (var kp in pose.keypoints) kp.name: kp};

    connections.forEach((startName, endName) {
      final startPoint = keypointsByName[startName];
      final endPoint = keypointsByName[endName];

      if (startPoint != null &&
          endPoint != null &&
          startPoint.visibility > 0.5 &&
          endPoint.visibility > 0.5) {
        final double scaleX = size.width / imageSize.width;
        final double scaleY = size.height / imageSize.height;

        final startOffset = Offset(startPoint.x * scaleX, startPoint.y * scaleY);
        final endOffset = Offset(endPoint.x * scaleX, endPoint.y * scaleY);

        canvas.drawLine(startOffset, endOffset, linePaint);
      }
    });
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // Only repaint if the pose has changed to be more efficient
    return oldDelegate is! PoseOverlayPainter || oldDelegate.pose != pose;
  }
}
