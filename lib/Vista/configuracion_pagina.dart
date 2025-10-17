import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sistema_integral/Vista/theme_service.dart';

class ConfiguracionPagina extends StatefulWidget {
  const ConfiguracionPagina({super.key});

  @override
  State<ConfiguracionPagina> createState() => _ConfiguracionPaginaState();
}

class _ConfiguracionPaginaState extends State<ConfiguracionPagina> {
  bool _notificaciones = true;
  bool _modoOscuro = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificaciones = prefs.getBool('notificaciones') ?? true;
      _modoOscuro = prefs.getBool('modo_oscuro') ?? false;
      _loading = false;
    });
  }

  Future<void> _setNotificaciones(bool v) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificaciones', v);
    setState(() => _notificaciones = v);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          v ? 'Notificaciones activadas' : 'Notificaciones desactivadas',
        ),
      ),
    );
    // Aquí puedes añadir lógica para registrar/cancelar notificaciones locales si lo deseas.
  }

  Future<void> _setModoOscuro(bool v) async {
    await ThemeService.setDark(v); // guarda y aplica
    setState(() => _modoOscuro = v);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(v ? 'Modo oscuro activado' : 'Modo oscuro desactivado'),
      ),
    );
  }

  Future<void> _guardar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificaciones', _notificaciones);
    await prefs.setBool('modo_oscuro', _modoOscuro);
    // ensure ThemeService reflects latest
    await ThemeService.setDark(_modoOscuro);
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Ajustes guardados')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Configuración',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Notificaciones'),
                      subtitle: const Text('Recibir alertas y recordatorios'),
                      value: _notificaciones,
                      onChanged: (v) => _setNotificaciones(v),
                    ),
                    SwitchListTile(
                      title: const Text('Modo oscuro (UI local)'),
                      subtitle: const Text(
                        'Cambiar esquema de colores de la app',
                      ),
                      value: _modoOscuro,
                      onChanged: (v) => _setModoOscuro(v),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _guardar,
                      icon: const Icon(Icons.save_outlined),
                      label: const Text('Guardar ajustes'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
