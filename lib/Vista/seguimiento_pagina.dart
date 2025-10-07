// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';

class SeguimientoPagina extends StatelessWidget {
  const SeguimientoPagina({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seguimiento de Glucosa'),
        backgroundColor: const Color(0xFF4090CD),
      ),
      body: Center(
        child: Icon(Icons.monitor_heart, size: 80, color: Color(0xFF133476)),
      ),
    );
  }
}
