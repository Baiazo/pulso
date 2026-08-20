import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';
import 'connection_state.dart';

/// Tela "02B · CONEXÃO — HANDSHAKE" do mockup — o log ao final é o mesmo
/// terminal usado no modo de validação (RF22): mostrar o comando bruto
/// prova que a leitura é real, não inventada.
class HandshakeView extends StatelessWidget {
  const HandshakeView({super.key, required this.state, required this.onCancel});

  final ConnectionHandshaking state;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(PulsoSpacing.s4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Negociando protocolo', style: PulsoTypography.titleScreen),
            const SizedBox(height: PulsoSpacing.s2),
            Text('Conversando com a central do carro', style: PulsoTypography.body),
            const SizedBox(height: PulsoSpacing.s1),
            Text(
              'Leva alguns segundos. Mantenha a ignição ligada.',
              style: PulsoTypography.micro,
            ),
            const SizedBox(height: PulsoSpacing.s7),
            Row(
              children: [
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: PulsoColors.accent),
                ),
                const SizedBox(width: PulsoSpacing.s3),
                Expanded(
                  child: Text(state.stepLabel, style: PulsoTypography.label.copyWith(color: PulsoColors.ink)),
                ),
              ],
            ),
            const SizedBox(height: PulsoSpacing.s6),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(PulsoSpacing.s4),
                decoration: BoxDecoration(
                  color: PulsoColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: PulsoColors.hairline),
                ),
                child: ListView(
                  reverse: true,
                  children: [
                    for (final line in state.log.reversed)
                      Padding(
                        padding: const EdgeInsets.only(bottom: PulsoSpacing.s1),
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(text: '> ${line.command}    ', style: PulsoTypography.monoCode.copyWith(color: PulsoColors.inkMeta)),
                              TextSpan(text: line.response, style: PulsoTypography.monoCode),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: PulsoSpacing.s4),
            OutlinedButton(onPressed: onCancel, child: const Text('CANCELAR')),
          ],
        ),
      ),
    );
  }
}
