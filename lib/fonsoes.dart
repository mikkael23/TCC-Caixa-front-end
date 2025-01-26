import 'dart:convert';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:plataforma/main.dart';



// Função para enviar a imagem com o nome para o servidor
  Future<http.Response> sendImageToServer(Uint8List imageBytes, String username) async {
    final url = Uri.parse('http://192.168.15.88:5000/register'); // Altere para o URL do seu servidor
    final request = http.MultipartRequest('POST', url)
      ..fields['username'] = username
      ..files.add(http.MultipartFile.fromBytes('image', imageBytes, filename: 'photo.jpg'));

    final response = await request.send();
    return http.Response.fromStream(response);
  }

  // Função para capturar e enviar a imagem
  Future<void> captureAndSendImage(BuildContext context, CameraController cameraController, bool isCameraInitialized, String username) async {
    if (!isCameraInitialized) return;

    final image = await cameraController.takePicture();
    final imageBytes = await image.readAsBytes();
    final response = await sendImageToServer(imageBytes, username);

    // Exibir um diálogo com o resultado do envio
    if (response.statusCode == 200) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Sucesso'),
          content: Text('Imagem enviada com sucesso!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => ButtonScreen()),
                  (route) => false,
                );
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Erro'),
          content: Text('Erro ao enviar a imagem: ${response.statusCode}'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fechar o diálogo
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }


class ImageSendService {
  // Função que envia a imagem para o servidor
  Future<String> sendImageToServer(Uint8List imageBytes) async {
    final url = Uri.parse('http://192.168.15.88:5000/verify');
    final request = http.MultipartRequest('POST', url)
      ..files.add(http.MultipartFile.fromBytes('image', imageBytes, filename: 'image.jpg'));

    try {
      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      
      if (response.statusCode == 200) {
        final data = jsonDecode(responseData);
        return data["message"] ?? "Verificação realizada com sucesso!";
      } else {
        final data = jsonDecode(responseData);
        return data["message"] ?? "Erro na verificação";
      }
    } catch (e) {
      return 'Erro ao conectar com o servidor: $e';
    }
  }
}