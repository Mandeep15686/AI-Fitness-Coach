import 'package:camera/camera.dart';
import '../core/constants/app_constants.dart';

class CameraService {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;

  CameraController? get controller => _controller;
  bool get isInitialized => _isInitialized;

  // Initialize camera
  Future<void> initializeCamera({bool useFrontCamera = true}) async {
    try {
      _cameras = await availableCameras();

      if (_cameras == null || _cameras!.isEmpty) {
        throw Exception('No cameras available');
      }

      // Select camera (front or back)
      CameraDescription selectedCamera = useFrontCamera
          ? _cameras!.firstWhere(
              (camera) => camera.lensDirection == CameraLensDirection.front,
              orElse: () => _cameras!.first,
            )
          : _cameras!.firstWhere(
              (camera) => camera.lensDirection == CameraLensDirection.back,
              orElse: () => _cameras!.first,
            );

      _controller = CameraController(
        selectedCamera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      await _controller!.initialize();
      _isInitialized = true;
    } catch (e) {
      throw Exception('Camera initialization failed: ${e.toString()}');
    }
  }

  // Start camera streaming
  Future<void> startImageStream(
    Future<void> Function(CameraImage image) onImage,
  ) async {
    if (_controller == null || !_controller!.value.isInitialized) {
      throw Exception('Camera not initialized');
    }

    await _controller!.startImageStream(onImage);
  }

  // Stop camera streaming
  Future<void> stopImageStream() async {
    if (_controller != null && _controller!.value.isStreamingImages) {
      await _controller!.stopImageStream();
    }
  }

  // Dispose camera
  Future<void> dispose() async {
    if (_controller != null) {
      await stopImageStream();
      await _controller!.dispose();
      _isInitialized = false;
    }
  }

  // Switch camera
  Future<void> switchCamera() async {
    if (_cameras == null || _cameras!.length < 2) {
      return;
    }

    bool wasFront = _controller!.description.lensDirection == CameraLensDirection.front;
    await dispose();
    await initializeCamera(useFrontCamera: !wasFront);
  }

  // Take picture
  Future<XFile?> takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      return null;
    }

    try {
      return await _controller!.takePicture();
    } catch (e) {
      throw Exception('Failed to take picture: ${e.toString()}');
    }
  }
}
