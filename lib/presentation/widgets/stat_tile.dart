import 'package:flutter/material.dart';

import '../../domain/entities/enums.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';
import 'severity_colors.dart';

/// "Stat tile" do sistema visual — parâmetro secundário em grade. O selo
/// sempre traz forma + palavra (aqui, a legenda `caption`); a cor é
/// redundante por projeto, nunca a única pista.
class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.label,
    required this.value,
    required this.unit,
    this.caption,
    this.severity,
  });

  final String label;

  /// Já formatado — `"—"` para "sem leitura" (RF23: nunca inventar valor).
  final String value;
  final String unit;
  final String? caption;
  final AnomalySeverity? severity;

  @override
  Widget build(BuildContext context) {
    final color = severityColor(severity);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(PulsoSpacing.s4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: PulsoTypography.label),
            const SizedBox(height: PulsoSpacing.s2),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(value, style: PulsoTypography.valueMd),
                if (unit.isNotEmpty) ...[
                  const SizedBox(width: PulsoSpacing.s1),
                  Text(unit, style: PulsoTypography.micro),
                ],
              ],
            ),
            if (caption != null) ...[
              const SizedBox(height: PulsoSpacing.s1),
              Text(
                caption!,
                style: PulsoTypography.micro.copyWith(color: color ?? PulsoColors.inkMeta),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
