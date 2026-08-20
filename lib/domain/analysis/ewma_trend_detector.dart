import 'zscore_detector.dart' show stdDevFloorFor;

/// Média móvel exponencial (§12.5) — pega a degradação lenta que a
/// anomalia pontual (§12.4) não pega: nenhuma leitura individual é
/// atípica, a média é que foi deslocando aos poucos.
class EwmaAccumulator {
  EwmaAccumulator({this.alpha = 0.05});

  final double alpha;
  double? _value;

  void update(double x) {
    final current = _value;
    _value = current == null ? x : alpha * x + (1 - alpha) * current;
  }

  /// `null` antes da primeira amostra.
  double? get value => _value;
}

/// `true` quando a EWMA da sessão se afastou da baseline por mais que
/// `factor` desvios padrão (§12.5: 1,5σ) — usa o mesmo piso de σ do
/// Z-score (§12.4), pela mesma razão: parâmetro quase constante não pode
/// gerar um σ artificialmente pequeno.
bool isTrendDeviated({
  required double ewma,
  required double baselineMean,
  required double baselineStdDev,
  required String pidKey,
  double factor = 1.5,
}) {
  final floor = stdDevFloorFor(pidKey);
  final effectiveStdDev = baselineStdDev < floor ? floor : baselineStdDev;
  return (ewma - baselineMean).abs() > factor * effectiveStdDev;
}
