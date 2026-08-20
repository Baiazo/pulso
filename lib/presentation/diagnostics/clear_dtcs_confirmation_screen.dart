import 'package:flutter/material.dart';

import '../../core/result.dart';
import '../../data/obd/dtc/dtc_decoder.dart';
import '../../data/obd/dtc/dtc_catalog.dart';
import '../../data/obd/elm327/elm327_client.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';

/// "06C · APAGAR CÓDIGOS — CONFIRMAÇÃO" do mockup — RF19: apagar DTCs
/// (Modo 04) só mediante confirmação explícita; RNF05: é o único comando
/// de escrita que este app manda para a ECU.
class ClearDtcsConfirmationScreen extends StatefulWidget {
  const ClearDtcsConfirmationScreen({
    super.key,
    required this.client,
    required this.toDelete,
    required this.keptPermanent,
  });

  final Elm327Client client;

  /// Ativos + pendentes — o Modo 04 apaga os dois.
  final List<DtcCode> toDelete;

  /// Permanentes — só a própria central apaga este tipo (§9), nenhum app
  /// consegue, então nem tenta: só informa que vão continuar lá.
  final List<DtcCode> keptPermanent;

  @override
  State<ClearDtcsConfirmationScreen> createState() =>
      _ClearDtcsConfirmationScreenState();
}

class _ClearDtcsConfirmationScreenState extends State<ClearDtcsConfirmationScreen> {
  bool _clearing = false;
  String? _error;

  Future<void> _confirm() async {
    setState(() {
      _clearing = true;
      _error = null;
    });
    final result = await widget.client.clearDtcs();
    if (!mounted) return;
    switch (result) {
      case Err():
        setState(() {
          _clearing = false;
          _error = 'A central não respondeu ao comando de apagar. Tente de novo.';
        });
      case Ok():
        Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PulsoColors.bg,
      appBar: AppBar(
        backgroundColor: PulsoColors.bg,
        elevation: 0,
        title: const Text('Códigos de falha', style: PulsoTypography.titleScreen),
      ),
      body: ListView(
        padding: const EdgeInsets.all(PulsoSpacing.s4),
        children: [
          Text('Apagar apaga a prova', style: PulsoTypography.titleScreen),
          const SizedBox(height: PulsoSpacing.s3),
          Text(
            'A luz do painel some, mas o defeito continua. Você também perde o '
            'registro das condições em que a falha aconteceu — é justamente '
            'isso que a oficina usa para achar o problema.',
            style: PulsoTypography.body,
          ),
          const SizedBox(height: PulsoSpacing.s6),
          Text('SERÃO APAGADOS', style: PulsoTypography.titleSection),
          const SizedBox(height: PulsoSpacing.s3),
          for (final code in widget.toDelete) _CodeRow(code: code, willBeDeleted: true),
          for (final code in widget.keptPermanent) _CodeRow(code: code, willBeDeleted: false),
          const SizedBox(height: PulsoSpacing.s6),
          Text(
            'O Pulso guarda uma cópia do que foi lido antes de apagar, em '
            'Viagens → Diagnóstico.',
            style: PulsoTypography.micro,
          ),
          if (_error != null) ...[
            const SizedBox(height: PulsoSpacing.s4),
            Text(_error!, style: PulsoTypography.body.copyWith(color: PulsoColors.criticalInk)),
          ],
          const SizedBox(height: PulsoSpacing.s7),
          SizedBox(
            height: 52,
            child: FilledButton(
              onPressed: _clearing ? null : _confirm,
              style: FilledButton.styleFrom(backgroundColor: PulsoColors.criticalInk),
              child: _clearing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: PulsoColors.ink),
                    )
                  : Text('Apagar os ${widget.toDelete.length} códigos'),
            ),
          ),
          const SizedBox(height: PulsoSpacing.s3),
          SizedBox(
            height: 52,
            child: OutlinedButton(
              onPressed: _clearing ? null : () => Navigator.of(context).pop(false),
              child: const Text('Manter como está'),
            ),
          ),
        ],
      ),
    );
  }
}

class _CodeRow extends StatelessWidget {
  const _CodeRow({required this.code, required this.willBeDeleted});

  final DtcCode code;
  final bool willBeDeleted;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: PulsoSpacing.s3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(code.code, style: PulsoTypography.monoCode),
          const SizedBox(width: PulsoSpacing.s3),
          Expanded(
            child: Text(
              willBeDeleted ? describeDtc(code) : 'permanente — não será apagado',
              style: PulsoTypography.micro,
            ),
          ),
        ],
      ),
    );
  }
}
