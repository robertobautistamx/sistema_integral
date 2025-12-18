import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import '../Controlador/registro_controller.dart';
import '../Modelo/registro.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import '../Servicios/activity_service.dart';

class ExportarPagina extends StatefulWidget {
  final String uid;
  const ExportarPagina({super.key, required this.uid});

  @override
  State<ExportarPagina> createState() => _ExportarPaginaState();
}

class _ExportarPaginaState extends State<ExportarPagina> {
  late RegistroController _controller;
  bool _loading = true;
  List<Registro> _registros = [];

  @override
  void initState() {
    super.initState();
    _controller = RegistroController(uid: widget.uid);
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    await _controller.init();
    final r = await _controller.fetchRegistros(limit: 1000);
    if (!mounted) return;
    setState(() {
      _registros = r;
      _loading = false;
    });
  }

  Future<Uint8List> _generatePdf(PdfPageFormat format) async {
    final doc = pw.Document();
    final styleHeader = pw.TextStyle(
      fontSize: 18,
      fontWeight: pw.FontWeight.bold,
    );
    final styleNormal = pw.TextStyle(fontSize: 11);

    doc.addPage(
      pw.MultiPage(
        pageFormat: format,
        build: (context) {
          return [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Expediente - Registros de glucosa',
                      style: styleHeader,
                    ),
                    pw.SizedBox(height: 6),
                    pw.Text('Usuario: ${widget.uid}', style: styleNormal),
                  ],
                ),
                pw.Text(
                  DateTime.now().toString().split('.').first,
                  style: styleNormal,
                ),
              ],
            ),
            pw.SizedBox(height: 12),
            pw.Divider(),
            pw.SizedBox(height: 8),
            if (_registros.isEmpty)
              pw.Center(
                child: pw.Text(
                  'No hay registros para exportar',
                  style: styleNormal,
                ),
              )
            else
              pw.Table.fromTextArray(
                headers: [
                  'Fecha',
                  'Glucosa',
                  'Presión',
                  'Pulso',
                  'Peso',
                  'Nota',
                ],
                data:
                    _registros.map((r) {
                      final fecha =
                          r.fecha.toLocal().toString().split('.').first;
                      return [
                        fecha,
                        r.glucosa.toStringAsFixed(1),
                        r.presion ?? '',
                        r.pulso?.toString() ?? '',
                        r.peso?.toStringAsFixed(1) ?? '',
                        r.nota ?? '',
                      ];
                    }).toList(),
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 11,
                ),
                cellStyle: styleNormal,
                cellAlignment: pw.Alignment.centerLeft,
                headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
                cellHeight: 22,
                columnWidths: {
                  0: pw.FlexColumnWidth(2),
                  1: pw.FlexColumnWidth(1),
                  2: pw.FlexColumnWidth(1.5),
                  3: pw.FlexColumnWidth(1),
                  4: pw.FlexColumnWidth(1),
                  5: pw.FlexColumnWidth(2),
                },
              ),
            pw.SizedBox(height: 18),
            pw.Divider(),
            pw.Padding(
              padding: const pw.EdgeInsets.only(top: 6),
              child: pw.Text(
                'Generado desde la app Sistema Integral',
                style: pw.TextStyle(fontSize: 9, color: PdfColors.grey),
              ),
            ),
          ];
        },
      ),
    );

    return doc.save();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Exportar / Vista previa',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () async {
                            try {
                              final pdf = await _generatePdf(PdfPageFormat.a4);
                              await Printing.sharePdf(
                                bytes: pdf,
                                filename: 'registros_glucosa.pdf',
                              );
                              await ActivityService.logActivity(
                                uid: widget.uid,
                                tipo: 'export',
                                title: 'Exportó PDF',
                                detail: 'Exportación de registros',
                              );
                            } catch (e) {
                              _showPrintError(context, e);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                          ),
                          icon: const Icon(
                            Icons.share_outlined,
                            color: Colors.white,
                          ),
                          label: const Text(
                            'Compartir PDF',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: () async {
                            try {
                              final pdf = await _generatePdf(PdfPageFormat.a4);
                              // layoutPdf puede fallar si no hay implementación nativa -> capturamos
                              await Printing.layoutPdf(
                                onLayout: (format) => pdf,
                              );
                            } on MissingPluginException catch (_) {
                              // fallback: compartir si imprimir no está implementado
                              final pdf = await _generatePdf(PdfPageFormat.a4);
                              await Printing.sharePdf(
                                bytes: pdf,
                                filename: 'registros_glucosa.pdf',
                              );
                            } catch (e) {
                              _showPrintError(context, e);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                          ),
                          icon: const Icon(
                            Icons.save_alt_outlined,
                            color: Colors.white,
                          ),
                          label: const Text(
                            'Guardar / Imprimir',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: PdfPreview(
                        build: (format) => _generatePdf(format),
                        allowPrinting: true,
                        allowSharing: true,
                        canChangePageFormat: false,
                        initialPageFormat: PdfPageFormat.a4,
                        pdfFileName: 'registros_glucosa.pdf',
                        loadingWidget: const Center(
                          child: CircularProgressIndicator(),
                        ),
                        maxPageWidth: 700,
                      ),
                    ),
                  ),
                ],
              ),
    );
  }

  void _showPrintError(BuildContext context, Object e) {
    final msg =
        (e is MissingPluginException)
            ? 'Funcionalidad de impresión no disponible en este dispositivo/emulador.'
            : 'Ocurrió un error al generar el PDF: $e';
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Error'),
            content: Text(msg),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Aceptar'),
              ),
            ],
          ),
    );
  }
}
