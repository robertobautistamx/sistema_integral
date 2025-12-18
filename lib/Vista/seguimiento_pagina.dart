// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
import '../Controlador/registro_controller.dart';
import '../Modelo/registro.dart';
import 'registro_glucosa_pagina.dart';
import 'historial_pagina.dart';

class SeguimientoPagina extends StatefulWidget {
  final String uid;
  const SeguimientoPagina({super.key, required this.uid});

  @override
  State<SeguimientoPagina> createState() => _SeguimientoPaginaState();
}

class _SeguimientoPaginaState extends State<SeguimientoPagina> {
  late RegistroController _controller;
  int _pendientes = 0;
  bool _loadingPendientes = true;

  @override
  void initState() {
    super.initState();
    _controller = RegistroController(uid: widget.uid);
    _initController();
  }

  Future<void> _initController() async {
    await _controller.init();
    await _controller.syncPendientes();
    final c = await _controller.pendientesCount();
    if (!mounted) return;
    setState(() {
      _pendientes = c;
      _loadingPendientes = false;
    });
  }

  Color _colorPorValor(double g) {
    if (g < 70) return Colors.orange;
    if (g <= 140) return Colors.green;
    if (g <= 200) return Colors.amber;
    return Colors.red;
  }

  Future<void> _irRegistro() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => RegistroGlucosaPagina(uid: widget.uid)),
    );
    final c = await _controller.pendientesCount();
    if (!mounted) return;
    setState(() => _pendientes = c);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seguimiento de Glucosa'),
        backgroundColor: const Color(0xFF4090CD),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => HistorialPagina(uid: widget.uid),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        backgroundColor: const Color(0xFF4090CD),
        onPressed: _irRegistro,
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child:
                _loadingPendientes
                    ? const LinearProgressIndicator()
                    : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Registros pendientes: $_pendientes',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            await _controller.syncPendientes();
                            final c = await _controller.pendientesCount();
                            if (!mounted) return;
                            setState(() => _pendientes = c);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text(
                            'Sincronizar ahora',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: StreamBuilder<List<Registro>>(
              stream: _controller.streamRegistros(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting)
                  return const Center(child: CircularProgressIndicator());
                final registros = snapshot.data ?? [];
                if (registros.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(
                          Icons.monitor_heart_outlined,
                          size: 72,
                          color: Colors.blueAccent,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Aún no hay registros',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: registros.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final r = registros[index];
                    final color = _colorPorValor(r.glucosa);
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: color,
                          child: const Icon(Icons.opacity, color: Colors.white),
                        ),
                        title: Text(
                          '${r.glucosa.toStringAsFixed(1)} mg/dL',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '${r.presion ?? ''} • ${r.pulso != null ? '${r.pulso} lpm' : ''}\n${r.nota ?? ''}',
                        ),
                        isThreeLine: true,
                        trailing: Text(
                          '${r.fecha.toLocal()}'.split('.').first,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
