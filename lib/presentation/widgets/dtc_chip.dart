import 'package:flutter/material.dart';

import '../../data/obd/dtc/dtc_decoder.dart';
import '../../domain/entities/enums.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';
import 'dtc_status.dart';

/// "Chip de DTC" do sistema visual: código em mono (não confunde 0/O e
/// 1/I), sistema por extenso, selo de status colorido.
class DtcChip extends StatelessWidget {
  const DtcChip({super.key, required this.code, required this.system, required this.tipo});

  final String code;
  final DtcSystem system;
  final DtcEventType tipo;

  @override
  Widget build(BuildContext context) {
    final color = dtcTipoColor(tipo);
    return Row(
      children: [
        Text(code, style: PulsoTypography.monoCode),
        const SizedBox(width: PulsoSpacing.s3),
        Expanded(
          child: Text(dtcSystemLabel(system), style: PulsoTypography.micro),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: PulsoSpacing.s2, vertical: 3),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(PulsoRadius.chip),
          ),
          child: Text(
            dtcTipoLabel(tipo),
            style: PulsoTypography.micro.copyWith(color: color),
          ),
        ),
      ],
    );
  }
}
