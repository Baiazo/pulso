import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/analysis/context_classifier.dart';
import '../../domain/entities/anomaly.dart';
import '../../domain/entities/baseline.dart' as domain;
import '../../domain/entities/enums.dart';
import '../connection/connection_state.dart';
import '../parameters/parameter_detail_screen.dart';
import '../providers/active_session_controller.dart';
import '../providers/live_data_providers.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';
import '../widgets/arc_gauge.dart';
import '../widgets/severity_colors.dart';
import '../widgets/stat_tile.dart';

/// Faixa de exibição do gauge — não é o mínimo/máximo físico do PID
/// (§8: RPM vai até 16383,75 na fórmula, ninguém dirige lá): é a faixa
/// que faz sentido no mostrador.
const _rpmDisplayRange = (min: 0.0, max: 7000.0);
const _speedDisplayRange = (min: 0.0, max: 220.0);
const _coolantDisplayRange = (min: 40.0, max: 130.0);

/// Item 12 — "03 · PAINEL AO VIVO" do mockup: rotação em destaque,
/// velocidade e temperatura em gauges secundários, o resto em stat tiles.
/// Tudo reativo — vem direto do banco (Drift `.watch()`), o mesmo dado
/// que o agendador (item 8) está gravando neste instante.
class LiveDashboardScreen extends ConsumerWidget {
  const LiveDashboardScreen({super.key, required this.connection});

  final ConnectionEstablished connection;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeSession = ref.watch(activeSessionProvider);

    if (activeSession == null) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: PulsoColors.accent),
            ),
            SizedBox(height: PulsoSpacing.s3),
            Text('Descobrindo parâmetros suportados…', style: PulsoTypography.body),
          ],
        ),
      );
    }

    final sessionId = activeSession.sessionId;
    final vehicleId = activeSession.vehicleId;

    final speedReading = ref.watch(
      latestReadingProvider((sessionId: sessionId, pidKey: 'vehicle_speed')),
    );
    final coolantReading = ref.watch(
      latestReadingProvider((sessionId: sessionId, pidKey: 'coolant_temp')),
    );
    final rpmReading = ref.watch(
      latestReadingProvider((sessionId: sessionId, pidKey: 'engine_rpm')),
    );
    final loadReading = ref.watch(
      latestReadingProvider((sessionId: sessionId, pidKey: 'engine_load')),
    );
    final throttleReading = ref.watch(
      latestReadingProvider((sessionId: sessionId, pidKey: 'throttle_position')),
    );
    final voltageReading = ref.watch(
      latestReadingProvider((sessionId: sessionId, pidKey: 'control_module_voltage')),
    );
    final consumptionReading = ref.watch(
      latestReadingProvider((sessionId: sessionId, pidKey: 'consumo_kml')),
    );

    final speed = speedReading.value?.valor ?? 0;
    final coolant = coolantReading.value?.valor ?? 90;
    final contexto = classifyContext(speedKmh: speed, coolantTempC: coolant);

    final rpmBaseline = ref.watch(
      baselineProvider((vehicleId: vehicleId, pidKey: 'engine_rpm', contexto: contexto)),
    );
    final coolantBaseline = ref.watch(
      baselineProvider((vehicleId: vehicleId, pidKey: 'coolant_temp', contexto: contexto)),
    );

    final anomalies = ref.watch(sessionAnomaliesProvider(sessionId)).value ?? const [];
    final rpmSeverity = _currentSeverityFor(anomalies, 'engine_rpm');
    final coolantSeverity = _currentSeverityFor(anomalies, 'coolant_temp');
    final activeAlert = anomalies.isEmpty ? null : anomalies.first;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: PulsoSpacing.s4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (activeAlert != null) ...[
            const SizedBox(height: PulsoSpacing.s2),
            _AlertBanner(anomaly: activeAlert),
          ],
          const SizedBox(height: PulsoSpacing.s6),
          Center(
            child: GestureDetector(
              onTap: () => _openParameterDetail(context, vehicleId, sessionId, 'engine_rpm'),
              child: ArcGauge(
                diameter: 212,
                value: rpmReading.value?.valor ?? _rpmDisplayRange.min,
                min: _rpmDisplayRange.min,
                max: _rpmDisplayRange.max,
                mean: _stableMean(rpmBaseline.value),
                severity: rpmSeverity,
                child: _GaugeCenter(
                  value: _fmt(rpmReading.value?.valor, decimals: 0),
                  unit: 'RPM',
                  caption: _meanCaption(rpmBaseline.value, contexto),
                ),
              ),
            ),
          ),
          const SizedBox(height: PulsoSpacing.s7),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () =>
                      _openParameterDetail(context, vehicleId, sessionId, 'vehicle_speed'),
                  child: ArcGauge(
                    diameter: 142,
                    value: speed,
                    min: _speedDisplayRange.min,
                    max: _speedDisplayRange.max,
                    child: _GaugeCenter(
                      value: _fmt(speedReading.value?.valor, decimals: 0),
                      unit: 'KM/H',
                      caption: 'VELOCIDADE',
                      labelFirst: true,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () =>
                      _openParameterDetail(context, vehicleId, sessionId, 'coolant_temp'),
                  child: ArcGauge(
                    diameter: 142,
                    value: coolant,
                    min: _coolantDisplayRange.min,
                    max: _coolantDisplayRange.max,
                    mean: _stableMean(coolantBaseline.value),
                    severity: coolantSeverity,
                    child: _GaugeCenter(
                      value: _fmt(coolantReading.value?.valor, decimals: 0),
                      unit: '°C',
                      caption: _stableMean(coolantBaseline.value) != null
                          ? 'MÉD ${_stableMean(coolantBaseline.value)!.round()}'
                          : 'MOTOR',
                      labelFirst: true,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: PulsoSpacing.s7),
          Text('SECUNDÁRIOS', style: PulsoTypography.titleSection),
          const SizedBox(height: PulsoSpacing.s3),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: PulsoSpacing.s3,
            crossAxisSpacing: PulsoSpacing.s3,
            childAspectRatio: 1.6,
            children: [
              GestureDetector(
                onTap: () =>
                    _openParameterDetail(context, vehicleId, sessionId, 'engine_load'),
                child: StatTile(
                  label: 'Carga do motor',
                  value: _fmt(loadReading.value?.valor, decimals: 0),
                  unit: '%',
                ),
              ),
              GestureDetector(
                onTap: () =>
                    _openParameterDetail(context, vehicleId, sessionId, 'throttle_position'),
                child: StatTile(
                  label: 'Acelerador',
                  value: _fmt(throttleReading.value?.valor, decimals: 0),
                  unit: '%',
                ),
              ),
              GestureDetector(
                onTap: () => _openParameterDetail(
                    context, vehicleId, sessionId, 'control_module_voltage'),
                child: StatTile(
                  label: 'Bateria',
                  value: _fmt(voltageReading.value?.valor, decimals: 1),
                  unit: 'V',
                ),
              ),
              StatTile(
                label: 'Consumo',
                value: _fmt(consumptionReading.value?.valor, decimals: 1),
                unit: 'km/l',
              ),
            ],
          ),
          const SizedBox(height: PulsoSpacing.s6),
        ],
      ),
    );
  }

  /// Só mostra a média com amostragem mínima razoável — antes disso o
  /// número oscila demais pra significar algo (o Z-score em si só avalia
  /// a partir de 100 amostras, §12.4; a marca visual usa um piso menor,
  /// 30, só pra não ficar em branco o tempo todo enquanto calibra).
  double? _stableMean(domain.Baseline? baseline) {
    if (baseline == null || baseline.n < 30) return null;
    return baseline.media;
  }

  String? _meanCaption(domain.Baseline? baseline, OperatingContext contexto) {
    final mean = _stableMean(baseline);
    if (mean == null) return 'Calibrando';
    return 'MÉD ${contexto.name.toUpperCase()} ${mean.round()}';
  }

  AnomalySeverity? _currentSeverityFor(
    List<Anomaly> anomalies,
    String pidKey, {
    DateTime Function()? now,
  }) {
    final clock = now ?? DateTime.now;
    final cutoff = clock().subtract(const Duration(seconds: 90));
    for (final anomaly in anomalies) {
      if (anomaly.pidKey != pidKey) continue;
      if (anomaly.tipo != AnomalyType.pontual) continue;
      if (anomaly.ts.isBefore(cutoff)) continue;
      return anomaly.severidade;
    }
    return null;
  }
}

void _openParameterDetail(
  BuildContext context,
  int vehicleId,
  int sessionId,
  String pidKey,
) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => ParameterDetailScreen(
        vehicleId: vehicleId,
        sessionId: sessionId,
        pidKey: pidKey,
      ),
    ),
  );
}

String _fmt(double? value, {required int decimals}) {
  if (value == null) return '—';
  return value.toStringAsFixed(decimals);
}

class _GaugeCenter extends StatelessWidget {
  const _GaugeCenter({
    required this.value,
    required this.unit,
    this.caption,
    this.labelFirst = false,
  });

  final String value;
  final String unit;
  final String? caption;
  final bool labelFirst;

  @override
  Widget build(BuildContext context) {
    final valueStyle = labelFirst ? PulsoTypography.valueLg : PulsoTypography.displayGauge;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (labelFirst && caption != null)
          Text(caption!, style: PulsoTypography.micro, textAlign: TextAlign.center),
        Text(value, style: valueStyle),
        Text(unit, style: PulsoTypography.micro),
        if (!labelFirst && caption != null)
          Text(caption!, style: PulsoTypography.micro, textAlign: TextAlign.center),
      ],
    );
  }
}

class _AlertBanner extends StatelessWidget {
  const _AlertBanner({required this.anomaly});

  final Anomaly anomaly;

  @override
  Widget build(BuildContext context) {
    final color = severityColor(anomaly.severidade) ?? PulsoColors.ink;
    return Container(
      padding: const EdgeInsets.all(PulsoSpacing.s4),
      decoration: BoxDecoration(
        color: PulsoColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, color: color, size: 20),
          const SizedBox(width: PulsoSpacing.s3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${severityLabel(anomaly.severidade).toUpperCase()} · ${anomaly.pidKey}',
                  style: PulsoTypography.micro.copyWith(color: color),
                ),
                const SizedBox(height: PulsoSpacing.s1),
                Text(
                  '${anomaly.valor.toStringAsFixed(1)} onde o normal deste carro é '
                  '${anomaly.mediaEsperada.toStringAsFixed(1)} ±${anomaly.desvioPadrao.toStringAsFixed(1)}',
                  style: PulsoTypography.body,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
