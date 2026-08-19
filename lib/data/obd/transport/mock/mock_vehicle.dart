import 'dart:math' as math;

import '../../dtc/dtc_decoder.dart';

/// Cenários de condução do simulador (§13). Cada um muda a física do
/// veículo, não só os valores exibidos — é o que permite testar a
/// detecção de anomalia (RF12/RF13) sem depender de um carro real.
enum MockProfile {
  normal,
  urbano,
  rodovia,
  superaquecimento,
  falhaSensorO2,
  bateriaFraca,
  dtcAtivo,
}

/// Estado físico do veículo simulado no instante `t` (segundos desde a
/// partida do motor). Funções puras de `t` e do perfil — dado o mesmo par
/// `(t, profile)`, sempre o mesmo resultado, o que torna os testes de
/// integração determinísticos mesmo com um relógio real por trás (§13).
class MockVehicle {
  MockVehicle({this.profile = MockProfile.normal});

  final MockProfile profile;

  static const double _ambientC = 22;
  static const double _idleRpm = 780;

  double _clamp(double v, double lo, double hi) => v < lo ? lo : (v > hi ? hi : v);

  /// Velocidade alvo (km/h) do ciclo de condução em `t`.
  double speedKmh(double t) {
    switch (profile) {
      case MockProfile.normal:
      case MockProfile.superaquecimento:
      case MockProfile.bateriaFraca:
      case MockProfile.dtcAtivo:
        return 0; // parado, motor ligado — ideal para contexto parado_*
      case MockProfile.urbano:
      case MockProfile.falhaSensorO2:
        final v = 27 + 27 * math.sin(2 * math.pi * t / 90) +
            8 * math.sin(2 * math.pi * t / 17);
        return _clamp(v, 0, 58);
      case MockProfile.rodovia:
        return _clamp(100 + 15 * math.sin(2 * math.pi * t / 120), 70, 130);
    }
  }

  double throttlePct(double t) {
    final speed = speedKmh(t);
    if (speed <= 0.5) return 8 + 2 * math.sin(t / 3.7).abs();
    final blip = 40 * math.sin(2 * math.pi * t / 23).abs();
    return _clamp(15 + blip, 0, 100);
  }

  double engineRpm(double t) {
    final speed = speedKmh(t);
    if (speed <= 0.5) {
      return _idleRpm + 15 * math.sin(t / 2.9);
    }
    return _clamp(900 + speed * 18 + throttlePct(t) * 3, _idleRpm, 6500);
  }

  double engineLoadPct(double t) => _clamp(throttlePct(t) * 0.8 + 12, 0, 100);

  double throttlePosition(double t) => throttlePct(t);

  /// Temperatura de arrefecimento (°C): sobe de forma assintótica desde a
  /// ambiente até o alvo — modelo de aquecimento a frio do §13. O perfil
  /// `superaquecimento` usa alvo e constante de tempo maiores, simulando
  /// falha de arrefecimento em vez de estabilizar em ~90 °C.
  double coolantTempC(double t) {
    final isOverheating = profile == MockProfile.superaquecimento;
    final target = isOverheating ? 128.0 : 90.0;
    final tau = isOverheating ? 260.0 : 300.0;
    return target - (target - _ambientC) * math.exp(-t / tau);
  }

  double intakeAirTempC(double t) => _ambientC + 8 + 2 * math.sin(t / 41);

  double ambientAirTempC(double t) => _ambientC + 0.5 * math.sin(t / 97);

  double intakeMapKpa(double t) => _clamp(30 + throttlePct(t) * 0.65, 20, 100);

  double mafRateGs(double t) {
    final rpm = engineRpm(t);
    final map = intakeMapKpa(t);
    return _clamp((rpm / 1000) * (map / 100) * 9, 1.5, 220);
  }

  double fuelLevelPct(double t) => _clamp(72 - t * 0.0008, 0, 100);

  double controlModuleVoltage(double t) {
    final base = profile == MockProfile.bateriaFraca ? 11.8 : 14.2;
    return base + 0.05 * math.sin(t / 5);
  }

  bool get _o2Faulted => profile == MockProfile.falhaSensorO2;

  double shortFuelTrim1Pct(double t) =>
      _o2Faulted ? _clamp(15 * math.sin(t / 3), -100, 99) : 1.5 * math.sin(t / 19);

  double longFuelTrim1Pct(double t) =>
      _o2Faulted ? _clamp(10 * math.cos(t / 4), -100, 99) : 1.0 * math.cos(t / 23);

  double commandedEquivRatio(double t) =>
      _o2Faulted ? _clamp(1.0 + 0.3 * math.sin(t / 2.5), 0, 2) : 1.0 + 0.02 * math.sin(t / 11);

  double timingAdvanceDeg(double t) =>
      _clamp(10 + (engineRpm(t) - _idleRpm) / 100, -10, 40);

  double barometricPressureKpa(double t) => 90.0;

  double engineOilTempC(double t) => math.max(_ambientC, coolantTempC(t) - 3);

  double catalystTempC(double t) => 420 - (420 - _ambientC) * math.exp(-t / 90);

  double runTimeSinceStartS(double t) => t;

  double distanceWithMilKm(double t) {
    if (!milOn) return 0;
    return t / 3600 * 35; // aproximação de velocidade média com MIL acesa
  }

  double absoluteLoadPct(double t) => _clamp(engineLoadPct(t) + 4, 0, 100);

  double fuelPressureKpa(double t) => _clamp(300 + engineRpm(t) * 0.05, 0, 765);

  double fuelRateLh(double t) {
    // Mesmo fator de conversão da gasolina comum brasileira do §12.6 (E27),
    // aplicado sobre o MAF simulado — mantém o simulador consistente com o
    // estimador de consumo do motor de análise.
    return mafRateGs(t) * 3600 * 0.364 / 1000;
  }

  bool get milOn =>
      profile == MockProfile.dtcAtivo || profile == MockProfile.falhaSensorO2;
}

/// Um DTC armazenado no simulador, com o freeze frame do instante em que
/// foi "detectado".
class StoredDtc {
  const StoredDtc({
    required this.code,
    required this.freezeFrame,
    this.pending = false,
    this.permanent = false,
  });

  final DtcCode code;
  final Map<String, double> freezeFrame;
  final bool pending;
  final bool permanent;
}

/// VIN de referência do simulador — 17 caracteres, não corresponde a um
/// veículo real (usado só para exercitar o parser multi-frame ISO-TP do
/// §7.3; o dígito verificador não foi calculado).
const String mockVin = 'YV1MZ7B2XPB123456';
