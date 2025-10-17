import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'actividad_pagina.dart';
import 'privacidad_pagina.dart';
import '../Servicios/activity_service.dart';

class PerfilPagina extends StatefulWidget {
  const PerfilPagina({super.key});

  @override
  State<PerfilPagina> createState() => _PerfilPaginaState();
}

class _PerfilPaginaState extends State<PerfilPagina> {
  final _auth = FirebaseAuth.instance;
  final _fire = FirebaseFirestore.instance;

  bool _loading = true;
  bool _editingName = false;
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();
  final TextEditingController _pesoCtrl = TextEditingController();
  final TextEditingController _alturaCtrl = TextEditingController();
  DateTime? _fechaNacimiento;
  String? _sexo;
  String _email = '';

  final _genders = ['Masculino', 'Femenino', 'Otro', 'Prefiero no decirlo'];

  @override
  void initState() {
    super.initState();
    _loadPerfil();
  }

  Future<void> _loadPerfil() async {
    final user = _auth.currentUser;
    if (user == null) return;
    _email = user.email ?? '';
    try {
      final doc = await _fire.collection('usuarios').doc(user.uid).get();
      final data = doc.data() ?? {};
      _nameCtrl.text = (data['nombre'] as String?) ?? (user.displayName ?? '');
      _phoneCtrl.text = (data['telefono'] as String?) ?? '';
      _pesoCtrl.text = (data['peso'] != null) ? data['peso'].toString() : '';
      _alturaCtrl.text =
          (data['altura'] != null) ? data['altura'].toString() : '';
      if (data['fechaNacimiento'] is Timestamp) {
        _fechaNacimiento = (data['fechaNacimiento'] as Timestamp).toDate();
      } else if (data['fechaNacimiento'] is String) {
        try {
          _fechaNacimiento = DateTime.parse(data['fechaNacimiento'] as String);
        } catch (_) {}
      }
      _sexo = (data['sexo'] as String?) ?? _genders[0];
    } catch (_) {
      // ignore
    }
    if (mounted) setState(() => _loading = false);
  }

  String _fmtDate(DateTime? d) {
    if (d == null) return 'No especificada';
    return DateFormat('dd/MM/yyyy').format(d);
  }

  Future<void> _pickFecha() async {
    final now = DateTime.now();
    final initial = _fechaNacimiento ?? DateTime(now.year - 30);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null) setState(() => _fechaNacimiento = picked);
  }

  Future<void> _guardar() async {
    final user = _auth.currentUser;
    if (user == null) return;
    setState(() => _loading = true);
    final nombre = _nameCtrl.text.trim();
    final telefono = _phoneCtrl.text.trim();
    final peso = double.tryParse(_pesoCtrl.text.replaceAll(',', '.'));
    final altura = double.tryParse(_alturaCtrl.text.replaceAll(',', '.'));

    final docRef = _fire.collection('usuarios').doc(user.uid);
    final data = {
      'nombre': nombre,
      'telefono': telefono,
      if (peso != null) 'peso': peso,
      if (altura != null) 'altura': altura,
      if (_sexo != null) 'sexo': _sexo,
      if (_fechaNacimiento != null) 'fechaNacimiento': _fechaNacimiento,
      'actualizadoEn': FieldValue.serverTimestamp(),
    };

    try {
      await docRef.set(data, SetOptions(merge: true));
      // Actualizar displayName en FirebaseAuth también
      await user.updateDisplayName(nombre);
      await user.reload();
      if (mounted) {
        setState(() {
          _editingName = false;
          _loading = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Perfil actualizado')));
      }
      await ActivityService.logActivity(
        uid: user.uid,
        tipo: 'perfil',
        title: 'Perfil actualizado',
        detail: 'Nombre y datos actualizados',
      );
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al guardar: $e')));
      }
    }
  }

  Future<void> _enviarCambioContrasena() async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No hay correo disponible')));
      return;
    }
    try {
      await _auth.sendPasswordResetEmail(email: user.email!);
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email para cambiar contraseña enviado'),
          ),
        );
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _pesoCtrl.dispose();
    _alturaCtrl.dispose();
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
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Avatar y nombre editable
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.blue.shade50,
                          child: Text(
                            (_nameCtrl.text.isEmpty
                                ? '?'
                                : _nameCtrl.text[0].toUpperCase()),
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child:
                                        _editingName
                                            ? TextField(
                                              controller: _nameCtrl,
                                              decoration: const InputDecoration(
                                                border: UnderlineInputBorder(),
                                                isDense: true,
                                              ),
                                            )
                                            : Text(
                                              _nameCtrl.text.isEmpty
                                                  ? 'Nombre no especificado'
                                                  : _nameCtrl.text,
                                              style: GoogleFonts.poppins(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit_outlined,
                                      size: 20,
                                    ),
                                    tooltip:
                                        _editingName
                                            ? 'Terminar edición'
                                            : 'Editar nombre',
                                    onPressed:
                                        () => setState(() {
                                          _editingName = !_editingName;
                                          if (!_editingName)
                                            FocusScope.of(context).unfocus();
                                        }),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _email,
                                style: GoogleFonts.poppins(
                                  color: Colors.black54,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Campos del perfil
                    TextField(
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Teléfono',
                        prefixIcon: Icon(Icons.phone),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Fecha nacimiento + sexo (responsive)
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final narrow = constraints.maxWidth < 420;
                        if (narrow) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              GestureDetector(
                                onTap: _pickFecha,
                                child: AbsorbPointer(
                                  child: TextField(
                                    decoration: const InputDecoration(
                                      labelText: 'Fecha de nacimiento',
                                      prefixIcon: Icon(Icons.cake_outlined),
                                    ),
                                    controller: TextEditingController(
                                      text: _fmtDate(_fechaNacimiento),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              DropdownButtonFormField<String>(
                                value: _sexo,
                                decoration: const InputDecoration(
                                  labelText: 'Sexo',
                                ),
                                items:
                                    _genders
                                        .map(
                                          (g) => DropdownMenuItem(
                                            value: g,
                                            child: Text(g),
                                          ),
                                        )
                                        .toList(),
                                onChanged: (v) => setState(() => _sexo = v),
                              ),
                            ],
                          );
                        }
                        // ancho suficiente: fila horizontal
                        return Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: _pickFecha,
                                child: AbsorbPointer(
                                  child: TextField(
                                    decoration: const InputDecoration(
                                      labelText: 'Fecha de nacimiento',
                                      prefixIcon: Icon(Icons.cake_outlined),
                                    ),
                                    controller: TextEditingController(
                                      text: _fmtDate(_fechaNacimiento),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 180),
                              child: DropdownButtonFormField<String>(
                                value: _sexo,
                                decoration: const InputDecoration(
                                  labelText: 'Sexo',
                                ),
                                items:
                                    _genders
                                        .map(
                                          (g) => DropdownMenuItem(
                                            value: g,
                                            child: Text(g),
                                          ),
                                        )
                                        .toList(),
                                onChanged: (v) => setState(() => _sexo = v),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 12),

                    // Peso y altura
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _pesoCtrl,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Peso (kg)',
                              prefixIcon: Icon(Icons.monitor_weight),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _alturaCtrl,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Altura (cm)',
                              prefixIcon: Icon(Icons.height),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Acciones (responsive, evita overflow)
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Wrap(
                          spacing: 12,
                          children: [
                            OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cerrar'),
                            ),
                            ElevatedButton(
                              onPressed: _guardar,
                              child: const Text('Guardar'),
                            ),
                          ],
                        ),
                        TextButton.icon(
                          onPressed: _enviarCambioContrasena,
                          icon: const Icon(Icons.lock_reset_outlined),
                          label: const Text('Cambiar contraseña'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 8),

                    // Información adicional y acciones
                    ListTile(
                      leading: const Icon(Icons.history_edu_outlined),
                      title: const Text('Historial de actividad'),
                      subtitle: const Text(
                        'Ver registros recientes y actividad de la cuenta',
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ActividadPagina(),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.privacy_tip_outlined),
                      title: const Text('Política de privacidad'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PrivacidadPagina(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
    );
  }
}
