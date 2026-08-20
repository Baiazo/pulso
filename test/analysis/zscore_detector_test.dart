import 'package:flutter_test/flutter_test.dart';
import 'package:pulso/domain/analysis/zscore_detector.dart';
import 'package:pulso/domain/entities/enums.dart';

void main() {
  group('computeZScore — guarda 1: amostras mínimas (§12.4)', () {
    test('n < 100 não avalia, mesmo com valor claramente atípico', () {
      final result = computeZScore(
        value: 5000,
        n: 99,
        mean: 780,
        stdDev: 20,
        pidKey: 'engine_rpm',
      );
      expect(result.evaluated, isFalse);
    });

    test('n >= 100 avalia normalmente', () {
      final result = computeZScore(
        value: 5000,
        n: 100,
        mean: 780,
        stdDev: 20,
        pidKey: 'engine_rpm',
      );
      expect(result.evaluated, isTrue);
    });
  });

  group('computeZScore — guarda 2: piso de desvio padrão (§12.4)', () {
    test('desvio padrão real abaixo do piso é substituído pelo piso, '
        'evitando Z-score infinito', () {
      final result = computeZScore(
        value: 14.3, // tensão da bateria, motor parado
        n: 500,
        mean: 14.2,
        stdDev: 0.001, // quase zero — sem piso, isso explodiria o Z
        pidKey: 'control_module_voltage',
      );
      expect(result.evaluated, isTrue);
      // piso de tensão é 0,15 (§12.4): z = (14.3-14.2)/0.15 = 0.666...
      expect(result.z, closeTo(0.1 / 0.15, 1e-9));
      expect(result.z.isFinite, isTrue);
    });

    test('desvio padrão real acima do piso é usado normalmente', () {
      final result = computeZScore(
        value: 900,
        n: 500,
        mean: 780,
        stdDev: 40, // bem acima do piso de RPM (25)
        pidKey: 'engine_rpm',
      );
      expect(result.z, closeTo((900 - 780) / 40, 1e-9));
    });

    test('PID sem piso explícito no §12.4 usa o piso genérico', () {
      final result = computeZScore(
        value: 1.02,
        n: 500,
        mean: 1.0,
        stdDev: 0.0,
        pidKey: 'commanded_equiv_ratio',
      );
      expect(result.z, closeTo(0.02 / defaultStdDevFloor, 1e-9));
    });
  });

  group('severityFor — faixas do §12.4', () {
    test('abaixo de 3 não é anomalia', () {
      expect(severityFor(2.9), isNull);
    });

    test('3 <= |z| < 4 -> atenção', () {
      expect(severityFor(3.0), AnomalySeverity.atencao);
      expect(severityFor(3.9), AnomalySeverity.atencao);
    });

    test('4 <= |z| < 6 -> sério', () {
      expect(severityFor(4.0), AnomalySeverity.serio);
      expect(severityFor(5.9), AnomalySeverity.serio);
    });

    test('|z| >= 6 -> crítico', () {
      expect(severityFor(6.0), AnomalySeverity.critico);
      expect(severityFor(50), AnomalySeverity.critico);
    });
  });

  group('DebounceTracker — guarda 3: 5 de 10 (§12.4)', () {
    test('um pico isolado não dispara alerta', () {
      final tracker = DebounceTracker();
      const key = 'coolant_temp|rodovia';

      var alerted = tracker.registerAndCheck(key, exceededThreshold: true);
      expect(alerted, isFalse);

      for (var i = 0; i < 9; i++) {
        alerted = tracker.registerAndCheck(key, exceededThreshold: false);
      }
      expect(alerted, isFalse);
    });

    test('5 excedências dentro da janela de 10 dispara o alerta', () {
      final tracker = DebounceTracker();
      const key = 'coolant_temp|rodovia';

      var alerted = false;
      for (var i = 0; i < 5; i++) {
        alerted = tracker.registerAndCheck(key, exceededThreshold: true);
      }
      expect(alerted, isTrue);
    });

    test('a janela desliza — excedência antiga sai depois de 10 amostras',
        () {
      final tracker = DebounceTracker();
      const key = 'coolant_temp|rodovia';

      // 5 excedências consecutivas -> dispara (janela com exatamente 5/10)
      for (var i = 0; i < 5; i++) {
        tracker.registerAndCheck(key, exceededThreshold: true);
      }
      // a janela já está cheia (10 posições); a 6ª amostra normal empurra
      // a 1ª excedência pra fora, derrubando a contagem pra 4/10
      var alerted = false;
      for (var i = 0; i < 6; i++) {
        alerted = tracker.registerAndCheck(key, exceededThreshold: false);
      }
      expect(alerted, isFalse);
    });

    test('chaves diferentes (pid/contexto) têm janelas independentes', () {
      final tracker = DebounceTracker();
      for (var i = 0; i < 5; i++) {
        tracker.registerAndCheck('coolant_temp|rodovia', exceededThreshold: true);
      }
      final otherAlerted = tracker.registerAndCheck(
        'coolant_temp|urbano',
        exceededThreshold: true,
      );
      expect(otherAlerted, isFalse);
    });
  });

  group('debounceKey', () {
    test('combina pid e contexto', () {
      expect(
        debounceKey('coolant_temp', OperatingContext.rodovia),
        'coolant_temp|rodovia',
      );
    });
  });
}
