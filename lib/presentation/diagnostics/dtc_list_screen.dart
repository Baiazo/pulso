import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/result.dart';
import '../../data/obd/dtc/dtc_catalog.dart';
import '../../data/obd/dtc/dtc_decoder.dart';
import '../../data/obd/dtc/dtc_reader.dart';
import '../../data/obd/elm327/elm327_client.dart';
import '../../domain/entities/dtc_event.dart';
import '../../domain/entities/enums.dart';
import '../providers/app_providers.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';
import '../widgets/dtc_chip.dart';
import 'clear_dtcs_confirmation_screen.dart';
import 'dtc_detail_screen.dart';

/// "06 · DIAGNÓSTICO (DTCS)" do mockup — RF06/RF07: lê ativos, pendentes e
/// permanentes (§9) e o freeze frame associado (Modo 02, sob demanda,
/// §10), e persiste cada leitura como um `DtcEvent` (histórico de
/// auditoria — não é um cache descartável).
class DtcListScreen extends ConsumerStatefulWidget {
  const DtcListScreen({super.key, required this.client, required this.sessionId});

  final Elm327Client client;
  final int sessionId;

  @override
  ConsumerState<DtcListScreen> createState() => _DtcListScreenState();
}

class _DtcListScreenState extends ConsumerState<DtcListScreen> {
  bool _loading = true;
  String? _error;
  AllDtcs? _result;
  Map<String, double> _freezeFrame = const {};
  DateTime? _lastRead;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final result = await readAllDtcs(widget.client);
    if (!mounted) return;

    switch (result) {
      case Err():
        setState(() {
          _loading = false;
          _error = 'Não foi possível ler a central agora. Tente de novo.';
        });
        return;
      case Ok(:final value):
        final freezeFrame =
            value.isEmpty ? <String, double>{} : await readFreezeFrameSnapshot(widget.client);
        if (!mounted) return;

        final now = DateTime.now();
        final repo = ref.read(dtcRepositoryProvider);
        for (final code in value.ativos) {
          await repo.record(
            sessionId: widget.sessionId,
            ts: now,
            codigo: code.code,
            tipo: DtcEventType.ativo,
            descricao: describeDtc(code),
            freezeFrame: freezeFrame,
          );
        }
        for (final code in value.pendentes) {
          await repo.record(
            sessionId: widget.sessionId,
            ts: now,
            codigo: code.code,
            tipo: DtcEventType.pendente,
            descricao: describeDtc(code),
            freezeFrame: freezeFrame,
          );
        }
        for (final code in value.permanentes) {
          await repo.record(
            sessionId: widget.sessionId,
            ts: now,
            codigo: code.code,
            tipo: DtcEventType.permanente,
            descricao: describeDtc(code),
            freezeFrame: freezeFrame,
          );
        }

        if (!mounted) return;
        setState(() {
          _loading = false;
          _result = value;
          _freezeFrame = freezeFrame;
          _lastRead = now;
        });
    }
  }

  Future<void> _clear() async {
    final result = _result;
    if (result == null) return;
    final toDelete = [...result.ativos, ...result.pendentes];
    final cleared = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => ClearDtcsConfirmationScreen(
          client: widget.client,
          toDelete: toDelete,
          keptPermanent: result.permanentes,
        ),
      ),
    );
    if (cleared == true) await _refresh();
  }

  void _openDetail(DtcCode code, DtcEventType tipo) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => DtcDetailScreen(
          event: DtcEvent(
            uuid: '',
            sessionId: widget.sessionId,
            ts: _lastRead ?? DateTime.now(),
            codigo: code.code,
            tipo: tipo,
            descricao: describeDtc(code),
            freezeFrame: _freezeFrame,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;
    return Scaffold(
      backgroundColor: PulsoColors.bg,
      body: SafeArea(
        child: _loading && result == null
            ? const Center(
                child: CircularProgressIndicator(strokeWidth: 2, color: PulsoColors.accent),
              )
            : ListView(
                padding: const EdgeInsets.all(PulsoSpacing.s4),
                children: [
                  Text('Códigos de falha', style: PulsoTypography.titleScreen),
                  const SizedBox(height: PulsoSpacing.s1),
                  Text(
                    result == null
                        ? 'Sem leitura ainda'
                        : 'Lidos da central agora · ${_totalCount(result)} códigos guardados',
                    style: PulsoTypography.micro,
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: PulsoSpacing.s4),
                    Text(_error!, style: PulsoTypography.body.copyWith(color: PulsoColors.criticalInk)),
                  ],
                  const SizedBox(height: PulsoSpacing.s6),
                  if (result != null && result.isEmpty) const _EmptyDtcs(),
                  if (result != null && !result.isEmpty) ...[
                    _DtcSection(
                      title: 'ATIVO',
                      tipo: DtcEventType.ativo,
                      codes: result.ativos,
                      onTap: _openDetail,
                    ),
                    _DtcSection(
                      title: 'PENDENTE',
                      tipo: DtcEventType.pendente,
                      codes: result.pendentes,
                      onTap: _openDetail,
                    ),
                    _DtcSection(
                      title: 'PERMANENTE',
                      tipo: DtcEventType.permanente,
                      codes: result.permanentes,
                      onTap: _openDetail,
                    ),
                  ],
                  const SizedBox(height: PulsoSpacing.s5),
                  SizedBox(
                    height: 52,
                    child: OutlinedButton(
                      onPressed: _loading ? null : _refresh,
                      child: const Text('Ler a central de novo'),
                    ),
                  ),
                  if (result != null && (result.ativos.isNotEmpty || result.pendentes.isNotEmpty)) ...[
                    const SizedBox(height: PulsoSpacing.s3),
                    SizedBox(
                      height: 52,
                      child: OutlinedButton(
                        onPressed: _loading ? null : _clear,
                        style: OutlinedButton.styleFrom(foregroundColor: PulsoColors.criticalInk),
                        child: const Text('Apagar códigos'),
                      ),
                    ),
                  ],
                  const SizedBox(height: PulsoSpacing.s6),
                ],
              ),
      ),
    );
  }

  int _totalCount(AllDtcs result) =>
      result.ativos.length + result.pendentes.length + result.permanentes.length;
}

class _DtcSection extends StatelessWidget {
  const _DtcSection({
    required this.title,
    required this.tipo,
    required this.codes,
    required this.onTap,
  });

  final String title;
  final DtcEventType tipo;
  final List<DtcCode> codes;
  final void Function(DtcCode code, DtcEventType tipo) onTap;

  @override
  Widget build(BuildContext context) {
    if (codes.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: PulsoSpacing.s6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$title · ${codes.length}', style: PulsoTypography.titleSection),
          const SizedBox(height: PulsoSpacing.s3),
          for (final code in codes)
            Padding(
              padding: const EdgeInsets.only(bottom: PulsoSpacing.s4),
              child: InkWell(
                onTap: () => onTap(code, tipo),
                child: Container(
                  padding: const EdgeInsets.all(PulsoSpacing.s4),
                  decoration: BoxDecoration(
                    color: PulsoColors.surface,
                    borderRadius: BorderRadius.circular(PulsoRadius.card),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DtcChip(code: code.code, system: code.system, tipo: tipo),
                      const SizedBox(height: PulsoSpacing.s2),
                      Text(describeDtc(code), style: PulsoTypography.body),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _EmptyDtcs extends StatelessWidget {
  const _EmptyDtcs();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: PulsoSpacing.s8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Nenhuma falha guardada', style: PulsoTypography.titleScreen),
          const SizedBox(height: PulsoSpacing.s3),
          Text(
            'A central não tem código ativo, pendente nem permanente. A luz '
            'da injeção está apagada e nada ficou registrado desde a última '
            'leitura.',
            style: PulsoTypography.body,
          ),
        ],
      ),
    );
  }
}
