import '../../../core/errors.dart';

/// Resultado da interpretação de uma resposta bruta do ELM327.
sealed class ParsedFrame {
  const ParsedFrame();
}

/// Resposta textual de um comando AT (`OK`, `ELM327 v1.5`, a descrição do
/// protocolo, etc.) — não é hexadecimal, não tenta decodificar como dado.
final class TextFrame extends ParsedFrame {
  const TextFrame(this.text);
  final String text;
}

/// Resposta de dado (Modo 01–0A), já reagrupada se veio em multi-frame
/// ISO-TP (§7.3) e sem cabeçalho CAN, eco ou espaçamento.
final class DataFrame extends ParsedFrame {
  const DataFrame(this.bytes);
  final List<int> bytes;
}

/// `SEARCHING...` (§7.4) — estado transitório enquanto o adaptador ainda
/// está negociando o protocolo. Não é a resposta final.
final class SearchingFrame extends ParsedFrame {
  const SearchingFrame();
}

/// A resposta é um dos erros explícitos do §7.4, ou não pôde ser
/// interpretada.
final class ErrorFrame extends ParsedFrame {
  const ErrorFrame(this.error);
  final ObdError error;
}

const Map<String, ObdError Function()> _errorTokens = {
  'NO DATA': _noData,
  'UNABLE TO CONNECT': _adapter,
  'BUS INIT: ERROR': _adapter,
  'BUS INIT ERROR': _adapter,
  'BUS BUSY': _adapter,
  'CAN ERROR': _adapter,
  'DATA ERROR': _adapter,
  'STOPPED': _adapter,
  'BUFFER FULL': _adapter,
  'ERROR': _adapter,
  '?': _adapter,
};

ObdError _noData() => const NoDataError();
ObdError _adapter() => const AdapterError('');

final RegExp _headerToken = RegExp(r'^[0-9A-Fa-f]{3}\s+');
final RegExp _hexLengthLine = RegExp(r'^[0-9A-Fa-f]{1,3}$');
final RegExp _multiFrameLine = RegExp(r'^(\d+):([0-9A-Fa-f]+)$');
final RegExp _hexOnly = RegExp(r'^[0-9A-Fa-f\s]+$');

/// Interpreta uma resposta bruta do ELM327: remove o prompt `>`, o eco do
/// comando (se o eco estiver ligado), o cabeçalho CAN (se ATH1 ligado), e
/// reagrupa multi-frame ISO-TP quando presente (§7.3). Detecta as strings
/// de erro do §7.4 antes de tentar decodificar como hexadecimal — uma
/// resposta de comando AT nunca é tratada como dado.
ParsedFrame parseResponse(
  String raw, {
  required bool isAtCommand,
  String? echoedCommand,
  bool headersEnabled = false,
}) {
  final withoutPrompt = raw.replaceFirst(RegExp(r'>\s*$'), '');
  var lines = withoutPrompt
      .split(RegExp(r'\r\n|\r|\n'))
      .map((l) => l.trim())
      .where((l) => l.isNotEmpty)
      .toList();

  if (echoedCommand != null &&
      lines.isNotEmpty &&
      lines.first.toUpperCase() == echoedCommand.toUpperCase()) {
    lines = lines.sublist(1);
  }

  if (headersEnabled) {
    lines = lines.map((l) => l.replaceFirst(_headerToken, '')).toList();
  }

  if (lines.isEmpty) {
    return const ErrorFrame(ParseError(''));
  }

  final joined = lines.join(' ').trim();
  final asError = _errorTokens[joined.toUpperCase()];
  if (asError != null) {
    return ErrorFrame(
      joined.toUpperCase() == 'NO DATA' ? _noData() : AdapterError(joined),
    );
  }
  if (joined.toUpperCase() == 'SEARCHING...') {
    return const SearchingFrame();
  }

  if (isAtCommand) {
    return TextFrame(joined);
  }

  if (lines.length >= 2 &&
      _hexLengthLine.hasMatch(lines.first) &&
      _multiFrameLine.hasMatch(lines[1])) {
    return _parseMultiFrame(raw, lines);
  }

  final flatHex = lines.join('').replaceAll(' ', '');
  if (flatHex.isEmpty || flatHex.length.isOdd || !_hexOnly.hasMatch(flatHex)) {
    return ErrorFrame(ParseError(raw));
  }
  return DataFrame(_hexToBytes(flatHex));
}

ParsedFrame _parseMultiFrame(String raw, List<String> lines) {
  final declaredLength = int.parse(lines.first, radix: 16);
  final bytes = <int>[];
  for (final line in lines.skip(1)) {
    final match = _multiFrameLine.firstMatch(line);
    if (match == null) return ErrorFrame(ParseError(raw));
    bytes.addAll(_hexToBytes(match.group(2)!));
  }
  if (bytes.length < declaredLength) return ErrorFrame(ParseError(raw));
  return DataFrame(bytes.sublist(0, declaredLength));
}

List<int> _hexToBytes(String hex) {
  final bytes = <int>[];
  for (var i = 0; i + 1 < hex.length; i += 2) {
    bytes.add(int.parse(hex.substring(i, i + 2), radix: 16));
  }
  return bytes;
}

/// `true` quando `buffer` já contém uma resposta completa (terminada pelo
/// prompt `>`) — usado pelo client para saber quando parar de acumular
/// pedaços do stream e chamar [parseResponse].
bool hasCompletePrompt(String buffer) => buffer.contains('>');
