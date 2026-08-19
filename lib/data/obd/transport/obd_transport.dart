import '../../../core/errors.dart';
import '../../../core/result.dart';

/// Canal serial com o adaptador OBD-II — Bluetooth clássico (SPP), BLE, ou
/// o simulador (§13). Não sabe nada de ELM327 ou de PIDs: só transporta
/// texto. Isso é o que permite trocar `flutter_bluetooth_serial` sem afetar
/// o resto do app (§5).
abstract class ObdTransport {
  /// Abre a conexão com o adaptador. Idempotente: chamar de novo com a
  /// conexão já aberta não deve reabrir.
  Future<Result<void, ObdError>> connect();

  /// Envia um comando bruto (sem o `\r` final — quem formata a linha de
  /// comando é o [ObdTransport], não o chamador).
  Future<Result<void, ObdError>> write(String command);

  /// Dados brutos recebidos do adaptador, como chegam do canal serial —
  /// sem framing por resposta. Juntar isso numa resposta completa (até o
  /// prompt `>`) é responsabilidade de quem lê o stream (Elm327Client).
  Stream<String> get incoming;

  /// `true` enquanto a conexão está aberta.
  bool get isConnected;

  /// Fecha a conexão e libera recursos. Seguro chamar mais de uma vez.
  Future<void> dispose();
}
