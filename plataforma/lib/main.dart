import 'package:flutter/material.dart';
import 'package:plataforma/camera.dart'; // Certifique-se de que este caminho e importação estejam corretos.

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ButtonScreen(),
    );
  }
}

class ButtonScreen extends StatelessWidget {
  void _onButtonPressed(BuildContext context) {
    print("O botão foi pressionado!");
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CameraPage()), // Substitua CameraPage pela sua página de destino.
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Botão Centralizado'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _onButtonPressed(context), // Passa o contexto para a função.
          child: Text('Pressione-me'),
        ),
      ),
    );
  }
}
