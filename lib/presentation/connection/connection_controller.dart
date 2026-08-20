import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/result.dart';
import '../../data/obd/elm327/elm327_client.dart';
import '../../data/obd/elm327/response_parser.dart';
import '../../data/obd/transport/device_scanner.dart';
import '../../data/obd/transport/mock/mock_vehicle.dart';
import '../../data/obd/transport/mock_transport.dart';
import '../../data/obd/transport/obd_transport.dart';
import '../providers/active_session_controller.dart';
import 'connection_state.dart';

final deviceScannerProvider = Provider<DeviceScanner>((ref) => MockDeviceScanner());

/// Item 9 troca este provider por um que decide entre BLE e SPP clássico
/// conforme o dispositivo escolhido — a interface `ObdTransport` já
/// esconde essa diferença do resto do app (§5).
final connectionControllerProvider =
    NotifierProvider<ConnectionController, ObdConnectionState>(
  ConnectionController.new,
);

class ConnectionController extends Notifier<ObdConnectionState> {
  @override
  ObdConnectionState build() => const ConnectionIdle();

  Future<void> startScan() async {
    state = const ConnectionScanning([]);
    final scanner = ref.read(deviceScannerProvider);
    await for (final devices in scanner.scan()) {
      if (state is! ConnectionScanning) return; // usuário cancelou/saiu
      state = ConnectionScanning(devices);
    }
  }

  /// "Ver em modo demonstração" — conecta direto ao simulador, sem
  /// varredura (RF21).
  Future<void> connectDemoMode({MockProfile profile = MockProfile.normal}) {
    return _connect(MockTransport(profile: profile));
  }

  /// "Conectar ao [dispositivo]" — mesmo simulador por enquanto (não há
  /// transporte Bluetooth real até o item 9); o ponto importante é que a
  /// tela de handshake não muda quando isso for trocado.
  Future<void> connectToDevice(DiscoveredDevice device) {
    return _connect(MockTransport());
  }

  Future<void> _connect(ObdTransport transport) async {
    final log = <HandshakeLogLine>[];
    state = const ConnectionHandshaking(log: [], stepLabel: 'Conectando ao adaptador');

    final connectResult = await transport.connect();
    if (connectResult.isErr) {
      state = const ConnectionFailed(ConnectionErrorKind.lostConnection);
      return;
    }

    final client = Elm327Client(transport);
    state = ConnectionHandshaking(log: List.of(log), stepLabel: 'Negociando protocolo');

    final handshakeResult = await client.handshake(
      onStep: (command, response) {
        log.add(HandshakeLogLine(command: command, response: _describe(response)));
        state = ConnectionHandshaking(
          log: List.of(log),
          stepLabel: _stepLabelFor(command),
        );
      },
    );

    switch (handshakeResult) {
      case Ok(value: final protocolDescription):
        state = ConnectionEstablished(
          protocolDescription: protocolDescription,
          transport: transport,
          client: client,
        );
        // Dispara a sessão de coleta (item 8+10) só depois de publicar o
        // estado conectado — o painel ao vivo já pode montar a UI
        // enquanto a descoberta de PIDs roda em segundo plano.
        unawaited(
          ref.read(activeSessionProvider.notifier).startFor(
                client,
                protocolDescription: protocolDescription,
              ),
        );
      case Err():
        state = const ConnectionFailed(ConnectionErrorKind.protocolNotRecognized);
    }
  }

  String _describe(ParsedFrame frame) => switch (frame) {
        TextFrame(:final text) => text,
        DataFrame(:final bytes) =>
          bytes.map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase()).join(),
        SearchingFrame() => 'SEARCHING...',
        ErrorFrame(:final error) => '$error',
      };

  String _stepLabelFor(String command) {
    final upper = command.toUpperCase();
    if (upper == 'ATZ') return 'Adaptador respondeu';
    if (upper.startsWith('ATSP')) return 'Detectando protocolo';
    if (upper == '0100') return 'Lendo PIDs suportados';
    if (upper == 'ATDP') return 'Confirmando protocolo';
    return 'Negociando protocolo';
  }

  void reset() => state = const ConnectionIdle();
}
