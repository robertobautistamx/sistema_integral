import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:google_fonts/google_fonts.dart';

class DocumentPreviewPagina extends StatelessWidget {
  final Uint8List pdfBytes;
  final String title;
  const DocumentPreviewPagina({
    super.key,
    required this.pdfBytes,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: PdfPreview(
        build: (format) => pdfBytes,
        allowPrinting: true,
        allowSharing: true,
        initialPageFormat: null,
        maxPageWidth: 700,
        loadingWidget: const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
