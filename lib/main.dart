import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Prueba Firebase',
      home: Scaffold(
        appBar: AppBar(title: const Text('Conexión Firebase')),
        body: const Center(
          child: Text('✅ Conectado a Firebase', style: TextStyle(fontSize: 24)),
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
