import 'package:flutter_test/flutter_test.dart';
import 'package:pulso/data/obd/dtc/dtc_catalog.dart';
import 'package:pulso/data/obd/dtc/dtc_decoder.dart';

void main() {
  group('decodeDtc — os seis vetores do §9', () {
    final cases = <List<int>, String>{
      [0x01, 0x33]: 'P0133',
      [0x04, 0x20]: 'P0420',
      [0x41, 0x71]: 'C0171',
      [0x81, 0x00]: 'B0100',
      [0xC1, 0x23]: 'U0123',
      [0x01, 0x71]: 'P0171',
    };

    cases.forEach((bytes, expected) {
      test('${bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join()} '
          '-> $expected', () {
        final dtc = decodeDtc(bytes[0], bytes[1]);
        expect(dtc.code, expected);
      });
    });

    test('primeiro dígito indica código genérico vs específico do fabricante',
        () {
      expect(decodeDtc(0x01, 0x33).isManufacturerSpecific, isFalse);
      expect(decodeDtc(0x11, 0x33).isManufacturerSpecific, isTrue);
      expect(decodeDtc(0x11, 0x33).code, 'P1133');
    });

    test('os 4 sistemas (P/C/B/U) são decodificados pelos 2 bits altos de A',
        () {
      expect(decodeDtc(0x00, 0x00).system, DtcSystem.powertrain);
      expect(decodeDtc(0x40, 0x00).system, DtcSystem.chassis);
      expect(decodeDtc(0x80, 0x00).system, DtcSystem.body);
      expect(decodeDtc(0xC0, 0x00).system, DtcSystem.network);
    });
  });

  group('isDtcPadding / decodeDtcFrame', () {
    test('0000 é reconhecido como preenchimento, não como P0000', () {
      expect(isDtcPadding(0x00, 0x00), isTrue);
      expect(isDtcPadding(0x01, 0x33), isFalse);
    });

    test('decodeDtcFrame descarta os pares 0000 de um frame com contagem',
        () {
      // Resposta CAN com byte de contagem já removido pelo chamador:
      // 2 DTCs reais seguidos de 1 slot de preenchimento.
      final frame = [0x01, 0x33, 0x04, 0x20, 0x00, 0x00];
      final codes = decodeDtcFrame(frame).map((c) => c.code).toList();
      expect(codes, ['P0133', 'P0420']);
    });

    test('decodeDtcFrame com frame vazio não decodifica nada', () {
      expect(decodeDtcFrame(const []), isEmpty);
    });

    test('decodeDtcFrame com só preenchimento retorna lista vazia', () {
      expect(decodeDtcFrame([0x00, 0x00, 0x00, 0x00]), isEmpty);
    });
  });

  group('describeDtc', () {
    test('código genérico catalogado retorna a descrição em português', () {
      final dtc = decodeDtc(0x01, 0x33); // P0133
      expect(describeDtc(dtc), contains('Sonda lambda'));
    });

    test('código específico do fabricante nunca tem descrição inventada',
        () {
      final dtc = decodeDtc(0x11, 0x33); // P1133
      expect(describeDtc(dtc), manufacturerSpecificNote);
    });

    test('código genérico fora do catálogo usa a nota de não documentado',
        () {
      final dtc = decodeDtc(0x0F, 0xFF); // P0FFF, não cadastrado
      expect(describeDtc(dtc), undocumentedGenericNote);
    });
  });
}
