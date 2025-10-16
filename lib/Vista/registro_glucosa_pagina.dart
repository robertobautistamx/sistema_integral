import 'package:flutter/material.dart';
import '../Controlador/registro_controller.dart';
import '../Modelo/registro.dart';

class RegistroGlucosaPagina extends StatefulWidget {
  final String uid;
  const RegistroGlucosaPagina({super.key, required this.uid});

  @override
  State<RegistroGlucosaPagina> createState() => _RegistroGlucosaPaginaState();
}

class _RegistroGlucosaPaginaState extends State<RegistroGlucosaPagina> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _glucosaCtrl = TextEditingController();
  final TextEditingController _presionCtrl = TextEditingController();
  final TextEditingController _pulsoCtrl = TextEditingController();
  final TextEditingController _pesoCtrl = TextEditingController();
  final TextEditingController _notaCtrl = TextEditingController();

  late RegistroController _controller;
  bool _saving = false;
  DateTime _fecha = DateTime.now();

  @override
  void initState() {
    super.initState();
    _controller = RegistroController(uid: widget.uid);
    _controller.init();
    _controller.syncPendientes();
  }

  @override
  void dispose() {
    _glucosaCtrl.dispose();
    _presionCtrl.dispose();
    _pulsoCtrl.dispose();
    _pesoCtrl.dispose();
    _notaCtrl.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickFecha() async {
    final DateTime? f = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (f != null) {
      final TimeOfDay? t = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_fecha),
      );
      setState(() {
        _fecha = DateTime(f.year, f.month, f.day, t?.hour ?? 0, t?.minute ?? 0);
      });
    }
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    final reg = Registro(
      glucosa: double.parse(_glucosaCtrl.text.trim()),
      presion: _presionCtrl.text.trim(),
      pulso: int.tryParse(_pulsoCtrl.text.trim()),
      peso: double.tryParse(_pesoCtrl.text.trim()),
      nota: _notaCtrl.text.trim(),
      fecha: _fecha,
      sincronizado: false,
    );

    setState(() => _saving = true);
    final success = await _controller.saveRegistro(reg);
    setState(() => _saving = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registro guardado en la nube')),
      );
      _formKey.currentState!.reset();
      _fecha = DateTime.now();
      Navigator.pop(context); // vuelve a lista
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sin conexión: guardado localmente')),
      );
      _formKey.currentState!.reset();
      _fecha = DateTime.now();
      Navigator.pop(context);
    }

    _controller.syncPendientes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar Glucosa')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextButton.icon(
                icon: const Icon(Icons.calendar_today),
                label: Text('Fecha: ${_fecha.toLocal()}'.split('.').first),
                onPressed: _pickFecha,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _glucosaCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Glucosa (mg/dL)',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty)
                    return 'Ingrese valor de glucosa';
                  final n = double.tryParse(v);
                  if (n == null) return 'Valor numérico inválido';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _presionCtrl,
                decoration: const InputDecoration(
                  labelText: 'Presión (ej. 120/80)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _pulsoCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Pulso (lpm)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _pesoCtrl,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Peso (kg)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notaCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Nota (opcional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 18),
              ElevatedButton.icon(
                onPressed: _saving ? null : _guardar,
                icon:
                    _saving
                        ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Icon(Icons.save),
                label: Text(_saving ? 'Guardando...' : 'Guardar registro'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
