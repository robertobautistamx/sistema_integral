class Registro {
  String? id;
  double glucosa;
  String? presion;
  int? pulso;
  double? peso;
  String? nota;
  DateTime fecha;
  bool sincronizado;

  Registro({
    this.id,
    required this.glucosa,
    this.presion,
    this.pulso,
    this.peso,
    this.nota,
    DateTime? fecha,
    this.sincronizado = false,
  }) : fecha = fecha ?? DateTime.now();

  // Mapa para guardar localmente (JSON)
  Map<String, dynamic> toMapForLocal() {
    return {
      'glucosa': glucosa,
      'presion': presion ?? '',
      'pulso': pulso,
      'peso': peso,
      'nota': nota ?? '',
      'fecha': fecha.toUtc().toIso8601String(),
      'sincronizado': sincronizado,
    };
  }

  // Mapa para subir a Firestore
  Map<String, dynamic> toMapForFirestore() {
    return {
      'glucosa': glucosa,
      'presion': presion ?? '',
      'pulso': pulso,
      'peso': peso,
      'nota': nota ?? '',
      'fecha': fecha.toUtc(),
      'sincronizado': true,
    };
  }

  // Construir desde mapa local (JSON)
  factory Registro.fromMapLocal(Map<String, dynamic> map) {
    return Registro(
      glucosa: (map['glucosa'] as num).toDouble(),
      presion: map['presion'] as String?,
      pulso: (map['pulso'] as num?)?.toInt(),
      peso: (map['peso'] as num?)?.toDouble(),
      nota: map['nota'] as String?,
      fecha: DateTime.parse(map['fecha'] as String),
      sincronizado: map['sincronizado'] == true,
    );
  }

  // Construir desde documento Firestore (maneja Timestamp o String)
  factory Registro.fromFirestoreDoc(Map<String, dynamic> map, String id) {
    DateTime fechaParsed = DateTime.now();
    final f = map['fecha'];
    if (f != null) {
      try {
        fechaParsed = (f as dynamic).toDate();
      } catch (_) {
        try {
          fechaParsed = DateTime.parse(f as String);
        } catch (_) {
          fechaParsed = DateTime.now();
        }
      }
    }
    return Registro(
      id: id,
      glucosa: (map['glucosa'] as num).toDouble(),
      presion: map['presion'] as String?,
      pulso: (map['pulso'] as num?)?.toInt(),
      peso: (map['peso'] as num?)?.toDouble(),
      nota: map['nota'] as String?,
      fecha: fechaParsed,
      sincronizado: map['sincronizado'] == true,
    );
  }
}
