import 'package:cloud_firestore/cloud_firestore.dart';

class ActivityService {
  static final _col = FirebaseFirestore.instance.collection('actividad');

  /// Registra un evento de actividad en Firestore.
  static Future<void> logActivity({
    required String uid,
    required String tipo,
    required String title,
    String? detail,
    Map<String, dynamic>? extra,
  }) async {
    try {
      await _col.add({
        'uid': uid,
        'tipo':
            tipo, // 'registro'|'login'|'logout'|'perfil'|'export'|'config'|'recordatorio'...
        'title': title,
        'detail': detail ?? '',
        'extra': extra ?? {},
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // no bloquee la app si falla el logging
      // print('ActivityService error: $e');
    }
  }
}
