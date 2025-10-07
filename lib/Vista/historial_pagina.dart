import 'package:flutter/material.dart';

class HistorialPagina extends StatelessWidget {
  const HistorialPagina({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Glucosa'),
        backgroundColor: const Color(0xFF4090CD),
      ),
      body: Center(
        child: Icon(Icons.show_chart, size: 80, color: Color(0xFF133476)),
      ),
    );
  }
}
