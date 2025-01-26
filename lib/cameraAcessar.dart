import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:plataforma/fonsoes.dart';


class CameraPageAcessar extends StatefulWidget {
  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPageAcessar> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;

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
        orElse: () => _cameras![0], // Fallback para a primeira câmera disponível
      );

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.high,
      );

      await _cameraController!.initialize();
      setState(() {
        _isCameraInitialized = true;
      });
    }
  }

 Future<void> _captureAndVerify() async {
  if (_cameraController != null && _cameraController!.value.isInitialized) {
    try {
      List<Uint8List> imageBytesList = [];
      int photoCounter = 0;

      // Exibir um diálogo informando que estamos tirando 5 fotos
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Aguardando'),
            content: Text('Tirando 5 fotos... ($photoCounter/5)'),
            actions: <Widget>[
              TextButton(
                child: Text('Cancelar'),
                onPressed: () {
                  Navigator.pop(context); // Permite ao usuário cancelar, se necessário.
                },
              ),
            ],
          );
        },
      );

      // Capturando 5 fotos e informando o progresso
      for (int i = 0; i < 5; i++) {
        final image = await _cameraController!.takePicture();
        final imageBytes = await image.readAsBytes();
        imageBytesList.add(imageBytes);
        photoCounter++;

        // Atualiza o diálogo com o progresso
        Navigator.of(context).pop(); // Fecha o diálogo atual
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Aguardando'),
              content: Text('Tirando 5 fotos... ($photoCounter/5)'),
              actions: <Widget>[
                TextButton(
                  child: Text('Cancelar'),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          },
        );
      }

      // Fechar o diálogo de captura e enviar as imagens para o servidor
      Navigator.pop(context); // Fecha o último diálogo de captura

      // Enviando as 5 imagens para o servidor
      String result = '';
      for (var imageBytes in imageBytesList) {
        result = await ImageSendService().sendImageToServer(imageBytes);
        if (result.contains("É a pessoa")) {
          break;
        }
      }

      _showDialog(result);
    } catch (e) {
      _showDialog('Erro ao capturar a imagem: $e');
    }
  }
}


  // Exibindo o resultado do servidor
  void _showDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Resultado'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
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
        title: Text('Verificar Usuário'),
      ),
      body: _isCameraInitialized
          ? Column(
              children: [
                Expanded(
                  child: CameraPreview(_cameraController!),
                ),
                ElevatedButton(
                  onPressed: _captureAndVerify,
                  child: Text('Capturar e Verificar'),
                ),
              ],
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
