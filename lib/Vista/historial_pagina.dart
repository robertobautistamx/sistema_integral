import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Controlador/registro_controller.dart';
import '../Modelo/registro.dart';

class HistorialPagina extends StatefulWidget {
  final String uid;
  const HistorialPagina({super.key, required this.uid});

  @override
  State<HistorialPagina> createState() => _HistorialPaginaState();
}

class _HistorialPaginaState extends State<HistorialPagina> {
  late RegistroController _controller;
  bool _loading = true;
  List<Registro> _registros = [];

  final Color _primary = const Color(0xFF3F84D4);
  final Color _accent = const Color(0xFF5A4FBF);
  final double _chartHeight = 260;

  @override
  void initState() {
    super.initState();
    _controller = RegistroController(uid: widget.uid);
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    await _controller.init();
    final r = await _controller.fetchRegistros(limit: 500);
    if (!mounted) return;
    setState(() {
      _registros = r.reversed.toList(); // ascendente
      _loading = false;
    });
  }

  double get _avg {
    if (_registros.isEmpty) return 0;
    final s = _registros.fold<double>(0, (p, e) => p + e.glucosa);
    return s / _registros.length;
  }

  double get _min {
    if (_registros.isEmpty) return 0;
    return _registros.map((e) => e.glucosa).reduce((a, b) => a < b ? a : b);
  }

  double get _max {
    if (_registros.isEmpty) return 0;
    return _registros.map((e) => e.glucosa).reduce((a, b) => a > b ? a : b);
  }

  List<FlSpot> _spots() {
    return List.generate(
      _registros.length,
      (i) => FlSpot(i.toDouble(), _registros[i].glucosa),
    );
  }

  double _minY() {
    final min = _registros.isEmpty ? 0 : _min;
    return (min - 30).clamp(0, double.infinity).toDouble();
  }

  double _maxY() {
    final max = _registros.isEmpty ? 200 : _max;
    return max + 30;
  }

  String _fmtDate(DateTime d) {
    final l = d.toLocal();
    return '${l.day.toString().padLeft(2, '0')}/${l.month.toString().padLeft(2, '0')} ${l.hour.toString().padLeft(2, '0')}:${l.minute.toString().padLeft(2, '0')}';
  }

  Widget _chartCard() {
    final spots = _spots();
    if (spots.isEmpty) {
      return SizedBox(
        height: _chartHeight,
        child: Center(
          child: Text(
            'Aún no hay datos para graficar',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
      );
    }

    return SizedBox(
      height: _chartHeight,
      child: LineChart(
        LineChartData(
          minY: _minY(),
          maxY: _maxY(),
          gridData: FlGridData(
            show: true,
            horizontalInterval: 20,
            getDrawingHorizontalLine:
                (v) => FlLine(
                  color: Colors.grey.withOpacity(0.12),
                  strokeWidth: 1,
                ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                interval: 20,
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= _registros.length)
                    return const SizedBox.shrink();
                  // show only a few labels
                  final step = (_registros.length / 5).ceil().clamp(
                    1,
                    _registros.length,
                  );
                  if (idx % step != 0 && idx != _registros.length - 1)
                    return const SizedBox.shrink();
                  final d = _registros[idx].fecha;
                  return SideTitleWidget(
                    child: Text(
                      '${d.day}/${d.month}',
                      style: const TextStyle(fontSize: 11),
                    ),
                    meta: meta,
                  );
                },
              ),
            ),
          ),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems:
                  (touched) =>
                      touched
                          .map((t) {
                            final idx = t.x.toInt();
                            if (idx < 0 || idx >= _registros.length)
                              return null;
                            final r = _registros[idx];
                            return LineTooltipItem(
                              '${r.glucosa.toStringAsFixed(1)} mg/dL\n${_fmtDate(r.fecha)}',
                              const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          })
                          .whereType<LineTooltipItem>()
                          .toList(),
            ),
          ),
          extraLinesData: ExtraLinesData(
            horizontalLines: [
              HorizontalLine(
                y: 70,
                color: Colors.orange.withOpacity(0.8),
                strokeWidth: 1,
                dashArray: [6, 4],
              ),
              HorizontalLine(
                y: 140,
                color: Colors.green.withOpacity(0.8),
                strokeWidth: 1,
                dashArray: [6, 4],
              ),
            ],
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: _primary,
              barWidth: 3.5,
              dotData: FlDotData(
                show: true,
                getDotPainter: (s, p, bar, idx) {
                  final value = s.y;
                  Color fill;
                  if (value < 70)
                    fill = Colors.orange;
                  else if (value <= 140)
                    fill = Colors.green;
                  else if (value <= 200)
                    fill = Colors.amber;
                  else
                    fill = Colors.red;
                  return FlDotCirclePainter(
                    radius: 4.5,
                    color: fill,
                    strokeWidth: 1.2,
                    strokeColor: Colors.white,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                color: _primary.withOpacity(0.18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDetalle(Registro r) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder:
          (_) => Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: _accent,
                      child: Text(
                        r.glucosa.toStringAsFixed(0),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${r.glucosa.toStringAsFixed(1)} mg/dL',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _fmtDate(r.fecha),
                          style: const TextStyle(color: Colors.black54),
                        ),
                      ],
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    if (r.presion != null && r.presion!.isNotEmpty)
                      Chip(label: Text('Presión: ${r.presion}')),
                    if ((r.pulso ?? 0) > 0)
                      Chip(label: Text('Pulso: ${r.pulso} lpm')),
                    if ((r.peso ?? 0) > 0)
                      Chip(label: Text('Peso: ${r.peso} kg')),
                  ],
                ),
                if (r.nota != null && r.nota!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Text(
                    'Nota',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(r.nota!),
                ],
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cerrar'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () async {
                        Navigator.pop(context);
                        await _confirmDelete(r);
                      },
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Eliminar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
    );
  }

  Future<void> _confirmDelete(Registro r) async {
    final ok = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Eliminar registro'),
            content: Text(
              '¿Eliminar registro ${r.glucosa.toStringAsFixed(1)} mg/dL?\n${_fmtDate(r.fecha)}',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Eliminar',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
    if (ok != true) return;
    if (r.id == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Registro sin id')));
      return;
    }
    final success = await _controller.deleteRegistro(r.id!);
    if (success) {
      await _load();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registro eliminado'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo eliminar'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

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
          child: Theme(
            data: Theme.of(context).copyWith(
              splashFactory: NoSplash.splashFactory,
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () => Navigator.pop(context),
              enableFeedback: false,
              splashRadius: 20,
            ),
          ),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.show_chart, size: 20, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              'Historial y tendencias',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _load,
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [_accent, _primary]),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _primary.withOpacity(0.24),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.sync_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    // summary + chart
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 6,
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Resumen y tendencia',
                                        style: TextStyle(
                                          color: _accent,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.2,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        '${_registros.isEmpty ? '-' : _registros.last.glucosa.toStringAsFixed(1)} mg/dL',
                                        style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Promedio: ${_registros.isEmpty ? '-' : _avg.toStringAsFixed(1)} • Min: ${_registros.isEmpty ? '-' : _min.toStringAsFixed(0)} • Max: ${_registros.isEmpty ? '-' : _max.toStringAsFixed(0)}',
                                        style: const TextStyle(
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 200, child: _chartCard()),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // list
                    Expanded(
                      child:
                          _registros.isEmpty
                              ? Center(
                                child: Text(
                                  'Sin registros',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              )
                              : ListView.separated(
                                itemCount: _registros.length,
                                separatorBuilder:
                                    (_, __) => const Divider(height: 1),
                                itemBuilder: (context, i) {
                                  final r =
                                      _registros[_registros.length - 1 - i];
                                  Color color;
                                  if (r.glucosa < 70)
                                    color = Colors.orange;
                                  else if (r.glucosa <= 140)
                                    color = Colors.green;
                                  else if (r.glucosa <= 200)
                                    color = Colors.amber;
                                  else
                                    color = Colors.red;
                                  return Dismissible(
                                    key: ValueKey(
                                      r.id ??
                                          '${r.fecha.millisecondsSinceEpoch}-$i',
                                    ),
                                    direction: DismissDirection.endToStart,
                                    confirmDismiss: (_) async {
                                      await _confirmDelete(r);
                                      return false; // prevent auto-dismiss; reload list in _confirmDelete
                                    },
                                    background: Container(
                                      color: Colors.redAccent,
                                      alignment: Alignment.centerRight,
                                      padding: const EdgeInsets.only(right: 18),
                                      child: const Icon(
                                        Icons.delete_forever,
                                        color: Colors.white,
                                      ),
                                    ),
                                    child: ListTile(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                      leading: CircleAvatar(
                                        backgroundColor: color,
                                        child: Text(
                                          r.glucosa.toStringAsFixed(0),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      title: Text(
                                        '${r.glucosa.toStringAsFixed(1)} mg/dL',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      subtitle: Text(_fmtDate(r.fecha)),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            onPressed: () => _showDetalle(r),
                                            icon: const Icon(
                                              Icons.info_outline,
                                            ),
                                          ),
                                          IconButton(
                                            onPressed: () => _confirmDelete(r),
                                            icon: const Icon(
                                              Icons.delete_outline,
                                              color: Colors.redAccent,
                                            ),
                                          ),
                                        ],
                                      ),
                                      onTap: () => _showDetalle(r),
                                    ),
                                  );
                                },
                              ),
                    ),
                  ],
                ),
              ),
    );
  }
}
