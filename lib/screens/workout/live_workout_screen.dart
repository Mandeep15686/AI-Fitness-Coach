import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import '../../providers/pose_provider.dart';
import '../../providers/workout_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/camera_service.dart';
import '../../widgets/pose_overlay_painter.dart';
import '../../widgets/rep_counter_widget.dart';

class LiveWorkoutScreen extends StatefulWidget {
  final String exerciseType;

  const LiveWorkoutScreen({super.key, required this.exerciseType});

  @override
  State<LiveWorkoutScreen> createState() => _LiveWorkoutScreenState();
}

class _LiveWorkoutScreenState extends State<LiveWorkoutScreen> {
  final CameraService _cameraService = CameraService();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    final workoutProvider = Provider.of<WorkoutProvider>(context, listen: false);
    final poseProvider = Provider.of<PoseProvider>(context, listen: false);
    workoutProvider.startWorkout(widget.exerciseType);
    poseProvider.startPoseDetection();
  }

  Future<void> _initializeCamera() async {
    try {
      await _cameraService.initializeCamera(useFrontCamera: true);
      setState(() => _isInitialized = true);
      _startImageStream();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Camera error: $e')),
      );
    }
  }

  void _startImageStream() {
    final poseProvider = Provider.of<PoseProvider>(context, listen: false);
    _cameraService.startImageStream((image) async {
      final sensorOrientation = _cameraService.controller?.description.sensorOrientation ?? 0;
      await poseProvider.processPose(image, sensorOrientation);
    });
  }

  Future<void> _endWorkout() async {
    final workoutProvider = Provider.of<WorkoutProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final poseProvider = Provider.of<PoseProvider>(context, listen: false);

    poseProvider.stopPoseDetection();
    await _cameraService.stopImageStream();

    if (authProvider.currentUser != null) {
      bool saved = await workoutProvider.endWorkout(authProvider.currentUser!);
      if (saved && mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Workout saved successfully!')),
        );
      }
    }
  }

  @override
  void dispose() {
    _cameraService.stopImageStream();
    _cameraService.dispose();
    Provider.of<PoseProvider>(context, listen: false).stopPoseDetection();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || _cameraService.controller == null || !_cameraService.controller!.value.isInitialized) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.exerciseType)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final screenW = MediaQuery.of(context).size.width;
    final previewSize = _cameraService.controller!.value.previewSize!;

    final double ratio = screenW / previewSize.height;
    final double previewH = previewSize.width * ratio;

    // This is the actual image size that the painter needs to perform scaling
    final Size imageSize = Size(
      _cameraService.controller!.value.previewSize!.height,
      _cameraService.controller!.value.previewSize!.width,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exerciseType),
        actions: [
          IconButton(
            icon: const Icon(Icons.stop),
            onPressed: _endWorkout,
          ),
        ],
      ),
      body: Consumer<PoseProvider>(
        builder: (context, poseProvider, child) {
          return Column(
            children: [
              Expanded(
                flex: 3,
                child: SizedBox(
                  height: previewH,
                  width: screenW,
                  child: Stack(
                    children: [
                      CameraPreview(_cameraService.controller!),
                      if (poseProvider.currentPose != null)
                        CustomPaint(
                          painter: PoseOverlayPainter(
                            pose: poseProvider.currentPose!,
                            imageSize: imageSize, // Pass the imageSize here
                          ),
                          size: Size(screenW, previewH),
                        ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: RepCounterWidget(
                  repCount: poseProvider.repCount,
                  exerciseType: widget.exerciseType,
                  formScore: poseProvider.formScore,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
