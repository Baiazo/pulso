import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/result.dart';
import '../../data/obd/elm327/elm327_client.dart';
import '../../data/obd/elm327/response_parser.dart';
import '../../data/obd/pids/pid_decoder.dart';
import '../../domain/entities/raw_frame.dart';
import '../connection/connection_controller.dart';
import '../connection/connection_state.dart';
import '../providers/active_session_controller.dart';
import '../providers/app_providers.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';

/// "Modo de validação" (item 16, RF22): liga `ATH1` em toda consulta e
/// grava cada par comando/resposta bruta em `raw_frames` — a evidência que
/// a seção 5.7 do TCC usa para comparar a leitura do Pulso contra a de um
/// scanner comercial. É uma tela alcançada por push (a partir de
/// Veículo), não uma aba do AppShell — por isso tem Scaffold/AppBar
/// próprios.
class ValidationModeScreen extends ConsumerWidget {
  const ValidationModeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectionState = ref.watch(connectionControllerProvider);

    return Scaffold(
      backgroundColor: PulsoColors.bg,
      appBar: AppBar(
        backgroundColor: PulsoColors.bg,
        elevation: 0,
        title: Text('Modo de validação', style: PulsoTypography.titleScreen),
      ),
      body: SafeArea(
        child: switch (connectionState) {
          // Só deveria acontecer se esta tela fosse alcançada fora do
          // AppShell (não é o caso hoje) — guarda mesmo assim, em vez de
          // presumir `client` sempre existe.
          ConnectionEstablished(:final client) => _ValidationBody(client: client),
          _ => Center(
              child: Text(
                'Sem conexão com o adaptador.',
                style: PulsoTypography.body,
              ),
            ),
        },
      ),
    );
  }
}

class _ValidationBody extends ConsumerWidget {
  const _ValidationBody({required this.client});

  final Elm327Client client;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeSession = ref.watch(activeSessionProvider);
    if (activeSession == null) {
      return const Center(
        child: CircularProgressIndicator(strokeWidth: 2, color: PulsoColors.accent),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(PulsoSpacing.s4),
      children: [
        _ValidationSwitch(enabled: activeSession.validationMode, client: client),
        const SizedBox(height: PulsoSpacing.s6),
        if (activeSession.validationMode)
          _RawFrameList(sessionId: activeSession.sessionId)
        else
          Text(
            'Ligue para começar a gravar o tráfego bruto desta sessão.',
            style: PulsoTypography.micro,
          ),
      ],
    );
  }
}

class _ValidationSwitch extends ConsumerWidget {
  const _ValidationSwitch({required this.enabled, required this.client});

  final bool enabled;
  final Elm327Client client;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(PulsoSpacing.s4),
      decoration: BoxDecoration(
        color: PulsoColors.surface,
        borderRadius: BorderRadius.circular(PulsoRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Modo de validação',
                  style: PulsoTypography.label.copyWith(color: PulsoColors.ink),
                ),
              ),
              Switch(
                value: enabled,
                activeThumbColor: PulsoColors.accent,
                onChanged: (value) =>
                    ref.read(activeSessionProvider.notifier).setValidationMode(value, client),
              ),
            ],
          ),
          const SizedBox(height: PulsoSpacing.s2),
          Text(
            'Liga os cabeçalhos CAN em toda resposta e grava o tráfego bruto '
            'desta sessão — evidência para comparar contra um scanner '
            'comercial.',
            style: PulsoTypography.body,
          ),
        ],
      ),
    );
  }
}

class _RawFrameList extends ConsumerWidget {
  const _RawFrameList({required this.sessionId});

  final int sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(rawFrameRepositoryProvider);
    return StreamBuilder<List<RawFrame>>(
      stream: repo.watchForSession(sessionId),
      builder: (context, snapshot) {
        final frames = snapshot.data;
        if (frames == null) {
          return const Center(
            child: CircularProgressIndicator(strokeWidth: 2, color: PulsoColors.accent),
          );
        }
        if (frames.isEmpty) {
          return Text('Nenhum quadro capturado ainda.', style: PulsoTypography.micro);
        }

        // `watchForSession` devolve em ordem crescente de `ts` (mesma
        // convenção de LocalDtcRepository) — invertido aqui pra mostrar o
        // quadro mais recente primeiro, como o mockup pede pra evidência
        // que se acumula ao vivo.
        final ordered = frames.reversed.toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('QUADROS CAPTURADOS · ${ordered.length}', style: PulsoTypography.titleSection),
            const SizedBox(height: PulsoSpacing.s3),
            for (final frame in ordered) _RawFrameRow(frame: frame),
          ],
        );
      },
    );
  }
}

class _RawFrameRow extends StatelessWidget {
  const _RawFrameRow({required this.frame});

  final RawFrame frame;

  @override
  Widget build(BuildContext context) {
    final decoded = _bestEffortDecode(frame.comando, frame.respostaBruta);
    return Container(
      margin: const EdgeInsets.only(bottom: PulsoSpacing.s3),
      padding: const EdgeInsets.all(PulsoSpacing.s3),
      decoration: BoxDecoration(
        color: PulsoColors.surface,
        borderRadius: BorderRadius.circular(PulsoRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(frame.comando, style: PulsoTypography.monoCode),
              Text(decoded, style: PulsoTypography.monoCode.copyWith(color: PulsoColors.ink2)),
            ],
          ),
          const SizedBox(height: PulsoSpacing.s1),
          Text(
            _trimRawResponse(frame.respostaBruta),
            style: PulsoTypography.monoCode.copyWith(color: PulsoColors.inkMeta),
          ),
        ],
      ),
    );
  }
}

/// Só remove o prompt final e as bordas em branco — de propósito, não
/// reformata mais que isso: o ponto da tela é mostrar o dado bruto tal
/// como veio do adaptador.
String _trimRawResponse(String raw) => raw.replaceFirst(RegExp(r'>\s*$'), '').trim();

/// Decodificação melhor-esforço só para exibição — nunca é a fonte da
/// verdade (essa é `respostaBruta`, gravada intacta). Espelha exatamente
/// a checagem de cabeçalho de `Elm327Client._decodePidResponse`: byte 0 é
/// `0x40 + modo`, byte 1 é o PID, o resto é o dado. Qualquer coisa que não
/// se encaixe (comando AT, modo de DTC/VIN, resposta que não decodifica)
/// mostra "—" — é publicidade, nunca motivo pra derrubar a tela.
String _bestEffortDecode(String comando, String respostaBruta) {
  try {
    final upper = comando.trim().toUpperCase();
    if (upper.length < 4) return '—';

    final mode = int.tryParse(upper.substring(0, 2), radix: 16);
    final pid = int.tryParse(upper.substring(2, 4), radix: 16);
    if (mode == null || pid == null || mode != 0x01) return '—';

    final def = findPidByCode(mode: 0x01, pid: pid);
    if (def == null) return '—';

    final parsed = parseResponse(
      respostaBruta,
      isAtCommand: false,
      echoedCommand: null,
      // O modo de validação sempre está com ATH1 ligado enquanto captura
      // (é o próprio propósito do modo), e o eco já está desligado a
      // essa altura da sessão (handshake do §7.1) — mesmo tratamento que
      // o resto do app dá ao tráfego pós-handshake.
      headersEnabled: true,
    );
    if (parsed is! DataFrame) return '—';

    final bytes = parsed.bytes;
    if (bytes.length < 2 || bytes[0] != 0x40 + mode || bytes[1] != pid) return '—';

    final result = decodePidValue(def, bytes.sublist(2));
    return switch (result) {
      Ok(:final value) => '${value.toStringAsFixed(1)} ${def.unit}'.trim(),
      Err() => '—',
    };
  } catch (_) {
    return '—';
  }
}
