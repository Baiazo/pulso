import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:pulso/core/errors.dart';
import 'package:pulso/core/result.dart';
import 'package:pulso/data/obd/dtc/dtc_decoder.dart';
import 'package:pulso/data/obd/elm327/elm327_client.dart';
import 'package:pulso/data/obd/elm327/elm327_commands.dart';
import 'package:pulso/data/obd/pids/pid_decoder.dart';
import 'package:pulso/data/obd/transport/mock/mock_vehicle.dart';
import 'package:pulso/data/obd/transport/mock_transport.dart';
import 'package:pulso/data/obd/transport/obd_transport.dart';

/// Transporte falso que só registra a ordem dos comandos escritos e
/// detecta se algum `write()` aconteceu enquanto o anterior ainda não
/// tinha sido respondido — é a violação que a fila serial do
/// [Elm327Client] existe para impedir (§7.2).
class _OrderTrackingTransport implements ObdTransport {
  final List<String> writes = [];
  final List<String> interleavingViolations = [];
  final _controller = StreamController<String>.broadcast();
  bool _outstanding = false;

  @override
  Stream<String> get incoming => _controller.stream;

  @override
  bool get isConnected => true;

  @override
  Future<Result<void, ObdError>> connect() async => const Ok(null);

  @override
  Future<void> dispose() async => _controller.close();

  @override
  Future<Result<void, ObdError>> write(String command) async {
    if (_outstanding) interleavingViolations.add(command);
    _outstanding = true;
    writes.add(command);
    Future.delayed(Duration(milliseconds: 2 + writes.length % 5), () {
      _outstanding = false;
      _controller.add('OK\r\r>');
    });
    return const Ok(null);
  }
}

void main() {
  group('fila serial — o teste mais importante da suíte (§7.2/§15)', () {
    test('50 requisições concorrentes saem uma a uma, em ordem, sem '
        'interleaving', () async {
      final transport = _OrderTrackingTransport();
      final client = Elm327Client(transport);
      final commands = List.generate(50, (i) => 'AT${i.toString().padLeft(2, '0')}');

      // dispara todas ao mesmo tempo, sem esperar uma terminar antes da
      // próxima — é exatamente o cenário que derruba um client sem fila
      final futures = commands.map(client.sendCommand).toList();
      final results = await Future.wait(futures);

      expect(transport.interleavingViolations, isEmpty);
      expect(transport.writes, commands);
      for (final r in results) {
        expect(r.isOk, isTrue);
      }
    });
  });

  group('handshake (§7.1) sobre o MockTransport', () {
    test('completa com sucesso e deixa o client pronto para consultar PIDs',
        () async {
      final transport = MockTransport();
      await transport.connect();
      final client = Elm327Client(transport);

      final handshakeResult = await client.handshake();
      expect(handshakeResult.isOk, isTrue);

      final def = findPidByKey('engine_rpm')!;
      final rpmResult = await client.readPid(def);
      expect(rpmResult.isOk, isTrue);
      expect(rpmResult.valueOrNull, closeTo(780, 80));
    });
  });

  group('leitura de PID — timeout e NO DATA', () {
    test('NO DATA não é tratado como erro fatal — vira NoDataError',
        () async {
      final transport = MockTransport();
      await transport.connect();
      final client = Elm327Client(transport);
      await client.handshake();

      transport.forceNoDataOnce();
      final def = findPidByKey('engine_rpm')!;
      final result = await client.readPid(def);
      expect(result.isErr, isTrue);
      expect(result.when(ok: (_) => null, err: (e) => e), isA<NoDataError>());
    });

    test('comando sem resposta expira dentro do timeout (RNF04)', () async {
      final transport = MockTransport();
      await transport.connect();
      final client = Elm327Client(transport);
      await client.handshake();

      transport.forceTimeoutOnce();
      final stopwatch = Stopwatch()..start();
      final result = await client.sendCommand(
        '010C',
        timeout: const Duration(milliseconds: 200),
      );
      stopwatch.stop();

      expect(result.isErr, isTrue);
      expect(result.when(ok: (_) => null, err: (e) => e), isA<TimeoutError>());
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
    });
  });

  group('DTCs e VIN sobre o MockTransport', () {
    test('readDtcs decodifica um DTC injetado no simulador', () async {
      final transport = MockTransport();
      await transport.connect();
      final client = Elm327Client(transport);
      await client.handshake();

      transport.injectDtc(decodeDtc(0x01, 0x33)); // P0133
      final result = await client.readDtcs(ObdServiceModes.storedDtcs);

      expect(result.isOk, isTrue);
      final codes = result.valueOrNull!.map((c) => c.code).toList();
      expect(codes, contains('P0133'));
    });

    test('clearDtcs esvazia a lista de DTCs armazenados', () async {
      final transport = MockTransport();
      await transport.connect();
      final client = Elm327Client(transport);
      await client.handshake();

      transport.injectDtc(decodeDtc(0x01, 0x33));
      final clearResult = await client.clearDtcs();
      expect(clearResult.isOk, isTrue);

      final afterClear = await client.readDtcs(ObdServiceModes.storedDtcs);
      expect(afterClear.valueOrNull, isEmpty);
    });

    test('readVin devolve o VIN de 17 caracteres do simulador', () async {
      final transport = MockTransport();
      await transport.connect();
      final client = Elm327Client(transport);
      await client.handshake();

      final result = await client.readVin();
      expect(result.isOk, isTrue);
      expect(result.valueOrNull, mockVin);
      expect(result.valueOrNull!.length, 17);
    });
  });
}
