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

  // paleta
  final Color _azulPrincipal = const Color(0xFF4090CD);
  final Color _azulOscuro = const Color(0xFF133476);
  final Color _fondo = const Color(0xFFFBF6FA);

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
      if (t != null) {
        setState(() {
          _fecha = DateTime(f.year, f.month, f.day, t.hour, t.minute);
        });
      } else {
        setState(() {
          _fecha = DateTime(f.year, f.month, f.day, _fecha.hour, _fecha.minute);
        });
      }
    }
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

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
    if (!mounted) return;
    setState(() => _saving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Registro guardado en la nube'
              : 'Sin conexión: guardado localmente',
        ),
        backgroundColor:
            success ? Colors.green.shade700 : Colors.orange.shade700,
        duration: const Duration(seconds: 2),
      ),
    );

    if (success) {
      _formKey.currentState!.reset();
      _fecha = DateTime.now();
      Navigator.pop(context);
    } else {
      _formKey.currentState!.reset();
      _fecha = DateTime.now();
      Navigator.pop(context);
    }

    _controller.syncPendientes();
  }

  String _formatFecha(DateTime d) {
    final local = d.toLocal();
    final y = local.year.toString().padLeft(4, '0');
    final m = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    final h = local.hour.toString().padLeft(2, '0');
    final min = local.minute.toString().padLeft(2, '0');
    return '$day/$m/$y  $h:$min';
  }

  InputDecoration _fieldDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: _azulOscuro),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _fondo,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: _azulPrincipal,
        title: const Text('Registrar Glucosa'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // header card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _azulPrincipal.withOpacity(0.95),
                    _azulOscuro.withOpacity(0.9),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: _azulOscuro.withOpacity(0.12),
                    blurRadius: 12,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.opacity,
                      size: 28,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Registro de Glucosa',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Registra tu medición rápida y segura',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _pickFecha,
                    icon: const Icon(
                      Icons.calendar_today,
                      color: Colors.white70,
                      size: 18,
                    ),
                    label: Text(
                      _formatFecha(_fecha),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // form container
            Card(
              elevation: 6,
              shadowColor: _azulOscuro.withOpacity(0.12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 16,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _glucosaCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: _fieldDecoration(
                          'Glucosa (mg/dL)',
                          Icons.bloodtype_outlined,
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty)
                            return 'Ingrese valor de glucosa';
                          final n = double.tryParse(v);
                          if (n == null) return 'Valor numérico inválido';
                          if (n <= 0) return 'Valor debe ser mayor que cero';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _presionCtrl,
                        decoration: _fieldDecoration(
                          'Presión (ej. 120/80)',
                          Icons.favorite_border,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _pulsoCtrl,
                              keyboardType: TextInputType.number,
                              decoration: _fieldDecoration(
                                'Pulso (lpm)',
                                Icons.speed,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _pesoCtrl,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              decoration: _fieldDecoration(
                                'Peso (kg)',
                                Icons.monitor_weight,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _notaCtrl,
                        maxLines: 4,
                        decoration: _fieldDecoration(
                          'Nota (opcional)',
                          Icons.note,
                        ),
                      ),
                      const SizedBox(height: 18),

                      // save button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _saving ? null : _guardar,
                          icon:
                              _saving
                                  ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                  : const Icon(Icons.save_outlined),
                          label: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            child: Text(
                              _saving ? 'Guardando...' : 'Guardar registro',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _azulPrincipal,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 6,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextButton(
                        onPressed: () {
                          _formKey.currentState?.reset();
                          _glucosaCtrl.clear();
                          _presionCtrl.clear();
                          _pulsoCtrl.clear();
                          _pesoCtrl.clear();
                          _notaCtrl.clear();
                          setState(() => _fecha = DateTime.now());
                        },
                        child: const Text('Limpiar formulario'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 22),

            // hint
            Row(
              children: [
                Icon(Icons.info_outline, color: _azulPrincipal, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Recomendado: registrar glucosa en ayunas y después de las comidas. Mantén un registro constante para visualizar tendencias.',
                    style: TextStyle(
                      color: _azulOscuro.withOpacity(0.8),
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
