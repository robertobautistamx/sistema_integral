import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class ActividadPagina extends StatefulWidget {
  const ActividadPagina({super.key});

  @override
  State<ActividadPagina> createState() => _ActividadPaginaState();
}

class _ActividadPaginaState extends State<ActividadPagina> {
  final _fire = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  bool _loading = true;
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _items = [];

  @override
  void initState() {
    super.initState();
    _loadActividad();
  }

  Future<void> _loadActividad() async {
    final user = _auth.currentUser;
    if (user == null) {
      if (mounted)
        setState(() {
          _loading = false;
          _items = [];
        });
      return;
    }
    try {
      final q =
          await _fire
              .collection('actividad')
              .where('uid', isEqualTo: user.uid)
              .orderBy('createdAt', descending: true)
              .limit(100)
              .get();

      if (mounted)
        setState(() {
          _items = q.docs;
          _loading = false;
        });
    } on FirebaseException catch (e) {
      // fallback (si requiere índice): trae sin orderBy y ordena localmente
      try {
        final qFallback =
            await _fire
                .collection('actividad')
                .where('uid', isEqualTo: user.uid)
                .get();
        final docs = qFallback.docs;
        docs.sort((a, b) {
          final ta = a.data()['createdAt'];
          final tb = b.data()['createdAt'];
          DateTime da =
              ta is Timestamp
                  ? ta.toDate()
                  : DateTime.tryParse(ta.toString()) ??
                      DateTime.fromMillisecondsSinceEpoch(0);
          DateTime db =
              tb is Timestamp
                  ? tb.toDate()
                  : DateTime.tryParse(tb.toString()) ??
                      DateTime.fromMillisecondsSinceEpoch(0);
          return db.compareTo(da);
        });
        if (mounted)
          setState(() {
            _items = docs;
            _loading = false;
          });
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Mostrando actividad (ordenada localmente)'),
            ),
          );
      } catch (_) {
        if (mounted)
          setState(() {
            _loading = false;
            _items = [];
          });
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error cargando actividad: ${e.message ?? e}'),
            ),
          );
      }
    } catch (e) {
      if (mounted)
        setState(() {
          _loading = false;
          _items = [];
        });
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error cargando actividad: $e')));
    }
  }

  String _fmtTimestamp(dynamic ts) {
    try {
      if (ts == null) return '';
      DateTime d;
      if (ts is Timestamp)
        d = ts.toDate();
      else if (ts is DateTime)
        d = ts;
      else
        d = DateTime.parse(ts.toString());
      return DateFormat('dd/MM/yyyy HH:mm').format(d);
    } catch (_) {
      return ts?.toString() ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final tipoInfo = <String, Map<String, dynamic>>{
      'registro': {
        'icon': Icons.opacity,
        'title': 'Registro de glucosa',
        'color': Colors.blue,
      },
      'login': {
        'icon': Icons.login,
        'title': 'Inicio de sesión',
        'color': Colors.green,
      },
      'logout': {
        'icon': Icons.logout,
        'title': 'Cierre de sesión',
        'color': Colors.grey,
      },
      'perfil': {
        'icon': Icons.person,
        'title': 'Perfil actualizado',
        'color': Colors.indigo,
      },
      'export': {
        'icon': Icons.download,
        'title': 'Exportó PDF',
        'color': Colors.deepPurple,
      },
      'config': {
        'icon': Icons.settings,
        'title': 'Cambio de configuración',
        'color': Colors.orange,
      },
      'recordatorio': {
        'icon': Icons.alarm,
        'title': 'Recordatorio',
        'color': Colors.teal,
      },
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Historial de actividad',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : _items.isEmpty
              ? Center(
                child: Text(
                  'No se encontraron registros',
                  style: GoogleFonts.poppins(),
                ),
              )
              : RefreshIndicator(
                onRefresh: _loadActividad,
                child: ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: _items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final data = _items[i].data();
                    final tipo = (data['tipo'] as String?) ?? 'registro';
                    final info = tipoInfo[tipo] ?? tipoInfo['registro']!;
                    final title = (data['title'] as String?) ?? info['title'];
                    final subtitle =
                        (data['detail'] as String?) ??
                        _fmtTimestamp(data['createdAt']);
                    final extra =
                        (data['extra'] as Map<String, dynamic>?) ?? {};

                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: Icon(
                          info['icon'] as IconData,
                          color: info['color'] as Color,
                        ),
                        title: Text(
                          title,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          subtitle,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                        trailing:
                            extra.isNotEmpty
                                ? const Icon(Icons.chevron_right)
                                : null,
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (_) {
                              return Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      title,
                                      style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Fecha: ${_fmtTimestamp(data['createdAt'])}',
                                      style: GoogleFonts.poppins(),
                                    ),
                                    const SizedBox(height: 8),
                                    if ((data['detail'] as String?)
                                            ?.isNotEmpty ??
                                        false)
                                      Text(
                                        'Detalle: ${data['detail']}',
                                        style: GoogleFonts.poppins(),
                                      ),
                                    if (extra.isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      Text(
                                        'Datos:',
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      for (final e in extra.entries)
                                        Text(
                                          '${e.key}: ${e.value}',
                                          style: GoogleFonts.poppins(),
                                        ),
                                    ],
                                    const SizedBox(height: 12),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Cerrar'),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
    );
  }
}
