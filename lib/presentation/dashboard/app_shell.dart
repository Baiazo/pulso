import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/obd/elm327/elm327_client.dart';
import '../connection/connection_state.dart';
import '../diagnostics/dtc_list_screen.dart';
import '../providers/active_session_controller.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';
import '../trips/trips_list_screen.dart';
import '../widgets/connection_chip.dart';
import 'live_dashboard_screen.dart';

const _tabs = ['Painel', 'Alertas', 'Viagens', 'Falhas', 'Veículo'];

/// Casca do app pós-conexão — chip de conexão fixo (mesmo lugar sempre,
/// nota do mockup) e navegação inferior só em texto (nota 06: "cinco
/// palavras curtas são mais rápidas de reconhecer que cinco pictogramas
/// inventados"), com o acento marcando só o item ativo.
class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.connection});

  final ConnectionEstablished connection;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      LiveDashboardScreen(connection: widget.connection),
      const _PlaceholderTab(title: 'Alertas', note: 'item 15'),
      const TripsListScreen(),
      _FalhasTab(client: widget.connection.client),
      const _PlaceholderTab(title: 'Veículo', note: 'item 15/19'),
    ];

    return Scaffold(
      backgroundColor: PulsoColors.bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                PulsoSpacing.s4,
                PulsoSpacing.s3,
                PulsoSpacing.s4,
                PulsoSpacing.s2,
              ),
              child: Row(
                children: [
                  ConnectionChip(
                    connected: true,
                    protocol: widget.connection.protocolDescription,
                  ),
                ],
              ),
            ),
            Expanded(child: IndexedStack(index: _index, children: pages)),
            _BottomNav(selected: _index, onSelect: (i) => setState(() => _index = i)),
          ],
        ),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.selected, required this.onSelect});

  final int selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: PulsoColors.hairline)),
      ),
      child: Row(
        children: [
          for (var i = 0; i < _tabs.length; i++)
            Expanded(
              child: InkWell(
                onTap: () => onSelect(i),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _tabs[i],
                      style: PulsoTypography.label.copyWith(
                        color: i == selected ? PulsoColors.ink : PulsoColors.inkMeta,
                      ),
                    ),
                    const SizedBox(height: PulsoSpacing.s2),
                    Container(
                      height: 2,
                      width: 20,
                      color: i == selected ? PulsoColors.accent : Colors.transparent,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// A tela de diagnóstico (item 14) precisa do `sessionId` da sessão ativa
/// pra persistir os `DtcEvent` lidos — mesma espera de PID suportado que
/// o painel ao vivo (item 12) já faz antes de existir sessão.
class _FalhasTab extends ConsumerWidget {
  const _FalhasTab({required this.client});

  final Elm327Client client;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeSession = ref.watch(activeSessionProvider);
    if (activeSession == null) {
      return const Center(
        child: CircularProgressIndicator(strokeWidth: 2, color: PulsoColors.accent),
      );
    }
    return DtcListScreen(client: client, sessionId: activeSession.sessionId);
  }
}

class _PlaceholderTab extends StatelessWidget {
  const _PlaceholderTab({required this.title, required this.note});

  final String title;
  final String note;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: PulsoTypography.titleScreen),
          const SizedBox(height: PulsoSpacing.s2),
          Text(note, style: PulsoTypography.micro),
        ],
      ),
    );
  }
}
