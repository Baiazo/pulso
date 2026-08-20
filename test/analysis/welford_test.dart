import 'package:flutter_test/flutter_test.dart';
import 'package:pulso/domain/analysis/welford.dart';

void main() {
  group('WelfordAccumulator — contra valores conhecidos (§15)', () {
    test('média e variância amostral batem com o cálculo direto', () {
      // 2, 4, 4, 4, 5, 5, 7, 9 -> média 5, variância amostral 32/7
      const values = [2.0, 4.0, 4.0, 4.0, 5.0, 5.0, 7.0, 9.0];
      final w = WelfordAccumulator();
      for (final v in values) {
        w.update(v);
      }

      expect(w.n, values.length);
      expect(w.mean, closeTo(5.0, 1e-9));
      expect(w.variance, closeTo(32 / 7, 1e-9));
      expect(w.stdDev, closeTo(2.1380899, 1e-6));
    });

    test('n=0 e n=1 não têm variância definida (retorna 0, não NaN/infinito)',
        () {
      final w = WelfordAccumulator();
      expect(w.variance, 0);
      expect(w.stdDev, 0);

      w.update(42);
      expect(w.n, 1);
      expect(w.mean, 42);
      expect(w.variance, 0);
    });

    test('WelfordAccumulator.fromState retoma o estado persistido e '
        'continua acumulando corretamente', () {
      // Estado equivalente a já ter processado [2,4,4,4] antes de retomar.
      final partial = WelfordAccumulator()
        ..update(2)
        ..update(4)
        ..update(4)
        ..update(4);

      final resumed = WelfordAccumulator.fromState(
        n: partial.n,
        mean: partial.mean,
        m2: partial.m2,
      );
      for (final v in [5.0, 5.0, 7.0, 9.0]) {
        resumed.update(v);
      }

      expect(resumed.n, 8);
      expect(resumed.mean, closeTo(5.0, 1e-9));
      expect(resumed.variance, closeTo(32 / 7, 1e-9));
    });

    test('estabilidade com 100 mil amostras de média alta e variância baixa '
        '(§15) — é onde o cálculo ingênuo de soma-de-quadrados quebra', () {
      final w = WelfordAccumulator();
      const base = 1000000.0; // média alta
      // variância baixa: ruído pequeno e determinístico em torno da base
      for (var i = 0; i < 100000; i++) {
        final noise = (i % 7) * 0.001 - 0.003; // amplitude minúscula
        w.update(base + noise);
      }

      expect(w.n, 100000);
      expect(w.mean, closeTo(base, 1e-3));
      // variância tem que ficar minúscula e, acima de tudo, não-negativa —
      // o sintoma clássico da fórmula ingênua nesse regime é dar negativo
      // por cancelamento catastrófico.
      expect(w.variance, greaterThanOrEqualTo(0));
      expect(w.variance, lessThan(0.01));
    });
  });
}
