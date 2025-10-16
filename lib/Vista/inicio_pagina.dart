// ignore_for_file: no_leading_underscores_for_local_identifiers, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sistema_integral/Vista/registro_glucosa_pagina.dart';
import 'login_pagina.dart';
import 'seguimiento_pagina.dart';
import '../Controlador/login_controller.dart';

class InicioPagina extends StatefulWidget {
  final String uid; // El UID del usuario autenticado
  const InicioPagina({super.key, required this.uid});

  @override
  State<InicioPagina> createState() => _InicioPaginaState();
}

class _InicioPaginaState extends State<InicioPagina> {
  String nombreUsuario = "Usuario";

  @override
  void initState() {
    super.initState();
    obtenerNombre();
  }

  Future<void> obtenerNombre() async {
    final doc =
        await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(widget.uid)
            .get();
    if (doc.exists && doc.data()?['nombre'] != null) {
      setState(() {
        nombreUsuario = doc.data()!['nombre'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final LoginController _loginController = LoginController();
    final Color azulPrincipal = const Color(0xFF4090CD);
    final Color azulOscuro = const Color(0xFF133476);
    final Color azulClaro = const Color(0xFF69D9F7);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: azulPrincipal,
        elevation: 6,
        title: const Text(
          'Inicio',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            letterSpacing: 1.2,
            fontFamily: 'Montserrat',
          ),
        ),
        leading: Builder(
          builder:
              (context) => IconButton(
                icon: const Icon(Icons.menu),
                tooltip: 'Menú',
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
        ),
      ),
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [azulPrincipal, azulClaro],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Center(
                child: Text(
                  'Opciones',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text(
                'Perfil',
                style: TextStyle(fontFamily: 'Montserrat'),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text(
                'Configuración',
                style: TextStyle(fontFamily: 'Montserrat'),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text(
                'Cerrar sesión',
                style: TextStyle(fontFamily: 'Montserrat'),
              ),
              onTap: () async {
                await _loginController.cerrarSesion();
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const Login()),
                );
              },
            ),
          ],
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              azulClaro.withOpacity(0.18),
              Colors.white,
              azulPrincipal.withOpacity(0.10),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.person, color: Color(0xFF133476), size: 26),
                const SizedBox(width: 8),
                Text(
                  'Bienvenido, $nombreUsuario',
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF133476),
                    letterSpacing: 1.1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 24,
                ),
                crossAxisSpacing: 24,
                mainAxisSpacing: 24,
                children: [
                  _ModuloCard(
                    icon: Icons.monitor_heart,
                    label: 'Seguimiento de Glucosa y Signos Vitales',
                    color: azulPrincipal,
                    onTap:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => RegistroGlucosaPagina(uid: widget.uid),
                          ),
                        ),
                  ),
                  _ModuloCard(
                    icon: Icons.show_chart,
                    label: 'Visualización de Historial',
                    color: azulOscuro,
                    onTap: () {
                      // Navega a HistorialPagina cuando la crees
                    },
                  ),
                  _ModuloCard(
                    icon: Icons.folder_shared,
                    label: 'Acceso a Expediente y Recursos',
                    color: azulClaro,
                    onTap: () {
                      // Navega a ExpedientePagina cuando la crees
                    },
                  ),
                  _ModuloCard(
                    icon: Icons.school,
                    label: 'Tutorial de Usuario',
                    color: azulPrincipal,
                    onTap: () {
                      // Navega a TutorialPagina cuando la crees
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModuloCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ModuloCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.15),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
            border: Border.all(color: color.withOpacity(0.18), width: 2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
