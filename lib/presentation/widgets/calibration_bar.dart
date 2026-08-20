import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';

/// "Barra de calibração" do mockup (seção 02, biblioteca de componentes) —
/// puramente apresentacional: quem chama já resolve o `n` da baseline em
/// percentual e formata a legenda (inclusive o caixa-alta, que o `micro`
/// não aplica sozinho — ver doc de `PulsoTypography`).
class CalibrationBar extends StatelessWidget {
  const CalibrationBar({
    super.key,
    required this.label,
    required this.percent,
    required this.caption,
  });

  final String label;

  /// 0–100, já saturado por quem chama. `>= 100` é o estado "calibrado" —
  /// troca o texto do valor por "Confiável" em vez de "100%".
  final int percent;

  final String caption;

  @override
  Widget build(BuildContext context) {
    final clamped = percent < 0 ? 0 : (percent > 100 ? 100 : percent);
    final done = clamped >= 100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: PulsoTypography.label),
        const SizedBox(height: PulsoSpacing.s2),
        Row(
          children: [
            Text(done ? 'Confiável' : '$clamped%', style: PulsoTypography.valueMd),
          ],
        ),
        const SizedBox(height: PulsoSpacing.s2),
        ClipRRect(
          borderRadius: BorderRadius.circular(PulsoRadius.chip),
          child: Container(
            height: 6,
            color: PulsoColors.hairline,
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: clamped / 100,
              child: Container(color: PulsoColors.accent),
            ),
          ),
        ),
        const SizedBox(height: PulsoSpacing.s2),
        Text(caption, style: PulsoTypography.micro),
      ],
    );
  }
}
