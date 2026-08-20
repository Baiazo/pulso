import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/anomaly.dart';
import '../../domain/entities/enums.dart';
import '../../domain/entities/reading.dart';
import '../../domain/entities/session.dart';
import '../export/trip_export.dart';
import '../providers/app_providers.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';

final _timeFmt = DateFormat.Hm();

/// "08B · VIAGEM — DETALHE" do mockup: dois quadros de série temporal
/// empilhados (velocidade, RPM) com o mesmo eixo X, marcados por uma
/// linha tracejada no instante da primeira anomalia da viagem.
class TripDetailScreen extends ConsumerWidget {
  const TripDetailScreen({super.key, required this.session});

  final Session session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: PulsoColors.bg,
      appBar: AppBar(
        backgroundColor: PulsoColors.bg,
        elevation: 0,
        title: Text(_headerTitle(session), style: PulsoTypography.titleScreen),
      ),
      body: FutureBuilder<_TripData>(
        future: _loadTripData(ref, session.id!),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(strokeWidth: 2, color: PulsoColors.accent),
            );
          }
          return _TripDetailBody(session: session, data: snapshot.data!);
        },
      ),
    );
  }

  String _headerTitle(Session session) {
    final end = session.encerradaEm;
    final range = end == null
        ? _timeFmt.format(session.iniciadaEm)
        : '${_timeFmt.format(session.iniciadaEm)} → ${_timeFmt.format(end)}';
    return range;
  }

  Future<_TripData> _loadTripData(WidgetRef ref, int sessionId) async {
    final readingRepo = ref.read(readingRepositoryProvider);
    final anomalyRepo = ref.read(anomalyRepositoryProvider);
    final results = await Future.wait([
      readingRepo.forSession(sessionId, pidKey: 'vehicle_speed'),
      readingRepo.forSession(sessionId, pidKey: 'engine_rpm'),
      anomalyRepo.forSession(sessionId),
    ]);
    return _TripData(
      speed: results[0] as List<Reading>,
      rpm: results[1] as List<Reading>,
      anomalies: results[2] as List<Anomaly>,
    );
  }
}

class _TripData {
  const _TripData({required this.speed, required this.rpm, required this.anomalies});

  final List<Reading> speed;
  final List<Reading> rpm;
  final List<Anomaly> anomalies;
}

class _TripDetailBody extends StatelessWidget {
  const _TripDetailBody({required this.session, required this.data});

  final Session session;
  final _TripData data;

  @override
  Widget build(BuildContext context) {
    final t0 = session.iniciadaEm;
    final stoppedMinutes = _stoppedMinutes(data.speed);
    final markerX = _markerElapsedSeconds(data.anomalies, t0);

    return ListView(
      padding: const EdgeInsets.all(PulsoSpacing.s4),
      children: [
        Row(
          children: [
            _StatChip(
              label: 'CONSUMO',
              value: session.consumoMedioKml != null
                  ? '${session.consumoMedioKml!.toStringAsFixed(1)} km/l'
                  : '—',
            ),
            const SizedBox(width: PulsoSpacing.s6),
            _StatChip(
              label: 'VEL. MÉDIA',
              value: '${_avgSpeed(data.speed).toStringAsFixed(0)} km/h',
            ),
            const SizedBox(width: PulsoSpacing.s6),
            _StatChip(label: 'PARADO', value: '$stoppedMinutes min'),
          ],
        ),
        const SizedBox(height: PulsoSpacing.s7),
        Text('VELOCIDADE', style: PulsoTypography.titleSection),
        const SizedBox(height: PulsoSpacing.s3),
        SizedBox(
          height: 160,
          child: _TimeSeriesChart(
            readings: data.speed,
            t0: t0,
            markerX: markerX,
            color: PulsoColors.series[0],
          ),
        ),
        const SizedBox(height: PulsoSpacing.s6),
        Text('ROTAÇÃO', style: PulsoTypography.titleSection),
        const SizedBox(height: PulsoSpacing.s3),
        SizedBox(
          height: 160,
          child: _TimeSeriesChart(
            readings: data.rpm,
            t0: t0,
            markerX: markerX,
            color: PulsoColors.series[1],
          ),
        ),
        if (data.anomalies.isNotEmpty) ...[
          const SizedBox(height: PulsoSpacing.s7),
          Text('MOMENTOS DE DESVIO', style: PulsoTypography.titleSection),
          const SizedBox(height: PulsoSpacing.s3),
          for (final anomaly in data.anomalies) _AnomalyTile(anomaly: anomaly),
        ],
        const SizedBox(height: PulsoSpacing.s7),
        _ExportButtons(session: session),
        const SizedBox(height: PulsoSpacing.s6),
      ],
    );
  }

  double _avgSpeed(List<Reading> readings) {
    if (readings.isEmpty) return 0;
    final sum = readings.fold<double>(0, (acc, r) => acc + r.valor);
    return sum / readings.length;
  }

  /// Minutos com o carro parado (§12.2: contexto `paradoFrio`/`paradoQuente`
  /// deriva de velocidade abaixo do limiar) — aproximado contando amostras
  /// com velocidade ~0 e convertendo pelo intervalo de amostragem (§8: 1 Hz).
  int _stoppedMinutes(List<Reading> speedReadings) {
    final stoppedSamples = speedReadings.where((r) => r.valor < 2).length;
    return (stoppedSamples / 60).round();
  }

  double? _markerElapsedSeconds(List<Anomaly> anomalies, DateTime t0) {
    if (anomalies.isEmpty) return null;
    final first = anomalies.reduce((a, b) => a.ts.isBefore(b.ts) ? a : b);
    return first.ts.difference(t0).inSeconds.toDouble();
  }
}

/// Dois botões — não só "Exportar CSV" como no mockup — porque RF20 exige
/// CSV e JSON; um `ConsumerStatefulWidget` isolado só pra isto evita ter
/// que promover a tela inteira (`_TripDetailBody` é `StatelessWidget`) a
/// algo com estado só por causa do spinner de exportação.
class _ExportButtons extends ConsumerStatefulWidget {
  const _ExportButtons({required this.session});

  final Session session;

  @override
  ConsumerState<_ExportButtons> createState() => _ExportButtonsState();
}

class _ExportButtonsState extends ConsumerState<_ExportButtons> {
  bool _exporting = false;

  Future<void> _run(Future<void> Function() export) async {
    setState(() => _exporting = true);
    try {
      await export();
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _exporting ? null : () => _run(() => exportSessionCsv(ref, widget.session)),
            child: _exporting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: PulsoColors.ink2),
                  )
                : const Text('Exportar CSV'),
          ),
        ),
        const SizedBox(width: PulsoSpacing.s3),
        Expanded(
          child: OutlinedButton(
            onPressed: _exporting ? null : () => _run(() => exportSessionJson(ref, widget.session)),
            child: _exporting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: PulsoColors.ink2),
                  )
                : const Text('Exportar JSON'),
          ),
        ),
      ],
    );
  }
}

/// Um dos dois quadros empilhados — mesmo eixo de tempo, marcados pela
/// mesma linha tracejada quando há anomalia (nota do mockup: "a linha
/// tracejada marca o mesmo instante nos dois").
class _TimeSeriesChart extends StatelessWidget {
  const _TimeSeriesChart({
    required this.readings,
    required this.t0,
    required this.markerX,
    required this.color,
  });

  final List<Reading> readings;
  final DateTime t0;
  final double? markerX;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (readings.isEmpty) {
      return Center(
        child: Text('Sem dados', style: PulsoTypography.micro),
      );
    }

    final spots = [
      for (final r in readings)
        FlSpot(r.ts.difference(t0).inSeconds.toDouble(), r.valor),
    ];
    final maxX = spots.last.x;

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: maxX,
        gridData: const FlGridData(
          drawVerticalLine: false,
          horizontalInterval: null,
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 36),
          ),
          rightTitles: const AxisTitles(),
          topTitles: const AxisTitles(),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 24,
              interval: maxX > 0 ? maxX / 4 : 1,
              getTitlesWidget: (value, meta) => Text(
                '${(value / 60).round()} min',
                style: PulsoTypography.micro,
              ),
            ),
          ),
        ),
        lineTouchData: const LineTouchData(enabled: false),
        extraLinesData: ExtraLinesData(
          verticalLines: [
            if (markerX != null)
              VerticalLine(
                x: markerX!,
                color: PulsoColors.attentionInk,
                strokeWidth: 1,
                dashArray: const [4, 4],
              ),
          ],
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: false,
            color: color,
            barWidth: 2,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(show: true, color: color.withValues(alpha: 0.08)),
          ),
        ],
      ),
    );
  }
}

class _AnomalyTile extends StatelessWidget {
  const _AnomalyTile({required this.anomaly});

  final Anomaly anomaly;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: PulsoSpacing.s3),
      child: Container(
        padding: const EdgeInsets.all(PulsoSpacing.s3),
        decoration: BoxDecoration(
          color: PulsoColors.surface,
          borderRadius: BorderRadius.circular(PulsoRadius.card),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_timeFmt.format(anomaly.ts)} · ${anomaly.pidKey}',
                    style: PulsoTypography.label.copyWith(color: PulsoColors.ink),
                  ),
                  const SizedBox(height: PulsoSpacing.s1),
                  Text(
                    '${anomaly.valor.toStringAsFixed(1)} (esperado '
                    '${anomaly.mediaEsperada.toStringAsFixed(1)} ±${anomaly.desvioPadrao.toStringAsFixed(1)})',
                    style: PulsoTypography.micro,
                  ),
                ],
              ),
            ),
            Text(
              anomaly.tipo == AnomalyType.tendencia ? 'TENDÊNCIA' : 'PONTUAL',
              style: PulsoTypography.micro,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: PulsoTypography.micro),
        Text(value, style: PulsoTypography.valueMd),
      ],
    );
  }
}
