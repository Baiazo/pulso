import 'dart:collection';

import '../entities/enums.dart';

/// Amostras mínimas antes de avaliar (§12.4, guarda 1) — com poucas
/// amostras, σ é uma estimativa ruim.
const int minSamplesForEvaluation = 100;

/// Pisos de desvio padrão por PID (§12.4, guarda 2) — sem isso, um
/// parâmetro quase constante (ex.: tensão com o motor parado) gera σ≈0 e
/// qualquer flutuação de leitura vira Z-score infinito.
const Map<String, double> stdDevFloors = {
  'engine_rpm': 25,
  'vehicle_speed': 1.0,
  'coolant_temp': 0.8,
  'throttle_position': 1.0,
  'engine_load': 1.5,
  'control_module_voltage': 0.15,
  'maf_rate': 0.5,
};

/// Piso genérico para PIDs sem piso explícito no §12.4 — o documento só
/// lista 7; sem isso, os demais parâmetros ficariam sem guarda nenhuma.
const double defaultStdDevFloor = 0.05;

double stdDevFloorFor(String pidKey) => stdDevFloors[pidKey] ?? defaultStdDevFloor;

/// Resultado de avaliar uma leitura contra a baseline. `evaluated = false`
/// quando ainda não há amostras suficientes ("perfil em construção" na
/// interface) — nesse caso `z` não tem significado.
class ZScoreResult {
  const ZScoreResult({required this.z, required this.evaluated});

  final double z;
  final bool evaluated;

  bool exceedsThreshold(double threshold) => evaluated && z.abs() > threshold;
}

/// `z = (x − μ) / σ`, com as guardas 1 e 2 do §12.4 já aplicadas.
ZScoreResult computeZScore({
  required double value,
  required int n,
  required double mean,
  required double stdDev,
  required String pidKey,
}) {
  if (n < minSamplesForEvaluation) {
    return const ZScoreResult(z: 0, evaluated: false);
  }
  final floor = stdDevFloorFor(pidKey);
  final effectiveStdDev = stdDev < floor ? floor : stdDev;
  return ZScoreResult(z: (value - mean) / effectiveStdDev, evaluated: true);
}

/// Severidade por faixa de |z| (§12.4). `null` quando abaixo do limiar de
/// atenção — não é anomalia.
AnomalySeverity? severityFor(
  double absZ, {
  double attentionThreshold = 3.0,
  double seriousThreshold = 4.0,
  double criticalThreshold = 6.0,
}) {
  if (absZ >= criticalThreshold) return AnomalySeverity.critico;
  if (absZ >= seriousThreshold) return AnomalySeverity.serio;
  if (absZ >= attentionThreshold) return AnomalySeverity.atencao;
  return null;
}

/// Guarda 3 do §12.4: só alerta o usuário depois de 5 amostras com |z| >
/// limiar dentro de uma janela das últimas 10 — um pico isolado é ruído de
/// comunicação, não anomalia mecânica.
///
/// Importante: essa guarda decide só se o usuário É AVISADO. Se uma
/// leitura pontual excede o limiar, ela continua fora da baseline (§12.5)
/// mesmo que o debounce não dispare o alerta — um blip isolado não deve
/// contaminar a média mesmo que não vire notificação.
class DebounceTracker {
  static const windowSize = 10;
  static const requiredFlags = 5;

  final Map<String, Queue<bool>> _windows = {};

  /// Registra se a amostra atual excedeu o limiar e devolve `true` quando
  /// a janela já acumulou amostras suficientes para alertar.
  bool registerAndCheck(String key, {required bool exceededThreshold}) {
    final window = _windows.putIfAbsent(key, Queue<bool>.new);
    window.addLast(exceededThreshold);
    if (window.length > windowSize) window.removeFirst();
    return window.where((flagged) => flagged).length >= requiredFlags;
  }

  void reset(String key) => _windows.remove(key);
}

/// Chave composta `(pidKey, contexto)` usada pelo [DebounceTracker] — a
/// baseline é por contexto (§12.2), então o debounce também precisa ser.
String debounceKey(String pidKey, OperatingContext contexto) =>
    '$pidKey|${contexto.name}';
