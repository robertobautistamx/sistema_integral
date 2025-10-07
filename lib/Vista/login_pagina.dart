// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import '../Controlador/login_controller.dart';
import 'inicio_pagina.dart';
import 'registro_pagina.dart'; // Importa la vista de registro

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

  // Paleta de colores
  final Color azulPrincipal = const Color(0xFF4090CD);
  final Color azulOscuro = const Color(0xFF133476);
  final Color azulMedio = const Color(0xFF0E285E);
  final Color azulClaro = const Color(0xFF69D9F7);
  final Color azulSecundario = const Color(0xFF387FC0);

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
        MaterialPageRoute(builder: (_) => InicioPagina(uid: usuario.uid)),
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
        MaterialPageRoute(builder: (_) => InicioPagina(uid: usuario.uid)),
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

  void _registrarUsuario() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RegistroPagina()),
    );
  }

  void _recuperarContrasena() async {
    if (correoController.text.isEmpty) {
      _mostrarError("Ingresa tu correo para recuperar la contraseña.");
      return;
    }
    try {
      await _loginController.recuperarContrasena(correoController.text.trim());
      _mostrarError("Se envió un correo para recuperar la contraseña.");
    } catch (e) {
      _mostrarError("Error al enviar el correo de recuperación.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: azulClaro.withOpacity(0.12),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: azulPrincipal.withOpacity(0.18),
                  blurRadius: 32,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo o avatar elegante
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [azulPrincipal, azulSecundario],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 44,
                    backgroundColor: Colors.transparent,
                    child: Icon(
                      Icons.lock_rounded,
                      size: 54,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  "Bienvenido",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: azulOscuro,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Accede a tu cuenta para continuar",
                  style: TextStyle(fontSize: 16, color: azulMedio),
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: correoController,
                  decoration: InputDecoration(
                    labelText: 'Correo electrónico',
                    prefixIcon: Icon(Icons.email_outlined, color: azulOscuro),
                    filled: true,
                    fillColor: azulClaro.withOpacity(0.08),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: azulPrincipal),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: contrasenaController,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: Icon(Icons.lock_outline, color: azulOscuro),
                    filled: true,
                    fillColor: azulClaro.withOpacity(0.08),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: azulPrincipal),
                    ),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 24),
                cargando
                    ? const CircularProgressIndicator()
                    : Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: azulPrincipal,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              elevation: 2,
                            ),
                            onPressed: _loginCorreo,
                            child: const Text(
                              'Iniciar sesión',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              side: BorderSide(color: azulSecundario, width: 2),
                              padding: const EdgeInsets.symmetric(vertical: 18),
                            ),
                            onPressed: _loginGoogle,
                            icon: Image.asset(
                              'lib/assets/google_logo.png',
                              height: 26,
                            ),
                            label: Text(
                              'Acceder con Google',
                              style: TextStyle(
                                color: azulMedio,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                              onPressed: _recuperarContrasena,
                              child: Text(
                                '¿Olvidaste tu contraseña?',
                                style: TextStyle(
                                  color: azulOscuro,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: _registrarUsuario,
                              child: Text(
                                'Registrarse',
                                style: TextStyle(
                                  color: azulSecundario,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
