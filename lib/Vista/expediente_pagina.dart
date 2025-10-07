import 'package:flutter/material.dart';

class ExpedientePagina extends StatelessWidget {
  const ExpedientePagina({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expediente y Recursos'),
        backgroundColor: const Color(0xFF4090CD),
      ),
      body: Center(
        child: Icon(Icons.folder_shared, size: 80, color: Color(0xFF133476)),
      ),
    );
  }
}
