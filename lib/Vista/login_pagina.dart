// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import '../Controlador/login_controller.dart';
import 'inicio_pagina.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController correoController = TextEditingController();
  final TextEditingController contrasenaController = TextEditingController();
  final LoginController _loginController = LoginController();
  bool cargando = false;

  void _loginCorreo() async {
    setState(() => cargando = true);
    final usuario = await _loginController.loginConCorreo(
      correoController.text.trim(),
      contrasenaController.text.trim(),
    );
    setState(() => cargando = false);

    if (usuario != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const InicioPagina()),
      );
    } else {
      _mostrarError("Error al iniciar sesión");
    }
  }

  void _loginGoogle() async {
    setState(() => cargando = true);
    final usuario = await _loginController.loginConGoogle();
    setState(() => cargando = false);

    if (usuario != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const InicioPagina()),
      );
    } else {
      _mostrarError("No se pudo iniciar sesión con Google");
    }
  }

  void _mostrarError(String mensaje) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Error"),
            content: Text(mensaje),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Aceptar"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              TextField(
                controller: correoController,
                decoration: const InputDecoration(labelText: 'Correo'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: contrasenaController,
                decoration: const InputDecoration(labelText: 'Contraseña'),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              cargando
                  ? const CircularProgressIndicator()
                  : Column(
                    children: [
                      ElevatedButton(
                        onPressed: _loginCorreo,
                        child: const Text('Iniciar sesión'),
                      ),
                      const SizedBox(height: 10),
                      OutlinedButton.icon(
                        onPressed: _loginGoogle,
                        icon: Image.asset(
                          'lib/assets/google_logo.png',
                          height: 24,
                        ),
                        label: const Text('Acceder con Google'),
                      ),
                    ],
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
