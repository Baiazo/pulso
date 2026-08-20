import '../../data/obd/elm327/elm327_client.dart';
import '../../data/obd/transport/device_scanner.dart';
import '../../data/obd/transport/obd_transport.dart';

/// As 4 causas de falha de conexão do mockup (telas 02C–02F) — cada uma
/// tem título, motivo e passos numerados próprios; nenhuma é um erro
/// genérico "algo deu errado".
enum ConnectionErrorKind {
  lostConnection, // 02C — fora de alcance
  ignitionOff, // 02D — central não responde
  protocolNotRecognized, // 02E — nenhum dos 9 protocolos respondeu
  incompatibleAdapter, // 02F — firmware clone incompleto
}

sealed class ObdConnectionState {
  const ObdConnectionState();
}

class ConnectionIdle extends ObdConnectionState {
  const ConnectionIdle();
}

class ConnectionScanning extends ObdConnectionState {
  const ConnectionScanning(this.devices);
  final List<DiscoveredDevice> devices;
}

/// Uma linha do log de handshake — mesmo formato do terminal do mockup
/// (`> ATZ    ELM327 v1.5`).
class HandshakeLogLine {
  const HandshakeLogLine({required this.command, required this.response});
  final String command;
  final String response;
}

class ConnectionHandshaking extends ObdConnectionState {
  const ConnectionHandshaking({required this.log, required this.stepLabel});
  final List<HandshakeLogLine> log;
  final String stepLabel;
}

class ConnectionEstablished extends ObdConnectionState {
  const ConnectionEstablished({
    required this.protocolDescription,
    required this.transport,
    required this.client,
  });

  final String protocolDescription;
  final ObdTransport transport;
  final Elm327Client client;
}

class ConnectionFailed extends ObdConnectionState {
  const ConnectionFailed(this.kind, {this.savedSessionMinutes});
  final ConnectionErrorKind kind;

  /// Só preenchido em [ConnectionErrorKind.lostConnection] — "a viagem
  /// não foi perdida" (tela 02C).
  final int? savedSessionMinutes;
}
