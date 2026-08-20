import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/analysis/context_classifier.dart';
import '../../domain/entities/anomaly.dart';
import '../providers/active_session_controller.dart';
import '../providers/live_data_providers.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';
import '../widgets/severity_colors.dart';

const _rpmMax = 7000.0;

/// "04 · MODO DIREÇÃO" do mockup — nota 05: não é o painel com fonte maior,
/// é outra tela. Perde o gauge (arco exige fixação visual pra ler), perde a
/// navegação, perde o toque comum. Quatro números alinhados à esquerda pro
/// olho voltar sempre ao mesmo ponto, e uma barra linear de rotação lida
/// por visão periférica, sem número — o número já está no bloco de cima.
/// Sai só com toque duplo, de propósito: nada que um cotovelo encoste sem
/// querer deveria tirar o motorista desta tela.
class DrivingModeScreen extends ConsumerWidget {
  const DrivingModeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeSession = ref.watch(activeSessionProvider);

    return GestureDetector(
      onDoubleTap: () => Navigator.of(context).pop(),
      child: Scaffold(
        backgroundColor: PulsoColors.bg,
        body: SafeArea(
          child: activeSession == null
              ? const Center(
                  child: CircularProgressIndicator(strokeWidth: 2, color: PulsoColors.accent),
                )
              : _DrivingModeBody(
                  sessionId: activeSession.sessionId,
                  vehicleId: activeSession.vehicleId,
                ),
        ),
      ),
    );
  }
}

class _DrivingModeBody extends ConsumerWidget {
  const _DrivingModeBody({required this.sessionId, required this.vehicleId});

  final int sessionId;
  final int vehicleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final speed = ref.watch(
      latestReadingProvider((sessionId: sessionId, pidKey: 'vehicle_speed')),
    ).value?.valor;
    final rpm = ref.watch(
      latestReadingProvider((sessionId: sessionId, pidKey: 'engine_rpm')),
    ).value?.valor;
    final coolant = ref.watch(
      latestReadingProvider((sessionId: sessionId, pidKey: 'coolant_temp')),
    ).value?.valor;
    final consumption = ref.watch(
      latestReadingProvider((sessionId: sessionId, pidKey: 'consumo_kml')),
    ).value?.valor;

    final contexto = classifyContext(speedKmh: speed ?? 0, coolantTempC: coolant ?? 90);
    final coolantBaseline = ref.watch(
      baselineProvider((vehicleId: vehicleId, pidKey: 'coolant_temp', contexto: contexto)),
    ).value;
    final consumptionBaseline = ref.watch(
      baselineProvider((vehicleId: vehicleId, pidKey: 'consumo_kml', contexto: contexto)),
    ).value;

    final anomalies = ref.watch(sessionAnomaliesProvider(sessionId)).value ?? const [];
    final activeAlert = anomalies.isEmpty ? null : anomalies.first;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: PulsoSpacing.s6, vertical: PulsoSpacing.s5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StatusLine(alert: activeAlert),
          const SizedBox(height: PulsoSpacing.s7),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _DriveNumber(label: 'VELOCIDADE', value: speed, decimals: 0, unit: 'km/h'),
                _DriveNumber(label: 'ROTAÇÃO', value: rpm, decimals: 0, unit: 'RPM'),
                _DriveNumber(
                  label: 'MOTOR',
                  value: coolant,
                  decimals: 0,
                  unit: '°C',
                  caption: _stableMeanCaption(coolantBaseline?.n, coolantBaseline?.media),
                ),
                _DriveNumber(
                  label: 'CONSUMO',
                  value: consumption,
                  decimals: 0,
                  unit: 'km/l',
                  caption: _stableMeanCaption(
                    consumptionBaseline?.n,
                    consumptionBaseline?.media,
                    prefix: 'MÉDIA',
                    decimals: 1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: PulsoSpacing.s6),
          _RotationBar(rpm: rpm ?? 0),
          const SizedBox(height: PulsoSpacing.s5),
          Center(
            child: Text(
              'TELA TRAVADA · TOQUE DUAS VEZES PARA SAIR',
              style: PulsoTypography.micro,
            ),
          ),
        ],
      ),
    );
  }

  /// Só mostra a média com amostragem mínima razoável — mesmo piso do
  /// painel ao vivo (item 12): antes disso o número oscila demais pra
  /// significar algo.
  String? _stableMeanCaption(
    int? n,
    double? media, {
    String prefix = 'MÉD',
    int decimals = 0,
  }) {
    if (n == null || n < 30 || media == null) return null;
    return '$prefix ${media.toStringAsFixed(decimals)}';
  }
}

class _StatusLine extends StatelessWidget {
  const _StatusLine({required this.alert});

  final Anomaly? alert;

  @override
  Widget build(BuildContext context) {
    if (alert == null) {
      return Text('Tudo dentro do normal', style: PulsoTypography.body);
    }
    final color = severityColor(alert!.severidade) ?? PulsoColors.ink;
    return Text(
      severityLabel(alert!.severidade),
      style: PulsoTypography.body.copyWith(color: color, fontWeight: FontWeight.w600),
    );
  }
}

class _DriveNumber extends StatelessWidget {
  const _DriveNumber({
    required this.label,
    required this.value,
    required this.decimals,
    required this.unit,
    this.caption,
  });

  final String label;
  final double? value;
  final int decimals;
  final String unit;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: PulsoTypography.micro),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value != null ? value!.toStringAsFixed(decimals) : '—',
              style: PulsoTypography.displayDrive,
            ),
            const SizedBox(width: PulsoSpacing.s2),
            Text(unit, style: PulsoTypography.label),
          ],
        ),
        if (caption != null) Text(caption!, style: PulsoTypography.micro),
      ],
    );
  }
}

/// Barra de rotação lida por visão periférica (nota 05) — sem número: o
/// bloco ROTAÇÃO acima já mostra o valor exato.
class _RotationBar extends StatelessWidget {
  const _RotationBar({required this.rpm});

  final double rpm;

  @override
  Widget build(BuildContext context) {
    final fraction = (rpm / _rpmMax).clamp(0.0, 1.0);
    return ClipRRect(
      borderRadius: BorderRadius.circular(PulsoRadius.chip),
      child: Container(
        height: 14,
        color: PulsoColors.hairline,
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: fraction,
          child: Container(color: PulsoColors.accent),
        ),
      ),
    );
  }
}
