import 'dart:async';

import '../../../core/errors.dart';
import '../../../core/result.dart';
import '../dtc/dtc_decoder.dart';
import '../pids/pid_decoder.dart';
import '../pids/pid_definition.dart';
import '../transport/obd_transport.dart';
import 'elm327_commands.dart';
import 'response_parser.dart';

/// Cliente ELM327 sobre um [ObdTransport]. Único ponto do app que escreve
/// no transporte — a fila serial garante que nunca há dois comandos em
/// voo ao mesmo tempo (§7.2): misturar respostas produz valor errado sem
/// lançar erro, o defeito mais comum de app OBD amador.
class Elm327Client {
  Elm327Client(this._transport);

  final ObdTransport _transport;

  Future<void> _tail = Future.value();

  bool _echoEnabled = true;
  bool _headersEnabled = false;

  static const _defaultTimeout = Duration(milliseconds: 1000);

  /// 4000 ms para Modos 03/09, como o §7.2 pede — estendido também a
  /// 07/0A, que têm a mesma forma de resposta (DTCs, potencialmente
  /// multi-frame) e o mesmo motivo de precisar de mais tempo.
  static const _dtcTimeout = Duration(milliseconds: 4000);

  /// Envia um comando bruto e devolve a resposta já interpretada
  /// (§7.3/§7.4). Enfileira internamente — chamadas concorrentes são
  /// atendidas uma de cada vez, na ordem em que chegaram: cada elo da
  /// fila só inicia depois que o anterior recebeu resposta ou expirou.
  Future<Result<ParsedFrame, ObdError>> sendCommand(
    String command, {
    Duration? timeout,
  }) {
    final completer = Completer<Result<ParsedFrame, ObdError>>();
    final previous = _tail;
    _tail = previous.then((_) async {
      final result = await _sendOne(command, timeout ?? _timeoutFor(command));
      completer.complete(result);
    });
    return completer.future;
  }

  Duration _timeoutFor(String command) {
    final upper = command.toUpperCase();
    final isDtcOrVin = upper.startsWith('03') ||
        upper.startsWith('07') ||
        upper.startsWith('0A') ||
        upper.startsWith('09');
    return isDtcOrVin ? _dtcTimeout : _defaultTimeout;
  }

  Future<Result<ParsedFrame, ObdError>> _sendOne(
    String command,
    Duration timeout,
  ) async {
    final buffer = StringBuffer();
    final completer = Completer<Result<ParsedFrame, ObdError>>();
    late final StreamSubscription<String> sub;
    Timer? timer;

    void finish(Result<ParsedFrame, ObdError> result) {
      if (completer.isCompleted) return;
      timer?.cancel();
      unawaited(sub.cancel());
      completer.complete(result);
    }

    sub = _transport.incoming.listen((chunk) {
      buffer.write(chunk);
      if (hasCompletePrompt(buffer.toString())) {
        // Modo 04 (apagar DTCs) é o único modo de serviço cuja resposta é
        // texto puro ("OK"), não um frame de dado — tratado como comando
        // AT só para fins de parsing, aqui.
        final upper = command.toUpperCase();
        final isAt = upper.startsWith('AT') || upper == '04';
        final parsed = parseResponse(
          buffer.toString(),
          isAtCommand: isAt,
          echoedCommand: _echoEnabled ? command : null,
          headersEnabled: _headersEnabled,
        );
        finish(Ok(parsed));
      }
    });

    timer = Timer(timeout, () => finish(Err(TimeoutError(command))));

    final writeResult = await _transport.write(command);
    writeResult.when(ok: (_) {}, err: (e) => finish(Err(e)));

    return completer.future;
  }

  void _applyHandshakeState(String step) {
    switch (step) {
      case AtCommands.echoOff:
        _echoEnabled = false;
      case AtCommands.echoOn:
        _echoEnabled = true;
      case AtCommands.headersOn:
        _headersEnabled = true;
      case AtCommands.headersOff:
        _headersEnabled = false;
    }
  }

  /// Sequência de handshake do §7.1. Faz fallback para detecção automática
  /// de protocolo (`ATSP0`) se a primeira consulta real (`0100`) falhar
  /// com o protocolo fixo (CAN 11 bits / 500 kbps). Devolve a descrição
  /// do protocolo negociado (resposta do `ATDP`).
  ///
  /// `onStep`, se informado, é chamado depois de cada comando — é o que
  /// alimenta a tela de handshake (item 11) com o progresso real, sem
  /// duplicar esta sequência na camada de apresentação.
  Future<Result<String, ObdError>> handshake({
    void Function(String command, ParsedFrame response)? onStep,
  }) async {
    const steps = [
      AtCommands.reset,
      AtCommands.echoOff,
      AtCommands.linefeedsOff,
      AtCommands.spacesOff,
      AtCommands.headersOff,
    ];

    for (final step in steps) {
      final result = await sendCommand(step);
      if (result case Err(:final error)) return Err(error);
      if (result case Ok(:final value)) onStep?.call(step, value);
      _applyHandshakeState(step);
    }

    final protocolCommand = AtCommands.setProtocol(AtCommands.protocolCan11Bit500k);
    final protocolResult = await sendCommand(protocolCommand);
    if (protocolResult case Err(:final error)) return Err(error);
    if (protocolResult case Ok(:final value)) onStep?.call(protocolCommand, value);

    var probe = await sendCommand('0100');
    if (probe case Ok(:final value) when value is DataFrame) {
      onStep?.call('0100', value);
    } else {
      final autoCommand = AtCommands.setProtocol(AtCommands.protocolAuto);
      final fallback = await sendCommand(autoCommand);
      if (fallback case Err(:final error)) return Err(error);
      if (fallback case Ok(:final value)) onStep?.call(autoCommand, value);

      probe = await sendCommand('0100');
      if (probe case Err(:final error)) return Err(error);
      if (probe case Ok(value: ErrorFrame(:final error))) return Err(error);
      if (probe case Ok(:final value)) onStep?.call('0100', value);
    }

    final describeResult = await sendCommand(AtCommands.describeProtocol);
    if (describeResult case Ok(:final value)) onStep?.call(AtCommands.describeProtocol, value);

    final adaptiveResult = await sendCommand(AtCommands.adaptiveTimingOn);
    if (adaptiveResult case Ok(:final value)) onStep?.call(AtCommands.adaptiveTimingOn, value);

    final protocolDescription = switch (describeResult) {
      Ok(value: TextFrame(:final text)) => text,
      _ => 'Protocolo desconhecido',
    };
    return Ok(protocolDescription);
  }

  String _formatCommand(int mode, int pid) =>
      '${mode.toRadixString(16).padLeft(2, '0')}'
              '${pid.toRadixString(16).padLeft(2, '0')}'
          .toUpperCase();

  /// Consulta um PID do Modo 01 e devolve o valor já decodificado e
  /// validado contra a faixa física (§8).
  Future<Result<double, ObdError>> readPid(PidDefinition def) async {
    final cmd = _formatCommand(def.mode, def.pid);
    final result = await sendCommand(cmd);
    return switch (result) {
      Err(:final error) => Err(error),
      Ok(value: SearchingFrame()) =>
        const Err(AdapterError('SEARCHING...')),
      Ok(value: ErrorFrame(:final error)) => Err(error),
      Ok(value: TextFrame()) => Err(ParseError(cmd)),
      Ok(value: DataFrame(:final bytes)) => _decodePidResponse(def, bytes),
    };
  }

  Result<double, ObdError> _decodePidResponse(
    PidDefinition def,
    List<int> bytes,
  ) {
    final expectedHeader = 0x40 + def.mode;
    if (bytes.length < 2 || bytes[0] != expectedHeader || bytes[1] != def.pid) {
      return Err(ParseError(bytes.toString()));
    }
    return decodePidValue(def, bytes.sublist(2));
  }

  /// Lê os DTCs de um modo de serviço (03 armazenados, 07 pendentes, 0A
  /// permanentes — §9). Descarta o byte de contagem quando a resposta vem
  /// em CAN (comprimento ímpar depois do byte de modo — pares de DTC são
  /// sempre em número par de bytes; um byte a mais só pode ser a
  /// contagem).
  Future<Result<List<DtcCode>, ObdError>> readDtcs(int serviceMode) async {
    final cmd = serviceMode.toRadixString(16).padLeft(2, '0').toUpperCase();
    final result = await sendCommand(cmd);
    return switch (result) {
      Err(:final error) => Err(error),
      Ok(value: SearchingFrame()) =>
        const Err(AdapterError('SEARCHING...')),
      Ok(value: ErrorFrame(:final error)) => Err(error),
      Ok(value: TextFrame()) => Err(ParseError(cmd)),
      Ok(value: DataFrame(:final bytes)) =>
        _decodeDtcResponse(serviceMode, bytes),
    };
  }

  Result<List<DtcCode>, ObdError> _decodeDtcResponse(
    int serviceMode,
    List<int> bytes,
  ) {
    final expectedHeader = 0x40 + serviceMode;
    if (bytes.isEmpty || bytes[0] != expectedHeader) {
      return Err(ParseError(bytes.toString()));
    }
    var rest = bytes.sublist(1);
    if (rest.length.isOdd) {
      rest = rest.sublist(1); // byte de contagem CAN (§9)
    }
    return Ok(decodeDtcFrame(rest));
  }

  /// Lê o VIN (Modo 09, PID 02) — resposta sempre multi-frame (§7.3).
  Future<Result<String, ObdError>> readVin() async {
    final result = await sendCommand('0902');
    return switch (result) {
      Err(:final error) => Err(error),
      Ok(value: ErrorFrame(:final error)) => Err(error),
      Ok(value: DataFrame(:final bytes)) when bytes.length > 3 =>
        Ok(String.fromCharCodes(bytes.sublist(3))),
      _ => const Err(ParseError('0902')),
    };
  }

  /// Apaga os DTCs (Modo 04). A confirmação dupla e o aviso sobre reset
  /// dos monitores de emissão (§16) são responsabilidade da camada de UI
  /// — este método só envia o comando.
  Future<Result<void, ObdError>> clearDtcs() async {
    final result = await sendCommand('04');
    return switch (result) {
      Err(:final error) => Err(error),
      Ok(value: ErrorFrame(:final error)) => Err(error),
      _ => const Ok(null),
    };
  }
}
