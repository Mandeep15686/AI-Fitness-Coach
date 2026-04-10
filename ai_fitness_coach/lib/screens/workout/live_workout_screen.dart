import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/colors.dart';
import '../../models/user_model.dart';
import '../../providers/pose_provider.dart';
import '../../providers/workout_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/camera_service.dart';
import '../../widgets/pose_overlay_painter.dart';

class LiveWorkoutScreen extends StatefulWidget {
  final String exerciseType;
  const LiveWorkoutScreen({super.key, required this.exerciseType});

  @override
  State<LiveWorkoutScreen> createState() => _LiveWorkoutScreenState();
}

class _LiveWorkoutScreenState extends State<LiveWorkoutScreen>
    with SingleTickerProviderStateMixin {
  final CameraService _cameraService = CameraService();
  bool _isInitialized = false;
  bool _isSaving = false;
  late AnimationController _repAnim;
  int _lastRepCount = 0;
  int _elapsedSeconds = 0;
  late DateTime _startTime;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _repAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<WorkoutProvider>(context, listen: false).startWorkout(widget.exerciseType);
      Provider.of<PoseProvider>(context, listen: false)
          .startPoseDetection(targetExercise: widget.exerciseType);
      _initCamera();
      _startTimer();
    });
  }

  void _startTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() => _elapsedSeconds = DateTime.now().difference(_startTime).inSeconds);
      return mounted;
    });
  }

  Future<void> _initCamera() async {
    try {
      await _cameraService.initializeCamera(useFrontCamera: true);
      if (!mounted) return;
      setState(() => _isInitialized = true);
      _startStream();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Camera unavailable: $e'), backgroundColor: AppColors.error),
      );
    }
  }

  void _startStream() {
    final pose = Provider.of<PoseProvider>(context, listen: false);
    _cameraService.startImageStream((image) async {
      final orient = _cameraService.controller?.description.sensorOrientation ?? 0;
      await pose.processPose(image, orient);
    });
  }

  Future<void> _endWorkout() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    final pose = Provider.of<PoseProvider>(context, listen: false);
    final workouts = Provider.of<WorkoutProvider>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context, listen: false);

    final repCount = pose.repCount;
    final formScore = pose.formScore;

    pose.stopPoseDetection();
    await _cameraService.stopImageStream();

    final user = auth.currentUser ?? UserModel(
      uid: 'anonymous', email: '', name: 'You',
      age: 25, height: 170, weight: 70,
      fitnessGoal: 'General Fitness', fitnessLevel: 'Beginner',
      createdAt: DateTime.now(),
    );

    final saved = await workouts.endWorkout(user, repCount: repCount, formScore: formScore);

    if (mounted) {
      Navigator.of(context).pop();
      if (saved) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('🎉 Workout saved!'), backgroundColor: AppColors.primary),
        );
      }
    }
  }

  @override
  void dispose() {
    _repAnim.dispose();
    _cameraService.stopImageStream();
    _cameraService.dispose();
    super.dispose();
  }

  String _fmt(int s) =>
      '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) { if (!didPop) _showEndDialog(); },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(fit: StackFit.expand, children: [
          // Camera layer
          if (_isInitialized && _cameraService.controller?.value.isInitialized == true)
            _buildCameraLayer()
          else
            const Center(child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: AppColors.primary),
                SizedBox(height: 16),
                Text('Starting camera...', style: TextStyle(color: Colors.white54, fontSize: 14)),
              ],
            )),

          // HUD
          Consumer<PoseProvider>(builder: (_, pose, __) {
            if (pose.repCount > _lastRepCount) {
              _lastRepCount = pose.repCount;
              _repAnim.forward(from: 0);
            }
            return Stack(children: [
              _buildTopBar(pose),
              Positioned(bottom: 0, left: 0, right: 0, child: _buildBottomPanel(pose)),
            ]);
          }),

          // Saving overlay
          if (_isSaving)
            Container(
              color: Colors.black.withOpacity(0.7),
              child: const Center(child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.primary),
                  SizedBox(height: 16),
                  Text('Saving...', style: TextStyle(color: Colors.white70)),
                ],
              )),
            ),
        ]),
      ),
    );
  }

  Widget _buildCameraLayer() {
    final ctrl = _cameraService.controller!;
    final sz = MediaQuery.of(context).size;
    final preview = ctrl.value.previewSize!;
    final imageSize = Size(preview.height, preview.width);

    return Consumer<PoseProvider>(builder: (_, pose, __) => SizedBox(
      width: sz.width, height: sz.height,
      child: Stack(children: [
        Positioned.fill(child: CameraPreview(ctrl)),
        if (pose.currentPose != null)
          Positioned.fill(child: CustomPaint(
            size: sz,
            painter: PoseOverlayPainter(
              pose: pose.currentPose!,
              imageSize: imageSize,
              exerciseColor: AppColors.exerciseColor(widget.exerciseType),
            ),
          )),
      ]),
    ));
  }

  Widget _buildTopBar(PoseProvider pose) => Positioned(
    top: 0, left: 0, right: 0,
    child: SafeArea(child: Padding(
      padding: const EdgeInsets.all(12),
      child: Row(children: [
        _glassBtn(Icons.arrow_back_ios_new_rounded, _showEndDialog),
        const SizedBox(width: 10),
        Expanded(child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(12)),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(widget.exerciseType, style: GoogleFonts.barlow(
              fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white,
            )),
            const Spacer(),
            const Icon(Icons.timer_outlined, color: Colors.white38, size: 14),
            const SizedBox(width: 4),
            Text(_fmt(_elapsedSeconds), style: GoogleFonts.barlow(
              fontSize: 15, color: AppColors.primary, fontWeight: FontWeight.w700,
            )),
          ]),
        )),
        const SizedBox(width: 10),
        _glassBtn(Icons.stop_rounded, _endWorkout, color: AppColors.error),
      ]),
    )),
  );

  Widget _glassBtn(IconData icon, VoidCallback onTap, {Color color = Colors.white}) =>
    GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42, height: 42,
        decoration: BoxDecoration(
          color: color == Colors.white ? Colors.white.withOpacity(0.15) : color.withOpacity(0.8),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );

  Widget _buildBottomPanel(PoseProvider pose) {
    final color = AppColors.exerciseColor(widget.exerciseType);
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.82),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: color.withOpacity(0.45), width: 1.5),
        boxShadow: [BoxShadow(color: color.withOpacity(0.15), blurRadius: 24)],
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        ScaleTransition(
          scale: Tween(begin: 1.0, end: 1.22).animate(
            CurvedAnimation(parent: _repAnim, curve: Curves.elasticOut),
          ),
          child: Text('${pose.repCount}', style: GoogleFonts.barlow(
            fontSize: 80, fontWeight: FontWeight.w900, color: color, height: 1,
          )),
        ),
        Text('REPS', style: GoogleFonts.barlow(
          fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white38, letterSpacing: 5,
        )),
        const SizedBox(height: 14),
        Row(children: [
          const Icon(Icons.star_rounded, color: Colors.amber, size: 14),
          const SizedBox(width: 5),
          Text('Form', style: GoogleFonts.barlow(fontSize: 12, color: Colors.white54)),
          const Spacer(),
          Text('${pose.formScore.toInt()}%', style: GoogleFonts.barlow(
            fontSize: 12, color: Colors.white70, fontWeight: FontWeight.w600,
          )),
        ]),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: (pose.formScore / 100).clamp(0.0, 1.0),
            minHeight: 6,
            backgroundColor: Colors.white10,
            valueColor: AlwaysStoppedAnimation<Color>(
              pose.formScore > 70 ? AppColors.primary
                  : pose.formScore > 40 ? AppColors.warning
                  : AppColors.error,
            ),
          ),
        ),
        if (pose.feedbackMessage != null) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Text(pose.feedbackMessage!, style: GoogleFonts.barlow(
              fontSize: 13, color: color, fontWeight: FontWeight.w600,
            ), textAlign: TextAlign.center),
          ),
        ],
      ]),
    );
  }

  void _showEndDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('End Workout?', style: GoogleFonts.barlow(
          fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary,
        )),
        content: Text('Your reps and progress will be saved.', style: GoogleFonts.barlow(
          color: AppColors.textSecondary,
        )),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Continue')),
          ElevatedButton(
            onPressed: () { Navigator.of(context).pop(); _endWorkout(); },
            child: const Text('End & Save'),
          ),
        ],
      ),
    );
  }
}
