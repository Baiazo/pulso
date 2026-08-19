import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:pulso/core/errors.dart';
import 'package:pulso/core/result.dart';
import 'package:pulso/data/obd/elm327/elm327_client.dart';
import 'package:pulso/data/obd/pids/pid_catalog.dart';
import 'package:pulso/data/obd/pids/supported_pids.dart';
import 'package:pulso/data/obd/transport/mock_transport.dart';
import 'package:pulso/data/obd/transport/obd_transport.dart';

/// Encaminha tudo para um [MockTransport], só contando quantas vezes cada
/// comando `01XX` de bitmap foi escrito — para provar que a descoberta
/// para assim que o bit de continuação vem desligado, em vez de sempre
/// consultar os 4 blocos possíveis.
class _CountingTransport implements ObdTransport {
  _CountingTransport(this._inner);
  final MockTransport _inner;
  final List<String> bitmapWrites = [];

  @override
  Stream<String> get incoming => _inner.incoming;
  @override
  bool get isConnected => _inner.isConnected;
  @override
  Future<Result<void, ObdError>> connect() => _inner.connect();
  @override
  Future<void> dispose() => _inner.dispose();

  @override
  Future<Result<void, ObdError>> write(String command) {
    if (RegExp(r'^01(00|20|40|60)$').hasMatch(command.toUpperCase())) {
      bitmapWrites.add(command.toUpperCase());
    }
    return _inner.write(command);
  }
}

void main() {
  group('discoverSupportedPids (§7.5)', () {
    test('descobre exatamente o conjunto de PIDs do catálogo + PID 01',
        () async {
      final mock = MockTransport();
      await mock.connect();
      final transport = _CountingTransport(mock);
      final client = Elm327Client(transport);
      await client.handshake();

      final result = await discoverSupportedPids(client);
      expect(result.isOk, isTrue);

      final expected = {0x01, ...pidCatalog.map((d) => d.pid)};
      expect(result.valueOrNull, expected);
    });

    test('para na descoberta assim que o bloco não sinaliza continuação — '
        'não consulta 0160 sem necessidade', () async {
      final mock = MockTransport();
      await mock.connect();
      final transport = _CountingTransport(mock);
      final client = Elm327Client(transport);
      await client.handshake();
      transport.bitmapWrites.clear(); // handshake já manda um 0100 de sonda (§7.1)

      await discoverSupportedPids(client);

      // catálogo vai até 0x5E (bloco 0140) — não deveria haver PID além
      // de 0x60, então 0160 não deveria ser consultado.
      expect(transport.bitmapWrites, ['0100', '0120', '0140']);
    });
  });

  group('filterSupportedCatalog', () {
    test('restringe o catálogo ao conjunto suportado', () {
      final restricted = filterSupportedCatalog({0x0C, 0x0D});
      expect(restricted.map((d) => d.key), ['engine_rpm', 'vehicle_speed']);
    });

    test('conjunto vazio produz catálogo vazio', () {
      expect(filterSupportedCatalog(const {}), isEmpty);
    });
  });
}
