import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PrivacidadPagina extends StatelessWidget {
  const PrivacidadPagina({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Política de privacidad',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(14),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Política de privacidad',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Esta aplicación respeta tu privacidad. A continuación un resumen corto:',
                style: GoogleFonts.poppins(),
              ),
              const SizedBox(height: 8),
              Text(
                '• Datos que recolectamos: nombre, correo, registros médicos (glucosa, notas), preferencias.',
                style: GoogleFonts.poppins(),
              ),
              const SizedBox(height: 6),
              Text(
                '• Uso de la información: para mostrar tu historial, generar reportes y recordatorios locales.',
                style: GoogleFonts.poppins(),
              ),
              const SizedBox(height: 6),
              Text(
                '• Almacenamiento: los datos se guardan en Firebase (Firestore).',
                style: GoogleFonts.poppins(),
              ),
              const SizedBox(height: 6),
              Text(
                '• Compartir datos: sólo cuando tú lo solicites (exportar/compartir PDF).',
                style: GoogleFonts.poppins(),
              ),
              const SizedBox(height: 12),
              Text(
                'Si quieres la versión completa en PDF o un enlace externo, indícalo y la añado.',
                style: GoogleFonts.poppins(color: Colors.black54),
              ),
              const SizedBox(height: 18),
              Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Aceptar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
