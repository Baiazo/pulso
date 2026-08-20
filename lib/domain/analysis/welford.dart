import 'dart:math' as math;

/// Algoritmo de Welford (§12.3) — média e variância incrementais, O(1) por
/// amostra, numericamente estável mesmo com muitas amostras de média alta
/// e variância baixa (onde a fórmula ingênua de soma-de-quadrados perde
/// precisão). Não recarrega o histórico inteiro a cada leitura.
class WelfordAccumulator {
  WelfordAccumulator({this.n = 0, this.mean = 0, this.m2 = 0});

  /// Recomeça a partir do estado persistido na tabela `baselines` (§11) —
  /// nunca a partir da lista de amostras, que não é guardada.
  factory WelfordAccumulator.fromState({
    required int n,
    required double mean,
    required double m2,
  }) =>
      WelfordAccumulator(n: n, mean: mean, m2: m2);

  int n;
  double mean;
  double m2;

  void update(double x) {
    n += 1;
    final delta = x - mean;
    mean += delta / n;
    m2 += delta * (x - mean); // usa a média JÁ atualizada
  }

  double get variance => n < 2 ? 0 : m2 / (n - 1);

  double get stdDev {
    final v = variance;
    return v <= 0 ? 0 : math.sqrt(v);
  }
}
