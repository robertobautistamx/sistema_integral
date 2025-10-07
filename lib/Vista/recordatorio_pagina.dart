import 'package:flutter/material.dart';

class RecordatoriosPagina extends StatelessWidget {
  const RecordatoriosPagina({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recordatorios y Notificaciones'),
        backgroundColor: const Color(0xFF4090CD),
      ),
      body: Center(
        child: Icon(
          Icons.notifications_active,
          size: 80,
          color: Color(0xFF133476),
        ),
      ),
    );
  }
}
