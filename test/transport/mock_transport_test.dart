import 'package:flutter_test/flutter_test.dart';
import 'package:pulso/data/obd/dtc/dtc_decoder.dart';
import 'package:pulso/data/obd/transport/mock/mock_vehicle.dart';
import 'package:pulso/data/obd/transport/mock_transport.dart';

/// Envia um comando e aguarda o primeiro pedaço de resposta do stream.
Future<String> _send(MockTransport t, String cmd) async {
  final future = t.incoming.first.timeout(const Duration(seconds: 2));
  final result = await t.write(cmd);
  expect(result.isOk, isTrue);
  return future;
}

/// Deixa o transporte em modo "limpo" (sem eco, sem linefeed, sem espaço)
/// — como o Elm327Client deixa depois do handshake do §7.1.
Future<void> _cleanHandshake(MockTransport t) async {
  await t.connect();
  await _send(t, 'ATZ');
  await _send(t, 'ATE0');
  await _send(t, 'ATL0');
  await _send(t, 'ATS0');
}

void main() {
  group('handshake (§7.1)', () {
    test('ATZ responde ELM327 v1.5', () async {
      final t = MockTransport();
      await t.connect();
      final resp = await _send(t, 'ATZ');
      expect(resp, contains('ELM327 v1.5'));
    });

    test('ATE0/ATL0/ATS0/ATH0 respondem OK', () async {
      final t = MockTransport();
      await t.connect();
      await _send(t, 'ATZ');
      for (final cmd in ['ATE0', 'ATL0', 'ATS0', 'ATH0']) {
        final resp = await _send(t, cmd);
        expect(resp, contains('OK'), reason: cmd);
      }
    });

    test('0100 depois do handshake responde bitmap de PIDs suportados',
        () async {
      final t = MockTransport();
      await _cleanHandshake(t);
      final resp = await _send(t, '0100');
      expect(resp, startsWith('4100'));
    });

    test('ATH1 liga o cabeçalho CAN nas respostas (modo de validação, RF22)',
        () async {
      final t = MockTransport();
      await _cleanHandshake(t);
      await _send(t, 'ATH1');
      final resp = await _send(t, '010C');
      expect(resp, startsWith('7E8 410C'));
    });

    test('ATDP confirma o protocolo negociado', () async {
      final t = MockTransport();
      await t.connect();
      await _send(t, 'ATZ');
      final resp = await _send(t, 'ATDP');
      expect(resp, contains('CAN'));
    });
  });

  group('descoberta de PIDs suportados (§7.5) — bitmaps', () {
    Future<int> bitmapOf(MockTransport t, String cmd) async {
      final resp = await _send(t, cmd);
      final hex = resp.replaceAll(RegExp(r'[\r\n>]'), '');
      return int.parse(hex.substring(4, 12), radix: 16);
    }

    bool bitFor(int bitmap, int offset) => (bitmap >> (32 - offset)) & 1 == 1;

    test('0100: bit do RPM (PID 0x0C, offset 12) ligado', () async {
      final t = MockTransport();
      await _cleanHandshake(t);
      final bitmap = await bitmapOf(t, '0100');
      expect(bitFor(bitmap, 0x0C), isTrue);
    });

    test('0100: bit de continuação (offset 32) ligado — há PID além de 0x20',
        () async {
      final t = MockTransport();
      await _cleanHandshake(t);
      final bitmap = await bitmapOf(t, '0100');
      expect(bitFor(bitmap, 32), isTrue);
    });

    test('0140: bit do fuel_rate (PID 0x5E, offset 0x1E) ligado, e bit de '
        'continuação desligado — não há PID além de 0x60 no catálogo',
        () async {
      final t = MockTransport();
      await _cleanHandshake(t);
      final bitmap = await bitmapOf(t, '0140');
      expect(bitFor(bitmap, 0x5E - 0x40), isTrue);
      expect(bitFor(bitmap, 32), isFalse);
    });
  });

  group('eco (§7.2) — comando some do texto só depois do ATE0', () {
    test('antes do ATE0, a resposta vem precedida do comando', () async {
      final t = MockTransport();
      await t.connect();
      final resp = await _send(t, 'ATE0');
      expect(resp, startsWith('ATE0'));
    });

    test('depois do ATE0, sem eco', () async {
      final t = MockTransport();
      await t.connect();
      await _send(t, 'ATZ');
      await _send(t, 'ATE0');
      final resp = await _send(t, '010C');
      expect(resp, isNot(contains('010C')));
    });
  });

  group('consulta de PID (Modo 01)', () {
    test('010C (RPM) em marcha lenta fica perto de 780 rpm', () async {
      final t = MockTransport();
      await _cleanHandshake(t);
      final resp = await _send(t, '010C');
      expect(resp, startsWith('410C'));
      final hex = resp.replaceAll(RegExp(r'[\r\n>]'), '');
      final bytes = [
        int.parse(hex.substring(4, 6), radix: 16),
        int.parse(hex.substring(6, 8), radix: 16),
      ];
      final rpm = (256 * bytes[0] + bytes[1]) / 4;
      expect(rpm, closeTo(780, 60));
    });

    test('forceNoDataOnce faz a próxima consulta responder NO DATA',
        () async {
      final t = MockTransport();
      await _cleanHandshake(t);
      t.forceNoDataOnce();
      final resp = await _send(t, '010C');
      expect(resp, contains('NO DATA'));

      // só afeta UMA consulta
      final resp2 = await _send(t, '010C');
      expect(resp2, isNot(contains('NO DATA')));
    });

    test('PID não suportado no catálogo responde NO DATA', () async {
      final t = MockTransport();
      await _cleanHandshake(t);
      final resp = await _send(t, '01FF');
      expect(resp, contains('NO DATA'));
    });
  });

  group('falhas de comunicação (§13, RNF04)', () {
    test('forceTimeoutOnce não gera nenhuma resposta', () async {
      final t = MockTransport();
      await _cleanHandshake(t);
      t.forceTimeoutOnce();
      await t.write('010C');
      final gotResponse = await t.incoming.first
          .timeout(
            const Duration(milliseconds: 300),
            onTimeout: () => '__TIMEOUT__',
          );
      expect(gotResponse, '__TIMEOUT__');
    });

    test('simulateDisconnect faz write() falhar', () async {
      final t = MockTransport();
      await _cleanHandshake(t);
      t.simulateDisconnect();
      final result = await t.write('010C');
      expect(result.isErr, isTrue);
      expect(t.isConnected, isFalse);
    });
  });

  group('DTCs (Modos 03/04) e VIN (Modo 09)', () {
    test('DTC injetado aparece na resposta do Modo 03 e decodifica de volta',
        () async {
      final t = MockTransport(profile: MockProfile.normal);
      await _cleanHandshake(t);
      t.injectDtc(decodeDtc(0x01, 0x33)); // P0133

      final resp = await _send(t, '03');
      final hex = resp.replaceAll(RegExp(r'[\r\n>]'), '');
      // 43 = resposta do Modo 03; próximo byte = contagem (CAN, §9)
      expect(hex.substring(0, 2), '43');
      final count = int.parse(hex.substring(2, 4), radix: 16);
      expect(count, 1);
      final a = int.parse(hex.substring(4, 6), radix: 16);
      final b = int.parse(hex.substring(6, 8), radix: 16);
      expect(decodeDtc(a, b).code, 'P0133');
    });

    test('Modo 04 limpa os DTCs armazenados', () async {
      final t = MockTransport();
      await _cleanHandshake(t);
      t.injectDtc(decodeDtc(0x01, 0x33));

      await _send(t, '04');
      final resp = await _send(t, '03');
      final hex = resp.replaceAll(RegExp(r'[\r\n>]'), '');
      expect(int.parse(hex.substring(2, 4), radix: 16), 0);
    });

    test('perfil dtcAtivo já nasce com MIL acesa e um DTC armazenado',
        () async {
      final t = MockTransport(profile: MockProfile.dtcAtivo);
      await _cleanHandshake(t);
      final resp = await _send(t, '0101');
      final hex = resp.replaceAll(RegExp(r'[\r\n>]'), '');
      final a = int.parse(hex.substring(4, 6), radix: 16);
      expect((a & 0x80) != 0, isTrue, reason: 'MIL deveria estar acesa');
    });

    test('0902 retorna o VIN em multi-frame ISO-TP com 17 caracteres',
        () async {
      final t = MockTransport();
      await _cleanHandshake(t);
      final resp = await _send(t, '0902');

      final lines = resp.split('\r').where((l) => l.isNotEmpty && l != '>').toList();
      // primeira linha: comprimento total; demais: "N:hex..."
      final dataHex = lines.skip(1).map((l) => l.split(':')[1]).join();
      final bytes = <int>[];
      for (var i = 0; i < dataHex.length; i += 2) {
        bytes.add(int.parse(dataHex.substring(i, i + 2), radix: 16));
      }
      final vinBytes = bytes.skip(3).toList(); // descarta 49 02 01
      final vin = String.fromCharCodes(vinBytes);
      expect(vin.length, 17);
    });
  });
}
