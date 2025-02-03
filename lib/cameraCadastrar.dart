import 'dart:async';
import 'dart:convert';
import 'dart:io'; // Importante para lidar com arquivos
import 'package:http/http.dart' as http;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraPageCadastrar extends StatefulWidget {
  @override
  _CameraPageCadastrarState createState() => _CameraPageCadastrarState();
}

class _CameraPageCadastrarState extends State<CameraPageCadastrar> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  Timer? _timer;
  bool _isScreenPink = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    var fotos = {
      "frente",
      "direita",
      "esquerda",
      "cima",
      "baixo"
    };
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();

    if (_cameras != null && _cameras!.isNotEmpty) {
      final frontCamera = _cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => _cameras![0],
      );

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.high,
      );

      await _cameraController!.initialize();
      setState(() {
        _isCameraInitialized = true;
      });

      _capturarImagens();
    } else {
      print('Nenhuma câmera encontrada.');
    }
  }

  void _capturarImagens() {
    _timer = Timer.periodic(Duration(seconds: 3), (timer) async {
      if (_cameraController != null && _isCameraInitialized) {
        try {
          final image = await _cameraController!.takePicture();
          print('Foto capturada: ${image.path}');

          // Exibe a tela rosa de imediato
          setState(() {
            _isScreenPink = true;
          });

          await Future.delayed(Duration(milliseconds: 300)); // Espera 300ms

          setState(() {
            _isScreenPink = false;
          });

          await _enviarImagem(image.path);
        } catch (e) {
          print('Erro ao capturar a imagem: $e');
        }
      }
    });
  }

  Future<void> _enviarImagem(String imagePath) async {
    try {
      print('Enviando imagem para: $imagePath');

      var request = http.MultipartRequest(
          'POST', Uri.parse('http://192.168.0.9:5000/detectar_rosto'));

      // Verifique se o caminho do arquivo é válido
      if (await File(imagePath).exists()) {
        request.files.add(await http.MultipartFile.fromPath('file', imagePath));
      } else {
        print('Arquivo não encontrado: $imagePath');
        return;
      }

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        String responseBody = await response.stream.bytesToString();
        // Decodificar a resposta JSON para um Map
        var jsonResponse = jsonDecode(responseBody);

        // Acessar a chave 'lado_identificado' no mapa decodificado
        print('Resposta do servidor: ${jsonResponse['lado_identificado']}');

        if (jsonResponse['lado_identificado'] == 'frente') {
          print('sucesso');
        } else {
          print('tire uma nova foto');
        }
      } else {
        print('Erro ao enviar imagem. Status: ${response.statusCode}');
        print('Razão: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Erro ao enviar imagem: $e');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Fundo preto
      body: Center(
        child: Stack(
          children: [
            // Camera Preview, sempre centralizado
            _isCameraInitialized
                ? Center(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 1,
                      height: MediaQuery.of(context).size.height * 0.83,
                      child: Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.rotationY(3.14159), // Espelhamento horizontal
                        child: AspectRatio(
                          aspectRatio: _cameraController!.value.aspectRatio,
                          child: CameraPreview(_cameraController!),
                        ),
                      ),
                    ),
                  )
                : CircularProgressIndicator(),

            // Tela rosa de forma instantânea
            _isScreenPink
                ? Container(
                    color: const Color.fromARGB(94, 102, 102, 102),
                    width: double.infinity,
                    height: double.infinity,
                  )
                : SizedBox.shrink(), // Exibe um SizedBox vazio quando a tela não é rosa
          ],
        ),
      ),
    );
  }
}
