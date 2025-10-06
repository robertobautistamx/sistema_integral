// ignore_for_file: no_leading_underscores_for_local_identifiers, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'login_pagina.dart';
import '../Controlador/login_controller.dart';

class InicioPagina extends StatelessWidget {
  const InicioPagina({super.key});

  @override
  Widget build(BuildContext context) {
    final LoginController _loginController = LoginController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _loginController.cerrarSesion();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const Login()),
              );
            },
          ),
        ],
      ),
      body: const Center(
        child: Text(
          '¡Bienvenido al Sistema Integral!',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
