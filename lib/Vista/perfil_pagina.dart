import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class PerfilPagina extends StatefulWidget {
  const PerfilPagina({super.key});

  @override
  State<PerfilPagina> createState() => _PerfilPaginaState();
}

class _PerfilPaginaState extends State<PerfilPagina> {
  final _user = FirebaseAuth.instance.currentUser;
  bool _loading = true;
  String _nombre = '';
  String _email = '';
  final _nameCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (_user == null) return;
    final doc =
        await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(_user!.uid)
            .get();
    if (!mounted) return;
    setState(() {
      _nombre = doc.data()?['nombre'] ?? (_user!.displayName ?? '');
      _email = _user!.email ?? '';
      _nameCtrl.text = _nombre;
      _loading = false;
    });
  }

  Future<void> _save() async {
    if (_user == null) return;
    final nuevo = _nameCtrl.text.trim();
    if (nuevo.isEmpty) return;
    setState(() => _loading = true);
    await FirebaseFirestore.instance.collection('usuarios').doc(_user!.uid).set(
      {'nombre': nuevo},
      SetOptions(merge: true),
    );
    setState(() {
      _nombre = nuevo;
      _loading = false;
    });
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Nombre actualizado')));
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Perfil',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      child: Text(
                        _nombre.isEmpty ? '?' : _nombre[0].toUpperCase(),
                        style: const TextStyle(fontSize: 36),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _nombre,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _email,
                      style: GoogleFonts.poppins(color: Colors.black54),
                    ),
                    const SizedBox(height: 18),
                    TextField(
                      controller: _nameCtrl,
                      decoration: const InputDecoration(labelText: 'Nombre'),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cerrar'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _save,
                          child: const Text('Guardar'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
    );
  }
}
