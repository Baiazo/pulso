import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/colors.dart';
import '../theme/typography.dart';

const _prefKey = 'driving_mode_disclaimer_seen';

/// Aviso de uso ao dirigir no primeiro uso (§16) — persistido entre
/// aberturas do app (não por sessão de coleta), então só aparece uma vez
/// de verdade, não a cada viagem.
Future<void> showDrivingModeDisclaimerIfNeeded(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  if (prefs.getBool(_prefKey) ?? false) return;
  if (!context.mounted) return;

  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: PulsoColors.surface,
      title: const Text('Antes de dirigir', style: PulsoTypography.titleScreen),
      content: const Text(
        'O modo direção mostra só quatro números grandes, sem toque — pra '
        'você não precisar interagir com o celular enquanto dirige. Mesmo '
        'assim, o lugar mais seguro pro aparelho é fixo num suporte, fora '
        'do seu campo de atenção da via.',
        style: PulsoTypography.body,
      ),
      actions: [
        TextButton(
          onPressed: () async {
            await prefs.setBool(_prefKey, true);
            if (dialogContext.mounted) Navigator.of(dialogContext).pop();
          },
          child: const Text('Entendi'),
        ),
      ],
    ),
  );
}
