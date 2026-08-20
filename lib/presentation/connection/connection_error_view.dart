import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';
import 'connection_state.dart';

class _ErrorContent {
  const _ErrorContent({
    required this.title,
    required this.subtitle,
    required this.reason,
    required this.steps,
    required this.primaryAction,
    this.secondaryAction,
    this.severityColor = PulsoColors.criticalInk,
  });

  final String title;
  final String subtitle;
  final String reason;
  final List<String> steps;
  final String primaryAction;
  final String? secondaryAction;
  final Color severityColor;
}

const _content = {
  ConnectionErrorKind.lostConnection: _ErrorContent(
    title: 'Conexão perdida',
    subtitle: 'O adaptador parou de responder',
    reason:
        'A última leitura chegou há alguns segundos. Normalmente é o '
        'adaptador que se soltou da porta, ou o celular que ficou longe '
        'demais.',
    steps: [
      'Empurre o adaptador até o fim na porta OBD-II.',
      'Confirme que a luz dele está acesa.',
      'Deixe o celular no suporte, não no bolso de trás.',
    ],
    primaryAction: 'TENTAR DE NOVO',
  ),
  ConnectionErrorKind.ignitionOff: _ErrorContent(
    title: 'A central não responde',
    subtitle: 'O adaptador está ligado, o carro não',
    reason:
        'A porta OBD-II tem energia direto da bateria, então o adaptador '
        'acende mesmo com o carro desligado. Os dados do motor só existem '
        'com a ignição na posição II.',
    steps: [
      'Gire a chave para a posição II (sem dar partida).',
      'Aguarde o painel do carro acender por completo.',
    ],
    primaryAction: 'JÁ LIGUEI — VERIFICAR DE NOVO',
    secondaryAction: 'IR PARA CÓDIGOS DE FALHA',
    severityColor: PulsoColors.attentionInk,
  ),
  ConnectionErrorKind.protocolNotRecognized: _ErrorContent(
    title: 'Protocolo não reconhecido',
    subtitle: 'O adaptador não conseguiu falar com a central',
    reason:
        'Testamos os protocolos padrão e nenhum respondeu. Num Volvo V40 '
        '2019 o esperado é ISO 15765-4 CAN, então provavelmente o problema '
        'é o adaptador, não o carro.',
    steps: [
      'Desplugue o adaptador, conte cinco, plugue de novo.',
      'Force o protocolo CAN 11 bit / 500 kbps.',
      'Se falhar, teste o adaptador em outro carro.',
    ],
    primaryAction: 'FORÇAR CAN 11 BIT · 500 KBPS',
    secondaryAction: 'COPIAR LOG DO HANDSHAKE',
  ),
  ConnectionErrorKind.incompatibleAdapter: _ErrorContent(
    title: 'Adaptador incompatível',
    subtitle: 'Este adaptador é um clone com firmware incompleto',
    reason:
        'Ele responde como ELM327, mas ignora os comandos de cabeçalho e '
        'de temporização. Sem eles não há como garantir que o número lido '
        'é o número que a central mandou.',
    steps: [
      'Veja a lista de adaptadores testados e compatíveis.',
      'Ou use assim mesmo, sem detecção de anomalia.',
    ],
    primaryAction: 'VER ADAPTADORES TESTADOS',
    secondaryAction: 'USAR SEM DETECÇÃO DE ANOMALIA',
  ),
};

/// Telas "02C"–"02F" do mockup — cada falha de conexão é tela de produto,
/// não um erro genérico: título humano, motivo provável, passos numerados
/// na ordem de probabilidade (nota 08 do mockup).
class ConnectionErrorView extends StatelessWidget {
  const ConnectionErrorView({
    super.key,
    required this.kind,
    required this.onPrimaryAction,
    this.onSecondaryAction,
  });

  final ConnectionErrorKind kind;
  final VoidCallback onPrimaryAction;
  final VoidCallback? onSecondaryAction;

  @override
  Widget build(BuildContext context) {
    final content = _content[kind]!;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(PulsoSpacing.s4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.error_outline, color: content.severityColor, size: 32),
            const SizedBox(height: PulsoSpacing.s4),
            Text(content.title, style: PulsoTypography.titleScreen),
            const SizedBox(height: PulsoSpacing.s1),
            Text(content.subtitle, style: PulsoTypography.body.copyWith(color: PulsoColors.ink2)),
            const SizedBox(height: PulsoSpacing.s5),
            Text(content.reason, style: PulsoTypography.body),
            const SizedBox(height: PulsoSpacing.s6),
            Text('TENTE NESTA ORDEM', style: PulsoTypography.titleSection),
            const SizedBox(height: PulsoSpacing.s3),
            for (var i = 0; i < content.steps.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: PulsoSpacing.s3),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: PulsoColors.surfaceRaised,
                        shape: BoxShape.circle,
                      ),
                      child: Text('${i + 1}', style: PulsoTypography.micro.copyWith(color: PulsoColors.ink)),
                    ),
                    const SizedBox(width: PulsoSpacing.s2),
                    Expanded(child: Text(content.steps[i], style: PulsoTypography.body)),
                  ],
                ),
              ),
            const Spacer(),
            ElevatedButton(onPressed: onPrimaryAction, child: Text(content.primaryAction)),
            if (content.secondaryAction != null) ...[
              const SizedBox(height: PulsoSpacing.s3),
              OutlinedButton(onPressed: onSecondaryAction, child: Text(content.secondaryAction!)),
            ],
          ],
        ),
      ),
    );
  }
}
