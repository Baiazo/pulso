import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/obd/dtc/dtc_decoder.dart';
import '../../domain/entities/dtc_event.dart';
import '../providers/app_providers.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';
import '../trips/trip_detail_screen.dart';
import '../widgets/dtc_chip.dart';

const _monthAbbrev = [
  'jan', 'fev', 'mar', 'abr', 'mai', 'jun',
  'jul', 'ago', 'set', 'out', 'nov', 'dez',
];

String _formatTimestamp(DateTime ts) {
  final hh = ts.hour.toString().padLeft(2, '0');
  final mm = ts.minute.toString().padLeft(2, '0');
  return '${ts.day} ${_monthAbbrev[ts.month - 1]}, $hh:$mm';
}

const _freezeFrameFields = [
  (key: 'engine_rpm', label: 'ROTAÇÃO', unit: 'rpm', decimals: 0),
  (key: 'vehicle_speed', label: 'VELOCIDADE', unit: 'km/h', decimals: 0),
  (key: 'coolant_temp', label: 'MOTOR', unit: '°C', decimals: 0),
  (key: 'engine_load', label: 'CARGA', unit: '%', decimals: 0),
];

/// Deriva o sistema (P/C/B/U) direto da primeira letra do código — o
/// `DtcEvent` persistido guarda só o texto (`"P0133"`), não a struct
/// `DtcCode` de onde ele veio.
DtcSystem _systemFromCode(String code) => switch (code[0]) {
      'C' => DtcSystem.chassis,
      'B' => DtcSystem.body,
      'U' => DtcSystem.network,
      _ => DtcSystem.powertrain,
    };

/// "06B · DTC — DETALHE" do mockup: descrição, freeze frame (RF07) e
/// atalho para a viagem em que a falha foi registrada.
class DtcDetailScreen extends ConsumerWidget {
  const DtcDetailScreen({super.key, required this.event});

  final DtcEvent event;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: PulsoColors.bg,
      appBar: AppBar(
        backgroundColor: PulsoColors.bg,
        elevation: 0,
        title: Text(event.codigo, style: PulsoTypography.titleScreen),
      ),
      body: ListView(
        padding: const EdgeInsets.all(PulsoSpacing.s4),
        children: [
          DtcChip(
            code: event.codigo,
            system: _systemFromCode(event.codigo),
            tipo: event.tipo,
          ),
          const SizedBox(height: PulsoSpacing.s5),
          Text(event.descricao, style: PulsoTypography.body),
          if (event.freezeFrame.isNotEmpty) ...[
            const SizedBox(height: PulsoSpacing.s7),
            Text('O CARRO NO INSTANTE DA FALHA', style: PulsoTypography.titleSection),
            const SizedBox(height: PulsoSpacing.s4),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: PulsoSpacing.s3,
              crossAxisSpacing: PulsoSpacing.s3,
              childAspectRatio: 2.4,
              children: [
                for (final field in _freezeFrameFields)
                  _FreezeFrameStat(
                    label: field.label,
                    value: event.freezeFrame[field.key],
                    unit: field.unit,
                    decimals: field.decimals,
                  ),
              ],
            ),
          ],
          const SizedBox(height: PulsoSpacing.s6),
          Text(
            'Registrado em ${_formatTimestamp(event.ts)}',
            style: PulsoTypography.micro,
          ),
          const SizedBox(height: PulsoSpacing.s5),
          SizedBox(
            height: 52,
            child: OutlinedButton(
              onPressed: () => _openTrip(context, ref),
              child: const Text('Ver a viagem dessa falha'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openTrip(BuildContext context, WidgetRef ref) async {
    final session = await ref.read(sessionRepositoryProvider).byId(event.sessionId);
    if (!context.mounted || session == null) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => TripDetailScreen(session: session)),
    );
  }
}

class _FreezeFrameStat extends StatelessWidget {
  const _FreezeFrameStat({
    required this.label,
    required this.value,
    required this.unit,
    required this.decimals,
  });

  final String label;
  final double? value;
  final String unit;
  final int decimals;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: PulsoTypography.micro),
        const SizedBox(height: PulsoSpacing.s1),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value != null ? value!.toStringAsFixed(decimals) : '—',
              style: PulsoTypography.valueMd,
            ),
            const SizedBox(width: PulsoSpacing.s1),
            Text(unit, style: PulsoTypography.micro),
          ],
        ),
      ],
    );
  }
}
