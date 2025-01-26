import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:plataforma/fonsoes.dart';

class CameraPageCadastrar extends StatefulWidget {
  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPageCadastrar> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  TextEditingController _nameController =
      TextEditingController(); // Controller para o nome do usuário

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  // Inicializando a câmera
  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();

    if (_cameras != null && _cameras!.isNotEmpty) {
      final frontCamera = _cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () =>
            _cameras![0], // Fallback para a primeira câmera disponível
      );

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.high,
      );

      await _cameraController!.initialize();
      setState(() {
        _isCameraInitialized = true;
      });
    } else {
      print('Nenhuma câmera encontrada.');
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cadastrar Usuário'),
      ),
      body: _isCameraInitialized
          ? Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  // Campo de texto para o nome do usuário
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: 'Nome do Usuário'),
                    textInputAction: TextInputAction.done,
                  ),
                  SizedBox(height: 16),
                  Expanded(
                    child: CameraPreview(_cameraController!),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      String username = _nameController.text.trim();
                      if (username.isEmpty) {
                        // Verificar se o nome do usuário foi preenchido
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Erro'),
                            content:
                                Text('Por favor, insira o nome do usuário.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text('OK'),
                              ),
                            ],
                          ),
                        );
                      } else {
                        // Passando o context para a função
                        await captureAndSendImage(context, _cameraController!,
                            _isCameraInitialized, username);
                      }
                    },
                    child: Text('Capturar e Enviar'),
                  ),
                ],
              ),
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
