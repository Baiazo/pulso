import '../../../core/errors.dart';
import '../../../core/result.dart';
import '../elm327/elm327_client.dart';
import '../elm327/response_parser.dart';
import 'pid_catalog.dart';
import 'pid_definition.dart';

/// Consulta `0100`, `0120`, `0140`, `0160` e decodifica os bitmaps de PIDs
/// suportados (§7.5). Para em qualquer bloco cujo último bit venha
/// desligado — esse bit nunca é um PID de dado real, é só o sinal de
/// "existe mais além deste bloco".
Future<Result<Set<int>, ObdError>> discoverSupportedPids(
  Elm327Client client,
) async {
  final supported = <int>{};
  var basePid = 0x00;

  // Só existem 4 blocos possíveis (00/20/40/60) — o limite é uma guarda
  // contra um ECU malformado que sempre ligue o bit de continuação.
  for (var block = 0; block < 4; block++) {
    final cmd = '01${basePid.toRadixString(16).padLeft(2, '0').toUpperCase()}';
    final result = await client.sendCommand(cmd);
    final ParsedFrame frame;
    switch (result) {
      case Err(:final error):
        return Err(error);
      case Ok(:final value):
        frame = value;
    }

    if (frame is! DataFrame || frame.bytes.length < 6) {
      return Err(ParseError(cmd));
    }

    final bytes = frame.bytes;
    final bitmap =
        (bytes[2] << 24) | (bytes[3] << 16) | (bytes[4] << 8) | bytes[5];

    var continueToNextBlock = false;
    for (var offset = 1; offset <= 32; offset++) {
      final bitSet = (bitmap >> (32 - offset)) & 1 == 1;
      if (offset == 32) {
        continueToNextBlock = bitSet;
      } else if (bitSet) {
        supported.add(basePid + offset);
      }
    }

    if (!continueToNextBlock) break;
    basePid += 0x20;
  }

  return Ok(supported);
}

/// Restringe o catálogo (§8) aos PIDs realmente suportados pelo veículo —
/// é o que o agendador (§10) deve usar para montar o rodízio, nunca o
/// catálogo completo direto.
List<PidDefinition> filterSupportedCatalog(Set<int> supportedPids) =>
    pidCatalog.where((def) => supportedPids.contains(def.pid)).toList();
