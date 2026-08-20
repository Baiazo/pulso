import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';
import 'connection_state.dart';

/// Confirmação de conexão bem-sucedida — o painel ao vivo de verdade é o
/// item 12; por enquanto isso é o destino do fluxo de conexão.
class ConnectedView extends StatelessWidget {
  const ConnectedView({super.key, required this.state});

  final ConnectionEstablished state;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(PulsoSpacing.s4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: PulsoColors.normalInk, size: 40),
              const SizedBox(height: PulsoSpacing.s4),
              const Text('Conectado', style: PulsoTypography.titleScreen),
              const SizedBox(height: PulsoSpacing.s2),
              Text(state.protocolDescription, style: PulsoTypography.monoCode),
              const SizedBox(height: PulsoSpacing.s6),
              Text('Painel ao vivo — item 12', style: PulsoTypography.micro),
            ],
          ),
        ),
      ),
    );
  }
}
