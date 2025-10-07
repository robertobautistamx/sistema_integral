// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Controlador/login_controller.dart';

class RegistroPagina extends StatefulWidget {
  const RegistroPagina({super.key});

  @override
  State<RegistroPagina> createState() => _RegistroPaginaState();
}

class _RegistroPaginaState extends State<RegistroPagina> {
  final TextEditingController correoController = TextEditingController();
  final TextEditingController contrasenaController = TextEditingController();
  final TextEditingController confirmarController = TextEditingController();
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController apellidoController = TextEditingController();
  final LoginController _loginController = LoginController();
  bool cargando = false;

  // Paleta de colores
  final Color azulPrincipal = const Color(0xFF4090CD);
  final Color azulOscuro = const Color(0xFF133476);
  final Color azulMedio = const Color(0xFF0E285E);
  final Color azulClaro = const Color(0xFF69D9F7);
  final Color azulSecundario = const Color(0xFF387FC0);

  void _registrarUsuario() async {
    final nombre = nombreController.text.trim();
    final apellido = apellidoController.text.trim();
    final correo = correoController.text.trim();
    final contrasena = contrasenaController.text.trim();
    final confirmar = confirmarController.text.trim();

    if (nombre.isEmpty ||
        apellido.isEmpty ||
        correo.isEmpty ||
        contrasena.isEmpty ||
        confirmar.isEmpty) {
      _mostrarMensaje("Completa todos los campos.");
      return;
    }
    if (contrasena != confirmar) {
      _mostrarMensaje("Las contraseñas no coinciden.");
      return;
    }
    setState(() => cargando = true);
    final usuario = await _loginController.registrarUsuario(correo, contrasena);
    setState(() => cargando = false);

    if (usuario != null) {
      // Guarda nombre y apellido en Firestore
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(usuario.uid)
          .set({'nombre': nombre, 'apellido': apellido, 'correo': correo});
      await showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: const Text("Registro"),
              content: const Text("¡Registro exitoso! Ahora inicia sesión."),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Aceptar"),
                ),
              ],
            ),
      );
      Navigator.pop(context); // Regresa al login después de mostrar el mensaje
    } else {
      _mostrarMensaje("No se pudo registrar el usuario22.");
    }
  }

  void _mostrarMensaje(String mensaje) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Registro"),
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
                      Icons.person_add_alt_1_rounded,
                      size: 54,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  "Crear cuenta",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: azulOscuro,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Regístrate para acceder al sistema",
                  style: TextStyle(fontSize: 16, color: azulMedio),
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: nombreController,
                  decoration: InputDecoration(
                    labelText: 'Nombre',
                    prefixIcon: Icon(Icons.person_outline, color: azulOscuro),
                    filled: true,
                    fillColor: azulClaro.withOpacity(0.08),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: azulPrincipal),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: apellidoController,
                  decoration: InputDecoration(
                    labelText: 'Apellido',
                    prefixIcon: Icon(Icons.person_outline, color: azulOscuro),
                    filled: true,
                    fillColor: azulClaro.withOpacity(0.08),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: azulPrincipal),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
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
                const SizedBox(height: 18),
                TextField(
                  controller: confirmarController,
                  decoration: InputDecoration(
                    labelText: 'Confirmar contraseña',
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
                    : SizedBox(
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
                        onPressed: _registrarUsuario,
                        child: const Text(
                          'Registrarse',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    '¿Ya tienes cuenta? Inicia sesión',
                    style: TextStyle(
                      color: azulSecundario,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
