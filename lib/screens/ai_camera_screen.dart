import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:animate_do/animate_do.dart';
import '../config/app_config.dart';
import 'home_screen.dart'; // To reuse ClayContainer and AppColors

class AiCameraScreen extends StatefulWidget {
  const AiCameraScreen({super.key});

  @override
  State<AiCameraScreen> createState() => _AiCameraScreenState();
}

class _AiCameraScreenState extends State<AiCameraScreen> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isCameraReady = false;
  bool _isProcessing = false;
  String _detectionResult = "Point your camera to a sign";
  double _confidence = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        _controller = CameraController(
          _cameras![0],
          ResolutionPreset.medium,
          enableAudio: false,
        );

        await _controller!.initialize();
        if (mounted) {
          setState(() {
            _isCameraReady = true;
          });
        }
      }
    } catch (e) {
      debugPrint("Camera Error: $e");
    }
  }

  Future<void> _detectSign() async {
    if (_controller == null || !_controller!.value.isInitialized || _isProcessing) return;

    setState(() {
      _isProcessing = true;
      _detectionResult = "Analyzing...";
    });

    try {
      final XFile imageFile = await _controller!.takePicture();
      final bytes = await File(imageFile.path).readAsBytes();
      
      var request = http.MultipartRequest('POST', Uri.parse(AppConfig.detectSignUri));
      request.files.add(http.MultipartFile.fromBytes(
        'image',
        bytes,
        filename: 'sign.jpg',
      ));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _detectionResult = data['sign'] ?? "Sign Not Recognized";
          _confidence = (data['confidence'] ?? 0.0).toDouble();
          _isProcessing = false;
        });
      } else {
        setState(() {
          _detectionResult = "Error connecting to AI";
          _isProcessing = false;
        });
      }
    } catch (e) {
      setState(() {
        _detectionResult = "Detection failed";
        _isProcessing = false;
      });
      debugPrint("Error detecting sign: $e");
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: _CircleButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: () => Navigator.pop(context),
          ),
        ),
        title: Text(
          "AI SIGN DETECTOR",
          style: GoogleFonts.lexend(
            fontWeight: FontWeight.w900,
            fontSize: 20,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: ClayContainer(
                borderRadius: 40,
                spread: 12,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (_isCameraReady)
                        CameraPreview(_controller!)
                      else
                        const Center(child: CircularProgressIndicator()),
                      
                      // Overlay UI
                      if (_isProcessing)
                        Container(
                          color: Colors.black26,
                          child: const Center(
                            child: CircularProgressIndicator(color: AppColors.primary),
                          ),
                        ),
                      
                      // Corner brackets for focus
                      _buildBrackets(),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // Result Panel
          Container(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
            child: Column(
              children: [
                ClayContainer(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  borderRadius: 24,
                  color: Colors.white,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.psychology_rounded, color: AppColors.primary),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "DETECTION",
                              style: GoogleFonts.lexend(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textSecondary,
                                letterSpacing: 1.5,
                              ),
                            ),
                            Text(
                              _detectionResult.toUpperCase(),
                              style: GoogleFonts.lexend(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            if (_confidence > 0)
                              LinearProgressIndicator(
                                value: _confidence,
                                backgroundColor: AppColors.background,
                                valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                                minHeight: 4,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Capture Button
                GestureDetector(
                  onTap: _detectSign,
                  child: ClayContainer(
                    width: 80,
                    height: 80,
                    borderRadius: 40,
                    color: AppColors.primary,
                    child: const Icon(Icons.camera_rounded, color: Colors.white, size: 40),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrackets() {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white30, width: 2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          _BracketCorner(top: 0, left: 0, rotate: 0),
          _BracketCorner(top: 0, right: 0, rotate: 1),
          _BracketCorner(bottom: 0, left: 0, rotate: 3),
          _BracketCorner(bottom: 0, right: 0, rotate: 2),
        ],
      ),
    );
  }
}

class _BracketCorner extends StatelessWidget {
  final double? top;
  final double? bottom;
  final double? left;
  final double? right;
  final int rotate;

  const _BracketCorner({this.top, this.bottom, this.left, this.right, required this.rotate});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: RotatedBox(
        quarterTurns: rotate,
        child: Container(
          width: 30,
          height: 30,
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: Colors.white, width: 4),
              left: BorderSide(color: Colors.white, width: 4),
            ),
          ),
        ),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 2)),
          ],
        ),
        child: Icon(icon, color: AppColors.textPrimary, size: 20),
      ),
    );
  }
}
