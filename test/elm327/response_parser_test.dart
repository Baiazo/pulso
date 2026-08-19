import 'package:flutter_test/flutter_test.dart';
import 'package:pulso/core/errors.dart';
import 'package:pulso/data/obd/elm327/response_parser.dart';

void main() {
  group('parseResponse — dado (Modo 01–0A)', () {
    test('linha simples, sem eco, sem cabeçalho (§7.3)', () {
      final frame = parseResponse('410C1AF8\r\r>', isAtCommand: false);
      expect(frame, isA<DataFrame>());
      expect((frame as DataFrame).bytes, [0x41, 0x0C, 0x1A, 0xF8]);
    });

    test('remove o eco do comando quando o eco está ligado', () {
      final frame = parseResponse(
        '010C\r410C1AF8\r\r>',
        isAtCommand: false,
        echoedCommand: '010C',
      );
      expect((frame as DataFrame).bytes, [0x41, 0x0C, 0x1A, 0xF8]);
    });

    test('remove o cabeçalho CAN quando ATH1 está ligado', () {
      final frame = parseResponse(
        '7E8 410C1AF8\r\r>',
        isAtCommand: false,
        headersEnabled: true,
      );
      expect((frame as DataFrame).bytes, [0x41, 0x0C, 0x1A, 0xF8]);
    });

    test('espaços entre bytes (ATS1) não atrapalham o parsing', () {
      final frame = parseResponse('41 0C 1A F8\r\r>', isAtCommand: false);
      expect((frame as DataFrame).bytes, [0x41, 0x0C, 0x1A, 0xF8]);
    });

    test('multi-frame ISO-TP reagrupa o VIN do exemplo do §7.3', () {
      final raw = '014\r0:490201314434\r1:47503030523535\r2:42313233343536\r\r>';
      final frame = parseResponse(raw, isAtCommand: false);
      expect(frame, isA<DataFrame>());
      final bytes = (frame as DataFrame).bytes;
      expect(bytes.length, 20);
      final vin = String.fromCharCodes(bytes.sublist(3));
      expect(vin.length, 17);
    });
  });

  group('parseResponse — texto (comando AT)', () {
    test('resposta de ATZ não é tratada como hexadecimal', () {
      final frame = parseResponse('ELM327 v1.5\r\r>', isAtCommand: true);
      expect(frame, isA<TextFrame>());
      expect((frame as TextFrame).text, 'ELM327 v1.5');
    });

    test('OK', () {
      final frame = parseResponse(
        'ATE0\rOK\r\r>',
        isAtCommand: true,
        echoedCommand: 'ATE0',
      );
      expect((frame as TextFrame).text, 'OK');
    });
  });

  group('parseResponse — erros do §7.4', () {
    for (final token in [
      'NO DATA',
      'UNABLE TO CONNECT',
      'BUS INIT: ERROR',
      'BUS BUSY',
      'CAN ERROR',
      'DATA ERROR',
      'STOPPED',
      'BUFFER FULL',
      'ERROR',
      '?',
    ]) {
      test('"$token" é reconhecido como erro', () {
        final frame = parseResponse('$token\r\r>', isAtCommand: false);
        expect(frame, isA<ErrorFrame>());
        final error = (frame as ErrorFrame).error;
        if (token == 'NO DATA') {
          expect(error, isA<NoDataError>());
        } else {
          expect(error, isA<AdapterError>());
        }
      });
    }

    test('SEARCHING... é transitório, não erro nem dado', () {
      final frame = parseResponse('SEARCHING...\r\r>', isAtCommand: false);
      expect(frame, isA<SearchingFrame>());
    });

    test('lixo/truncado vira ParseError, não exceção', () {
      final frame = parseResponse('41G@1AF\r\r>', isAtCommand: false);
      expect(frame, isA<ErrorFrame>());
      expect((frame as ErrorFrame).error, isA<ParseError>());
    });

    test('multi-frame com menos bytes do que o comprimento declarado vira '
        'ParseError', () {
      final frame = parseResponse('014\r0:490201314434\r\r>', isAtCommand: false);
      expect(frame, isA<ErrorFrame>());
    });
  });

  group('hasCompletePrompt', () {
    test('falso enquanto o prompt não chegou', () {
      expect(hasCompletePrompt('410C1AF8'), isFalse);
    });

    test('verdadeiro quando o prompt está no buffer', () {
      expect(hasCompletePrompt('410C1AF8\r\r>'), isTrue);
    });
  });
}
