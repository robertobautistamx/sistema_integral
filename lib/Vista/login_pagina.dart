// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Controlador/login_controller.dart';
import 'inicio_pagina.dart';
import 'registro_pagina.dart';

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

  final Color primary = const Color(0xFF3F84D4);
  final Color accent = const Color(0xFF5A4FBF);
  final Color softBg = const Color(0xFFFBF6FA);

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
      backgroundColor: softBg,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              children: [
                // Top illustration / circle
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [primary, accent]),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: primary.withOpacity(0.16),
                        blurRadius: 14,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.lock_rounded,
                    size: 56,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 18),

                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 8,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 26,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Bienvenido',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF133476),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Accede a tu cuenta para continuar',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(color: Colors.black54),
                        ),
                        const SizedBox(height: 18),

                        // Email
                        TextField(
                          controller: correoController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'Correo electrónico',
                            prefixIcon: const Icon(Icons.email_outlined),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Password
                        TextField(
                          controller: contrasenaController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Contraseña',
                            prefixIcon: const Icon(Icons.lock_outline),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Primary action
                        cargando
                            ? const Center(child: CircularProgressIndicator())
                            : SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _loginCorreo,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  'Iniciar sesión',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                        const SizedBox(height: 12),

                        // Google button
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _loginGoogle,
                            icon: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(2),
                                child: Image.asset(
                                  'lib/assets/google_logo.png',
                                  fit: BoxFit.contain,
                                  errorBuilder:
                                      (_, __, ___) => const Icon(
                                        Icons.g_mobiledata,
                                        color: Colors.red,
                                      ),
                                ),
                              ),
                            ),
                            label: Text(
                              'Acceder con Google',
                              style: GoogleFonts.poppins(
                                color: const Color(0xFF133476),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                              side: BorderSide(
                                color: primary.withOpacity(0.12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Links
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 8,
                          children: [
                            TextButton(
                              onPressed: _recuperarContrasena,
                              child: Text(
                                '¿Olvidaste tu contraseña?',
                                style: GoogleFonts.poppins(
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                            Text(
                              '·',
                              style: TextStyle(color: Colors.grey.shade300),
                            ),
                            TextButton(
                              onPressed: _registrarUsuario,
                              child: Text(
                                'Registrarse',
                                style: GoogleFonts.poppins(
                                  color: primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Footer small text
                Text(
                  'Protegemos tu información — Privacidad garantizada',
                  style: GoogleFonts.poppins(
                    color: Colors.black45,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
