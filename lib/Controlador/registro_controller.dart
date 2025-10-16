// ignore_for_file: unused_import, depend_on_referenced_packages

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import '../Modelo/registro.dart';

class RegistroController {
  final String uid;
  Database? _db;
  final CollectionReference _usersRef = FirebaseFirestore.instance.collection(
    'usuarios',
  );

  RegistroController({required this.uid});

  Future<void> init() async {
    if (_db != null) return;
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, 'sistema_integral.db');
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE IF NOT EXISTS pendientes (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          data TEXT NOT NULL
        )
      ''');
      },
    );
  }

  Future<void> dispose() async {
    await _db?.close();
    _db = null;
  }

  Future<bool> saveRegistro(Registro reg) async {
    await init();
    final mapa = reg.toMapForFirestore();
    try {
      await _usersRef.doc(uid).collection('registros').add(mapa);
      return true;
    } catch (e) {
      await _guardarLocal(reg.toMapForLocal());
      return false;
    }
  }

  Future<void> _guardarLocal(Map<String, dynamic> mapa) async {
    if (_db == null) await init();
    await _db!.insert('pendientes', {'data': jsonEncode(mapa)});
  }

  Future<void> _eliminarPendiente(int id) async {
    if (_db == null) await init();
    await _db!.delete('pendientes', where: 'id = ?', whereArgs: [id]);
  }

  // Método público para obtener la cantidad de pendientes
  Future<int> pendientesCount() async {
    if (_db == null) await init();
    final List<Map<String, Object?>> rows = await _db!.query(
      'pendientes',
      columns: ['id'],
    );
    return rows.length;
  }

  Future<void> syncPendientes() async {
    if (_db == null) await init();
    final List<Map<String, Object?>> rows = await _db!.query('pendientes');
    for (final row in rows) {
      try {
        final int id = row['id'] as int;
        final Map<String, dynamic> registro = jsonDecode(row['data'] as String);
        await _usersRef.doc(uid).collection('registros').add({
          'glucosa': registro['glucosa'],
          'presion': registro['presion'],
          'pulso': registro['pulso'],
          'peso': registro['peso'],
          'nota': registro['nota'],
          'fecha': FieldValue.serverTimestamp(),
          'sincronizado': true,
        });
        await _eliminarPendiente(id);
      } catch (_) {
        // si falla se mantiene el pendiente
      }
    }
  }

  // Stream público de registros desde Firestore
  Stream<List<Registro>> streamRegistros() {
    final col = _usersRef
        .doc(uid)
        .collection('registros')
        .orderBy('fecha', descending: true);
    return col.snapshots().map((snap) {
      return snap.docs.map((d) {
        final data = d.data() as Map<String, dynamic>;
        return Registro.fromFirestoreDoc(data, d.id);
      }).toList();
    });
  }
}
