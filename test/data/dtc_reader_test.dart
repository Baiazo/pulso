import 'package:flutter_test/flutter_test.dart';
import 'package:pulso/data/obd/dtc/dtc_decoder.dart';
import 'package:pulso/data/obd/dtc/dtc_reader.dart';
import 'package:pulso/data/obd/elm327/elm327_client.dart';
import 'package:pulso/data/obd/transport/mock_transport.dart';

void main() {
  group('readAllDtcs (item 14, §9)', () {
    test('lê os três modos e devolve o DTC injetado entre os ativos', () async {
      final transport = MockTransport();
      await transport.connect();
      final client = Elm327Client(transport);
      await client.handshake();
      transport.injectDtc(decodeDtc(0x01, 0x33)); // P0133

      final result = await readAllDtcs(client);

      expect(result.isOk, isTrue);
      final all = result.valueOrNull!;
      expect(all.ativos.map((c) => c.code), contains('P0133'));
      expect(all.pendentes, isEmpty);
      expect(all.permanentes, isEmpty);
      expect(all.isEmpty, isFalse);
    });

    test('sem nenhum DTC guardado, devolve as três listas vazias', () async {
      final transport = MockTransport();
      await transport.connect();
      final client = Elm327Client(transport);
      await client.handshake();

      final result = await readAllDtcs(client);

      expect(result.isOk, isTrue);
      expect(result.valueOrNull!.isEmpty, isTrue);
    });
  });

  group('readFreezeFrameSnapshot (Modo 02, §10: sob demanda)', () {
    test('lê rotação/velocidade/motor/carga do freeze frame injetado',
        () async {
      final transport = MockTransport();
      await transport.connect();
      final client = Elm327Client(transport);
      await client.handshake();

      transport.injectDtc(
        decodeDtc(0x01, 0x33),
        freezeFrame: const {
          'engine_rpm': 2380,
          'vehicle_speed': 78,
          'coolant_temp': 91,
          'engine_load': 46,
        },
      );

      final snapshot = await readFreezeFrameSnapshot(client);

      expect(snapshot['engine_rpm'], closeTo(2380, 5));
      expect(snapshot['vehicle_speed'], closeTo(78, 1));
      expect(snapshot['coolant_temp'], closeTo(91, 1));
      expect(snapshot['engine_load'], closeTo(46, 1));
    });

    test('sem DTC guardado, devolve snapshot vazio em vez de falhar',
        () async {
      final transport = MockTransport();
      await transport.connect();
      final client = Elm327Client(transport);
      await client.handshake();

      final snapshot = await readFreezeFrameSnapshot(client);

      expect(snapshot, isEmpty);
    });
  });
}
