import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TutorialPagina extends StatefulWidget {
  const TutorialPagina({super.key});

  @override
  State<TutorialPagina> createState() => _TutorialPaginaState();
}

class _TutorialPaginaState extends State<TutorialPagina> {
  final PageController _controller = PageController();
  int _page = 0;

  final List<Map<String, String>> _slides = [
    {
      'title': 'Bienvenido',
      'body':
          'Conoce las funciones principales: registrar medidas, ver historial y exportar PDF.',
    },
    {
      'title': 'Registrar',
      'body':
          'Toca el botón + o "Registrar" para añadir una nueva medida de glucosa con nota y foto opcional.',
    },
    {
      'title': 'Historial',
      'body':
          'En "Historial" puedes revisar, filtrar y compartir tus registros fácilmente.',
    },
    {
      'title': 'Exportar',
      'body':
          'Usa "Exportar" para generar un PDF con tus registros y compartirlo o imprimirlo.',
    },
    {
      'title': 'Notificaciones',
      'body':
          'Activa recordatorios en Configuración para recibir alertas diarias.',
    },
  ];

  void _next() {
    if (_page < _slides.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pop(context);
    }
  }

  void _skip() {
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(_slides.length, (i) {
        final active = i == _page;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 18 : 8,
          height: 8,
          decoration: BoxDecoration(
            color:
                active ? Theme.of(context).primaryColor : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(8),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tutorial',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _skip,
            child: Text(
              'Saltar',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _slides.length,
                onPageChanged: (p) => setState(() => _page = p),
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // icon / ilustración simple
                      Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).primaryColor.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            Icons.school,
                            size: 48,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        slide['title']!,
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        slide['body']!,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(color: Colors.black54),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            _buildIndicator(),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _skip,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text('Cerrar', style: GoogleFonts.poppins()),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _next,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      _page < _slides.length - 1 ? 'Siguiente' : 'Finalizar',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
