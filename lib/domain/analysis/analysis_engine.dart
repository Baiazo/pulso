import '../../data/repositories/anomaly_repository.dart';
import '../../data/repositories/baseline_repository.dart';
import '../../data/repositories/reading_repository.dart';
import '../../data/repositories/trend_watch_repository.dart';
import '../entities/enums.dart';
import '../entities/reading.dart';
import 'ewma_trend_detector.dart';
import 'fuel_estimator.dart';
import 'welford.dart';
import 'zscore_detector.dart';

/// Limiares configuráveis do motor de análise — os valores default são os
/// do §12.4/§12.5.
class AnalysisThresholds {
  const AnalysisThresholds({
    this.attention = 3.0,
    this.serious = 4.0,
    this.critical = 6.0,
    this.trendFactor = 1.5,
    this.trendSustainedSessions = 3,
  });

  final double attention;
  final double serious;
  final double critical;
  final double trendFactor;
  final int trendSustainedSessions;
}

/// Orquestra Welford (§12.3), Z-score (§12.4), EWMA/tendência (§12.5) e
/// consumo como parâmetro de primeira classe (§12.6/§12.7) sobre as
/// leituras de uma sessão.
///
/// Depende das interfaces de repositório (data/repositories/), não de
/// implementação concreta nem de Flutter — continua testável sem
/// framework (§2.1, regra 3), só a fonte de persistência é trocável.
class AnalysisEngine {
  AnalysisEngine({
    required this._baselineRepository,
    required this._anomalyRepository,
    required this._readingRepository,
    required this._trendWatchRepository,
    DebounceTracker? debounceTracker,
    this.thresholds = const AnalysisThresholds(),
  }) : _debounce = debounceTracker ?? DebounceTracker();

  final BaselineRepository _baselineRepository;
  final AnomalyRepository _anomalyRepository;
  final ReadingRepository _readingRepository;
  final TrendWatchRepository _trendWatchRepository;
  final DebounceTracker _debounce;
  final AnalysisThresholds thresholds;

  double? _lastSpeedKmh;

  /// Avalia uma leitura contra a baseline de `(pid_key, contexto)`:
  /// registra anomalia pontual se o debounce confirmar (§12.4, guarda 3),
  /// e só alimenta a baseline (Welford) se a própria leitura não for
  /// atípica — senão o "normal" absorve o defeito e o alerta desaparece
  /// sozinho (§12.5).
  Future<void> processReading({
    required int vehicleId,
    required int sessionId,
    required Reading reading,
  }) async {
    if (reading.pidKey == 'vehicle_speed') _lastSpeedKmh = reading.valor;

    final existing = await _baselineRepository.find(
      vehicleId: vehicleId,
      pidKey: reading.pidKey,
      contexto: reading.contexto,
    );

    final zResult = computeZScore(
      value: reading.valor,
      n: existing?.n ?? 0,
      mean: existing?.media ?? 0,
      stdDev: existing?.stdDev ?? 0,
      pidKey: reading.pidKey,
    );

    final exceeded = zResult.exceedsThreshold(thresholds.attention);
    final shouldAlert = _debounce.registerAndCheck(
      debounceKey(reading.pidKey, reading.contexto),
      exceededThreshold: exceeded,
    );

    if (exceeded && shouldAlert) {
      final severity = severityFor(
        zResult.z.abs(),
        attentionThreshold: thresholds.attention,
        seriousThreshold: thresholds.serious,
        criticalThreshold: thresholds.critical,
      )!;
      await _anomalyRepository.record(
        sessionId: sessionId,
        ts: reading.ts,
        pidKey: reading.pidKey,
        contexto: reading.contexto,
        valor: reading.valor,
        mediaEsperada: existing?.media ?? 0,
        desvioPadrao: existing?.stdDev ?? 0,
        z: zResult.z,
        severidade: severity,
        tipo: AnomalyType.pontual,
      );
    }

    if (!exceeded) {
      final welford = existing == null
          ? WelfordAccumulator()
          : WelfordAccumulator.fromState(
              n: existing.n,
              mean: existing.media,
              m2: existing.m2,
            );
      welford.update(reading.valor);
      await _baselineRepository.upsert(
        vehicleId: vehicleId,
        pidKey: reading.pidKey,
        contexto: reading.contexto,
        n: welford.n,
        media: welford.mean,
        m2: welford.m2,
        atualizadoEm: reading.ts,
      );
    }

    // Eficiência como parâmetro de primeira classe (§12.7): consumo_lh e
    // consumo_kml entram no MESMO pipeline de baseline/Z-score/EWMA que
    // qualquer PID lido do veículo.
    if (reading.pidKey == 'fuel_rate') {
      await _processFuelDerived(
        vehicleId: vehicleId,
        sessionId: sessionId,
        ts: reading.ts,
        contexto: reading.contexto,
        fuelRateLh: reading.valor,
      );
    }
  }

  Future<void> _processFuelDerived({
    required int vehicleId,
    required int sessionId,
    required DateTime ts,
    required OperatingContext contexto,
    required double fuelRateLh,
  }) async {
    final lhReading = await _readingRepository.record(
      sessionId: sessionId,
      ts: ts,
      pidKey: 'consumo_lh',
      valor: fuelRateLh,
      contexto: contexto,
    );
    await processReading(
      vehicleId: vehicleId,
      sessionId: sessionId,
      reading: lhReading,
    );

    final speed = _lastSpeedKmh;
    if (speed == null) return;
    final kml = fuelEconomyKmL(speedKmh: speed, fuelRateLh: fuelRateLh);
    if (kml == null) return; // parado — indefinido (§12.6), não persiste

    final kmlReading = await _readingRepository.record(
      sessionId: sessionId,
      ts: ts,
      pidKey: 'consumo_kml',
      valor: kml,
      contexto: contexto,
    );
    await processReading(
      vehicleId: vehicleId,
      sessionId: sessionId,
      reading: kmlReading,
    );
  }

  /// Fim de sessão (§12.5): compara a EWMA de cada `(pid_key, contexto)`
  /// observado na sessão contra a baseline, e registra uma anomalia do
  /// tipo `tendencia` quando o desvio se sustenta por
  /// `thresholds.trendSustainedSessions` sessões seguidas.
  Future<void> finalizeSession({
    required int vehicleId,
    required int sessionId,
  }) async {
    final readings = await _readingRepository.forSession(sessionId);
    final grouped = <String, List<Reading>>{};
    for (final reading in readings) {
      grouped
          .putIfAbsent(debounceKey(reading.pidKey, reading.contexto), () => [])
          .add(reading);
    }

    for (final group in grouped.values) {
      final pidKey = group.first.pidKey;
      final contexto = group.first.contexto;

      final baseline = await _baselineRepository.find(
        vehicleId: vehicleId,
        pidKey: pidKey,
        contexto: contexto,
      );
      if (baseline == null || baseline.n < minSamplesForEvaluation) continue;

      final ewma = EwmaAccumulator();
      for (final reading in group) {
        ewma.update(reading.valor);
      }
      final ewmaValue = ewma.value;
      if (ewmaValue == null) continue;

      final deviated = isTrendDeviated(
        ewma: ewmaValue,
        baselineMean: baseline.media,
        baselineStdDev: baseline.stdDev,
        pidKey: pidKey,
        factor: thresholds.trendFactor,
      );

      final watch = await _trendWatchRepository.find(
        vehicleId: vehicleId,
        pidKey: pidKey,
        contexto: contexto,
      );
      final streak = deviated ? (watch?.consecutiveDeviatedSessions ?? 0) + 1 : 0;

      if (streak >= thresholds.trendSustainedSessions) {
        final z = baseline.stdDev == 0
            ? 0.0
            : (ewmaValue - baseline.media) / baseline.stdDev;
        await _anomalyRepository.record(
          sessionId: sessionId,
          ts: group.last.ts,
          pidKey: pidKey,
          contexto: contexto,
          valor: ewmaValue,
          mediaEsperada: baseline.media,
          desvioPadrao: baseline.stdDev,
          z: z,
          severidade: AnomalySeverity.atencao,
          tipo: AnomalyType.tendencia,
        );
        await _trendWatchRepository.upsert(
          vehicleId: vehicleId,
          pidKey: pidKey,
          contexto: contexto,
          consecutiveDeviatedSessions: 0,
          lastSessionId: sessionId,
        );
      } else {
        await _trendWatchRepository.upsert(
          vehicleId: vehicleId,
          pidKey: pidKey,
          contexto: contexto,
          consecutiveDeviatedSessions: streak,
          lastSessionId: sessionId,
        );
      }
    }
  }
}
