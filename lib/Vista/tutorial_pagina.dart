import 'package:flutter/material.dart';

class TutorialPagina extends StatelessWidget {
  const TutorialPagina({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tutorial de Usuario'),
        backgroundColor: const Color(0xFF4090CD),
      ),
      body: Center(
        child: Icon(Icons.school, size: 80, color: Color(0xFF133476)),
      ),
    );
  }
}
