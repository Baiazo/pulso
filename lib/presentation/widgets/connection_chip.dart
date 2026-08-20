import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';

/// "Chip de conexão" — sempre no mesmo lugar (canto superior esquerdo),
/// 32 dp de altura. O nome do protocolo só aparece conectado: é a prova
/// de que a leitura é real, não inventada.
class ConnectionChip extends StatelessWidget {
  const ConnectionChip({super.key, required this.connected, this.protocol});

  final bool connected;
  final String? protocol;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: PulsoSpacing.s3),
      decoration: BoxDecoration(
        color: PulsoColors.surface,
        borderRadius: BorderRadius.circular(PulsoRadius.pill),
        border: Border.all(color: PulsoColors.hairline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: connected ? PulsoColors.normalInk : PulsoColors.inkSoft,
            ),
          ),
          const SizedBox(width: PulsoSpacing.s2),
          Text(
            connected ? 'Conectado' : 'Desconectado',
            style: PulsoTypography.micro.copyWith(color: PulsoColors.ink),
          ),
          if (connected && protocol != null) ...[
            const SizedBox(width: PulsoSpacing.s2),
            Text(protocol!, style: PulsoTypography.micro),
          ],
        ],
      ),
    );
  }
}
