import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../dashboard/app_shell.dart';
import '../theme/colors.dart';
import 'connection_controller.dart';
import 'connection_error_view.dart';
import 'connection_state.dart';
import 'device_scan_view.dart';
import 'handshake_view.dart';
import 'opening_view.dart';

/// Item 11 — dispatcher único do fluxo de conexão: a tela renderizada
/// segue direto do estado do [ConnectionController], sem rotas separadas
/// pra cada etapa (a máquina de estados já é a navegação).
class ConnectionFlowScreen extends ConsumerWidget {
  const ConnectionFlowScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(connectionControllerProvider);
    final controller = ref.read(connectionControllerProvider.notifier);

    return Scaffold(
      backgroundColor: PulsoColors.bg,
      body: switch (state) {
        ConnectionIdle() => OpeningView(onStartScan: controller.startScan),
        ConnectionScanning(:final devices) => DeviceScanView(devices: devices),
        ConnectionHandshaking() =>
          HandshakeView(state: state, onCancel: controller.reset),
        ConnectionEstablished() => AppShell(connection: state),
        ConnectionFailed(:final kind) => ConnectionErrorView(
            kind: kind,
            onPrimaryAction: controller.reset,
            onSecondaryAction: controller.reset,
          ),
      },
    );
  }
}
