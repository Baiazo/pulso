import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';
import 'connection_controller.dart';

/// Tela "01 · ABERTURA" do mockup — primeiro contato, explica o que o
/// app faz antes de pedir pra conectar em qualquer coisa.
///
/// Conteúdo rolável (nota 06 do mockup: ação primária vive fixa nos
/// últimos ~130 dp da tela) — em telas baixas o texto de abertura não
/// cabe inteiro sem rolar, os botões não podem depender disso.
class OpeningView extends ConsumerWidget {
  const OpeningView({super.key, required this.onStartScan});

  final VoidCallback onStartScan;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: PulsoSpacing.s4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: PulsoSpacing.s7),
                  Row(
                    children: [
                      Container(
                        width: 3,
                        height: 28,
                        color: PulsoColors.accent,
                        margin: const EdgeInsets.only(right: PulsoSpacing.s2),
                      ),
                      const Text('PULSO', style: PulsoTypography.titleScreen),
                    ],
                  ),
                  const SizedBox(height: PulsoSpacing.s6),
                  Text(
                    'O carro avisa antes de falhar.\nSó não avisa em português.',
                    style: PulsoTypography.displayHero.copyWith(fontSize: 28, height: 1.15),
                  ),
                  const SizedBox(height: PulsoSpacing.s4),
                  Text(
                    'O Pulso lê a central eletrônica pelo adaptador OBD-II, aprende '
                    'como o seu carro se comporta quando está bem, e fala quando '
                    'algo sai desse padrão.',
                    style: PulsoTypography.body,
                  ),
                  const SizedBox(height: PulsoSpacing.s7),
                  const _OnboardingStep(
                    number: '01',
                    title: 'Vê o motor funcionando',
                    body: 'Rotação, velocidade, temperatura, consumo — ao vivo.',
                  ),
                  const _OnboardingStep(
                    number: '02',
                    title: 'Aprende o normal deste carro',
                    body: 'E avisa quando um parâmetro começa a fugir dele.',
                  ),
                  const _OnboardingStep(
                    number: '03',
                    title: 'Explica os códigos de falha',
                    body: 'Sem jargão de oficina, com o que costuma causar cada um.',
                  ),
                  const SizedBox(height: PulsoSpacing.s3),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              PulsoSpacing.s4,
              PulsoSpacing.s2,
              PulsoSpacing.s4,
              PulsoSpacing.s4,
            ),
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: onStartScan,
                  child: const Text('CONECTAR UM ADAPTADOR'),
                ),
                const SizedBox(height: PulsoSpacing.s3),
                OutlinedButton(
                  onPressed: () =>
                      ref.read(connectionControllerProvider.notifier).connectDemoMode(),
                  child: const Text('VER EM MODO DEMONSTRAÇÃO'),
                ),
                const SizedBox(height: PulsoSpacing.s4),
                Text(
                  'COMPATÍVEL COM ADAPTADORES ELM327 BLUETOOTH',
                  style: PulsoTypography.micro,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingStep extends StatelessWidget {
  const _OnboardingStep({required this.number, required this.title, required this.body});

  final String number;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: PulsoSpacing.s5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 32,
            child: Text(number, style: PulsoTypography.label.copyWith(color: PulsoColors.accent)),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: PulsoTypography.label.copyWith(color: PulsoColors.ink)),
                const SizedBox(height: PulsoSpacing.s1),
                Text(body, style: PulsoTypography.body),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
