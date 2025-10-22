// lib/models/pose_data_model.dart

// This class holds all the keypoints for a single detected pose.
class PoseDataModel {
  final List<KeypointData> keypoints;
  final double averageConfidence;

  PoseDataModel({required this.keypoints, required this.averageConfidence});

  factory PoseDataModel.fromJson(Map<String, dynamic> json) {
    var keypointsList = json['keypoints'] as List;
    List<KeypointData> keypoints = keypointsList
        .map((i) => KeypointData.fromJson(i as Map<String, dynamic>))
        .toList();

    double sum = 0.0;
    for (var keypoint in keypoints) {
      sum += keypoint.visibility;
    }
    final averageConfidence = keypoints.isEmpty ? 0.0 : sum / keypoints.length;

    return PoseDataModel(
        keypoints: keypoints, averageConfidence: averageConfidence);
  }
}

// This class represents a single keypoint (like 'nose' or 'left_wrist').
class KeypointData {
  final double x;
  final double y;
  final String name;
  final double visibility;

  KeypointData({
    required this.x,
    required this.y,
    required this.name,
    required this.visibility,
  });

  factory KeypointData.fromJson(Map<String, dynamic> json) {
    return KeypointData(
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      name: json['name'] as String,
      visibility: (json['visibility'] as num? ?? 0.0).toDouble(),
    );
  }
}
