import 'package:flutter/material.dart';
import 'package:plataforma/cameraAcessar.dart';
import 'package:plataforma/cameraCadastrar.dart'; // Certifique-se de que este caminho e importação estejam corretos.

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
  void Acessar(BuildContext context) {
    print("O botão foi pressionado!");
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CameraPageAcessar()), // Substitua CameraPage pela sua página de destino.
    );
  }
  void Cadastrar(BuildContext context) {
    print("O botão foi pressionado!");
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CameraPageCadastrar()), // Substitua CameraPage pela sua página de destino.
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Botão Centralizado'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Centraliza os itens na coluna
          children: [
            ElevatedButton(
              onPressed: () => Acessar(context),
              child: Text('Acessar'),
            ),
            SizedBox(height: 20), // Espaço entre os botões
            ElevatedButton(
              onPressed: () => Cadastrar(context),
              child: Text('Cadastrar'),
            ),
          ],
        ),
      ),
    );
  }
}
