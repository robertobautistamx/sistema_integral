import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sistema_integral/Vista/document_preview_pagina.dart';
import 'exportar_pagina.dart';

class ExpedientePagina extends StatefulWidget {
  final String uid;
  const ExpedientePagina({super.key, required this.uid});

  @override
  State<ExpedientePagina> createState() => _ExpedientePaginaState();
}

class _ExpedientePaginaState extends State<ExpedientePagina> {
  final Color _primary = const Color(0xFF3F84D4);
  final Color _accent = const Color(0xFF5A4FBF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF6FA),
      appBar: AppBar(
        elevation: 2,
        backgroundColor: _primary,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () => Navigator.pop(context),
            enableFeedback: false,
            splashRadius: 20,
          ),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.folder_shared, size: 20, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              'Expediente',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 6,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 18,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _accent.withOpacity(0.18),
                            _primary.withOpacity(0.18),
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.folder_shared,
                          color: _primary,
                          size: 34,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Expediente y recursos',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Accede a tus documentos clínicos, certificados y guías personalizadas.',
                            style: GoogleFonts.poppins(
                              color: Colors.black54,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ExportarPagina(uid: widget.uid),
                            ),
                          ),
                      icon: const Icon(Icons.download_outlined),
                      label: const Text('Exportar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Documentos',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                children: [
                  _docTile(
                    title: 'Resumen clínico',
                    subtitle: 'Última actualización: 17/10/2025',
                    icon: Icons.description,
                    color: _accent,
                    onTap: () {},
                  ),
                  _docTile(
                    title: 'Certificado médico',
                    subtitle: 'Disponible',
                    icon: Icons.badge_outlined,
                    color: Colors.teal,
                    onTap: () {},
                  ),
                  _docTile(
                    title: 'Plan de tratamiento',
                    subtitle: 'Ver recomendaciones',
                    icon: Icons.event_note_outlined,
                    color: Colors.deepPurple,
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _docTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.12),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.poppins(color: Colors.black54, fontSize: 12),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Ver -> abre vista previa
            IconButton(
              onPressed: () => _onViewDocument(title, subtitle),
              icon: const Icon(Icons.visibility_outlined),
              tooltip: 'Ver documento',
            ),
            // Compartir -> genera PDF y comparte
            IconButton(
              onPressed: () => _onShareDocument(title, subtitle),
              icon: const Icon(Icons.share_outlined),
              tooltip: 'Compartir documento',
            ),
          ],
        ),
      ),
    );
  }

  Future<Uint8List> _generateSimplePdf(String title, String subtitle) async {
    final doc = pw.Document();
    final styleHeader = pw.TextStyle(
      fontSize: 20,
      fontWeight: pw.FontWeight.bold,
    );
    final styleNormal = pw.TextStyle(fontSize: 12);

    doc.addPage(
      pw.MultiPage(
        build: (context) {
          return [
            pw.Header(level: 0, child: pw.Text(title, style: styleHeader)),
            pw.SizedBox(height: 8),
            pw.Text('Detalle: $subtitle', style: styleNormal),
            pw.SizedBox(height: 12),
            pw.Divider(),
            pw.SizedBox(height: 8),
            pw.Text(
              'Generado: ${DateTime.now().toLocal()}',
              style: pw.TextStyle(fontSize: 9, color: PdfColors.grey),
            ),
          ];
        },
      ),
    );

    return doc.save();
  }

  Future<void> _onViewDocument(String title, String subtitle) async {
    try {
      final bytes = await _generateSimplePdf(title, subtitle);
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => DocumentPreviewPagina(pdfBytes: bytes, title: title),
        ),
      );
    } catch (e) {
      _showMessage('No se pudo generar la vista previa: $e');
    }
  }

  Future<void> _onShareDocument(String title, String subtitle) async {
    try {
      final bytes = await _generateSimplePdf(title, subtitle);
      await Printing.sharePdf(
        bytes: bytes,
        filename: '${title.replaceAll(' ', '_')}.pdf',
      );
    } catch (e) {
      _showMessage('Error al compartir: $e');
    }
  }

  void _showMessage(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
