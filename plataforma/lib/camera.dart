import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraPage extends StatefulWidget {
  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    // Obter as câmeras disponíveis no dispositivo.
    _cameras = await availableCameras();

    if (_cameras != null && _cameras!.isNotEmpty) {
 
      final frontCamera = _cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => _cameras![0], // Fallback para a primeira câmera.
      );

      // Inicializar o controlador com a câmera frontal.
      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.max,
      );

      // Inicializar o controlador.
      await _cameraController!.initialize();

      setState(() {
        _isCameraInitialized = true;
      });
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Camera Frontal'),
      ),
      body: _isCameraInitialized
          ? CameraPreview(_cameraController!)
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
