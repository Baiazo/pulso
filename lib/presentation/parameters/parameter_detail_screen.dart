import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/obd/pids/pid_catalog.dart';
import '../../data/obd/pids/pid_definition.dart';
import '../../domain/entities/anomaly.dart';
import '../../domain/entities/baseline.dart' as domain;
import '../../domain/entities/enums.dart';
import '../providers/live_data_providers.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';
import '../widgets/arc_gauge.dart';
import '../widgets/severity_colors.dart';

const _tabLabels = ['URBANO', 'RODOVIA', 'PARADO'];

/// "Parado" agrega os dois contextos frios/quentes do motor (§12.2) numa
/// única aba — o mockup só reserva uma, e o quente é o que representa
/// melhor o que o motorista entende por "carro ligado parado".
OperatingContext _baselineContextoFor(int tabIndex) => switch (tabIndex) {
      0 => OperatingContext.urbano,
      1 => OperatingContext.rodovia,
      _ => OperatingContext.paradoQuente,
    };

/// "05 · DETALHE DO PARÂMETRO" do mockup: gauge, média/desvio/amostras,
/// abas de contexto e série temporal de 30 min com faixa ±1σ.
class ParameterDetailScreen extends ConsumerStatefulWidget {
  const ParameterDetailScreen({
    super.key,
    required this.vehicleId,
    required this.sessionId,
    required this.pidKey,
  });

  final int vehicleId;
  final int sessionId;
  final String pidKey;

  @override
  ConsumerState<ParameterDetailScreen> createState() => _ParameterDetailScreenState();
}

class _ParameterDetailScreenState extends ConsumerState<ParameterDetailScreen> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final def = pidCatalog.firstWhere((p) => p.key == widget.pidKey);
    final baselineContexto = _baselineContextoFor(_tabIndex);

    final latest = ref.watch(
      latestReadingProvider((sessionId: widget.sessionId, pidKey: widget.pidKey)),
    );
    final baseline = ref.watch(
      baselineProvider(
        (vehicleId: widget.vehicleId, pidKey: widget.pidKey, contexto: baselineContexto),
      ),
    );
    final anomalies = ref.watch(sessionAnomaliesProvider(widget.sessionId)).value ?? const [];
    final pidAnomalies = anomalies.where((a) => a.pidKey == widget.pidKey).toList();
    final severity = pidAnomalies.isEmpty ? null : pidAnomalies.first.severidade;

    return Scaffold(
      backgroundColor: PulsoColors.bg,
      appBar: AppBar(
        backgroundColor: PulsoColors.bg,
        elevation: 0,
        title: Text(def.label, style: PulsoTypography.titleScreen),
      ),
      body: ListView(
        padding: const EdgeInsets.all(PulsoSpacing.s4),
        children: [
          Center(
            child: ArcGauge(
              diameter: 180,
              value: latest.value?.valor ?? def.min,
              min: def.min,
              max: def.max,
              mean: _stableMean(baseline.value),
              severity: severity,
              child: _GaugeCenter(def: def, value: latest.value?.valor),
            ),
          ),
          const SizedBox(height: PulsoSpacing.s6),
          _ContextTabs(
            selected: _tabIndex,
            onSelect: (i) => setState(() => _tabIndex = i),
          ),
          const SizedBox(height: PulsoSpacing.s6),
          Row(
            children: [
              _StatChip(
                label: 'MÉDIA',
                value: baseline.value != null
                    ? '${baseline.value!.media.toStringAsFixed(1)} ${def.unit}'
                    : '—',
              ),
              const SizedBox(width: PulsoSpacing.s6),
              _StatChip(
                label: 'DESVIO PADRÃO',
                value: baseline.value != null
                    ? '±${baseline.value!.stdDev.toStringAsFixed(1)}'
                    : '—',
              ),
              const SizedBox(width: PulsoSpacing.s6),
              _StatChip(
                label: 'AMOSTRAS',
                value: baseline.value != null ? '${baseline.value!.n}' : '0',
              ),
            ],
          ),
          const SizedBox(height: PulsoSpacing.s7),
          Text('ÚLTIMOS 30 MIN', style: PulsoTypography.titleSection),
          const SizedBox(height: PulsoSpacing.s3),
          SizedBox(
            height: 200,
            child: _RecentSeriesChart(
              sessionId: widget.sessionId,
              pidKey: widget.pidKey,
              baseline: baseline.value,
              anomalies: pidAnomalies,
            ),
          ),
          if (pidAnomalies.isNotEmpty) ...[
            const SizedBox(height: PulsoSpacing.s7),
            Text('MOMENTOS DE DESVIO', style: PulsoTypography.titleSection),
            const SizedBox(height: PulsoSpacing.s3),
            for (final anomaly in pidAnomalies) _AnomalyTile(anomaly: anomaly, unit: def.unit),
          ],
          const SizedBox(height: PulsoSpacing.s6),
        ],
      ),
    );
  }

  double? _stableMean(domain.Baseline? baseline) {
    if (baseline == null || baseline.n < 30) return null;
    return baseline.media;
  }
}

class _ContextTabs extends StatelessWidget {
  const _ContextTabs({required this.selected, required this.onSelect});

  final int selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < _tabLabels.length; i++)
          Expanded(
            child: GestureDetector(
              onTap: () => onSelect(i),
              child: Container(
                margin: EdgeInsets.only(right: i < _tabLabels.length - 1 ? PulsoSpacing.s2 : 0),
                padding: const EdgeInsets.symmetric(vertical: PulsoSpacing.s2),
                decoration: BoxDecoration(
                  color: i == selected ? PulsoColors.surfaceRaised : PulsoColors.surface,
                  borderRadius: BorderRadius.circular(PulsoRadius.button),
                  border: Border.all(
                    color: i == selected ? PulsoColors.accent : PulsoColors.hairline,
                  ),
                ),
                child: Text(
                  _tabLabels[i],
                  textAlign: TextAlign.center,
                  style: PulsoTypography.label.copyWith(
                    color: i == selected ? PulsoColors.ink : PulsoColors.inkMeta,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Série da sessão inteira filtrada pros últimos 30 min, com faixa ±1σ
/// desenhada como referência (não é o dado plotado, é a expectativa).
class _RecentSeriesChart extends ConsumerWidget {
  const _RecentSeriesChart({
    required this.sessionId,
    required this.pidKey,
    required this.baseline,
    required this.anomalies,
  });

  final int sessionId;
  final String pidKey;
  final domain.Baseline? baseline;
  final List<Anomaly> anomalies;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readingsAsync = ref.watch(
      readingsForSessionProvider((sessionId: sessionId, pidKey: pidKey)),
    );
    final readings = readingsAsync.value ?? const [];
    if (readings.isEmpty) {
      return Center(child: Text('Sem dados ainda', style: PulsoTypography.micro));
    }

    final cutoff = readings.last.ts.subtract(const Duration(minutes: 30));
    final recent = readings.where((r) => r.ts.isAfter(cutoff)).toList();
    final t0 = recent.first.ts;
    final spots = [
      for (final r in recent) FlSpot(r.ts.difference(t0).inSeconds.toDouble(), r.valor),
    ];
    final maxX = spots.last.x;

    final mean = baseline != null && baseline!.n >= 30 ? baseline!.media : null;
    final stdDev = baseline != null && baseline!.n >= 30 ? baseline!.stdDev : null;

    final anomalyMarkers = [
      for (final a in anomalies)
        if (a.ts.isAfter(cutoff)) a.ts.difference(t0).inSeconds.toDouble(),
    ];

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: maxX,
        gridData: const FlGridData(drawVerticalLine: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
          rightTitles: const AxisTitles(),
          topTitles: const AxisTitles(),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 24,
              interval: maxX > 0 ? maxX / 4 : 1,
              getTitlesWidget: (value, meta) =>
                  Text('${(value / 60).round()} min', style: PulsoTypography.micro),
            ),
          ),
        ),
        lineTouchData: const LineTouchData(enabled: false),
        extraLinesData: ExtraLinesData(
          horizontalLines: [
            if (mean != null)
              HorizontalLine(y: mean, color: PulsoColors.ink2, strokeWidth: 1, dashArray: const [4, 4]),
          ],
          verticalLines: [
            for (final x in anomalyMarkers)
              VerticalLine(
                x: x,
                color: PulsoColors.attentionInk,
                strokeWidth: 1,
                dashArray: const [4, 4],
              ),
          ],
        ),
        betweenBarsData: mean == null || stdDev == null
            ? const []
            : [
                BetweenBarsData(
                  fromIndex: 1,
                  toIndex: 2,
                  color: PulsoColors.ink2.withValues(alpha: 0.08),
                ),
              ],
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: false,
            color: PulsoColors.accent,
            barWidth: 2,
            dotData: const FlDotData(show: false),
          ),
          if (mean != null && stdDev != null)
            LineChartBarData(
              spots: [FlSpot(0, mean + stdDev), FlSpot(maxX, mean + stdDev)],
              color: Colors.transparent,
              barWidth: 0,
              dotData: const FlDotData(show: false),
            ),
          if (mean != null && stdDev != null)
            LineChartBarData(
              spots: [FlSpot(0, mean - stdDev), FlSpot(maxX, mean - stdDev)],
              color: Colors.transparent,
              barWidth: 0,
              dotData: const FlDotData(show: false),
            ),
        ],
      ),
    );
  }
}

class _AnomalyTile extends StatelessWidget {
  const _AnomalyTile({required this.anomaly, required this.unit});

  final Anomaly anomaly;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final color = severityColor(anomaly.severidade) ?? PulsoColors.ink;
    return Padding(
      padding: const EdgeInsets.only(bottom: PulsoSpacing.s3),
      child: Container(
        padding: const EdgeInsets.all(PulsoSpacing.s3),
        decoration: BoxDecoration(
          color: PulsoColors.surface,
          borderRadius: BorderRadius.circular(PulsoRadius.card),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${severityLabel(anomaly.severidade).toUpperCase()} · '
                    '${anomaly.ts.hour.toString().padLeft(2, '0')}:'
                    '${anomaly.ts.minute.toString().padLeft(2, '0')}',
                    style: PulsoTypography.micro.copyWith(color: color),
                  ),
                  const SizedBox(height: PulsoSpacing.s1),
                  Text(
                    '${anomaly.valor.toStringAsFixed(1)} $unit — normal é '
                    '${anomaly.mediaEsperada.toStringAsFixed(1)} ±${anomaly.desvioPadrao.toStringAsFixed(1)}',
                    style: PulsoTypography.body,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GaugeCenter extends StatelessWidget {
  const _GaugeCenter({required this.def, required this.value});

  final PidDefinition def;
  final double? value;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value != null ? value!.toStringAsFixed(1) : '—', style: PulsoTypography.displayGauge),
        Text(def.unit, style: PulsoTypography.micro),
      ],
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
