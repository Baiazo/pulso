import 'package:flutter_test/flutter_test.dart';
import 'package:pulso/domain/analysis/ewma_trend_detector.dart';

void main() {
  group('EwmaAccumulator (§12.5)', () {
    test('null antes da primeira amostra', () {
      expect(EwmaAccumulator().value, isNull);
    });

    test('primeira amostra vira o valor inicial', () {
      final ewma = EwmaAccumulator()..update(100);
      expect(ewma.value, 100);
    });

    test('amostras seguintes usam a fórmula α·x + (1−α)·anterior', () {
      final ewma = EwmaAccumulator(alpha: 0.05)
        ..update(100)
        ..update(110);
      expect(ewma.value, closeTo(0.05 * 110 + 0.95 * 100, 1e-9));
    });

    test('converge lentamente para um novo patamar (é o ponto do α baixo)',
        () {
      final ewma = EwmaAccumulator(alpha: 0.05);
      ewma.update(90); // patamar antigo
      for (var i = 0; i < 200; i++) {
        ewma.update(120); // novo patamar sustentado
      }
      expect(ewma.value, closeTo(120, 0.1));
    });
  });

  group('isTrendDeviated (§12.5)', () {
    test('dentro de 1,5σ não é desvio', () {
      final deviated = isTrendDeviated(
        ewma: 91,
        baselineMean: 90,
        baselineStdDev: 2,
        pidKey: 'coolant_temp',
      );
      expect(deviated, isFalse);
    });

    test('além de 1,5σ é desvio', () {
      final deviated = isTrendDeviated(
        ewma: 94,
        baselineMean: 90,
        baselineStdDev: 2,
        pidKey: 'coolant_temp',
      );
      expect(deviated, isTrue);
    });

    test('usa o piso de σ do §12.4 — parâmetro quase constante não gera '
        'falso positivo por σ artificialmente pequeno', () {
      final deviated = isTrendDeviated(
        ewma: 14.25,
        baselineMean: 14.2,
        baselineStdDev: 0.001,
        pidKey: 'control_module_voltage',
      );
      // piso de tensão é 0,15: 1,5×0,15 = 0,225 > |14.25-14.2| = 0.05
      expect(deviated, isFalse);
    });
  });
}
