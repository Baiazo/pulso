import 'package:flutter_test/flutter_test.dart';
import 'package:pulso/domain/analysis/context_classifier.dart';
import 'package:pulso/domain/entities/enums.dart';

void main() {
  group('classifyContext (§12.2) — fronteiras', () {
    test('velocidade 0 e ECT abaixo de 70 -> parado_frio', () {
      expect(
        classifyContext(speedKmh: 0, coolantTempC: 69.9),
        OperatingContext.paradoFrio,
      );
    });

    test('velocidade 0 e ECT exatamente 70 -> parado_quente (>=)', () {
      expect(
        classifyContext(speedKmh: 0, coolantTempC: 70),
        OperatingContext.paradoQuente,
      );
    });

    test('velocidade negativa (ruído de sensor) tratada como parada', () {
      expect(
        classifyContext(speedKmh: -0.5, coolantTempC: 90),
        OperatingContext.paradoQuente,
      );
    });

    test('velocidade > 0 até 60 -> urbano', () {
      expect(classifyContext(speedKmh: 0.1, coolantTempC: 90), OperatingContext.urbano);
      expect(classifyContext(speedKmh: 60, coolantTempC: 90), OperatingContext.urbano);
    });

    test('velocidade acima de 60 -> rodovia', () {
      expect(
        classifyContext(speedKmh: 60.1, coolantTempC: 90),
        OperatingContext.rodovia,
      );
    });
  });
}
