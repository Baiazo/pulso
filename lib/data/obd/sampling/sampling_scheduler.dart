import 'dart:async';

import '../../../domain/analysis/context_classifier.dart';
import '../../../domain/entities/reading.dart';
import '../../repositories/reading_repository.dart';
import '../elm327/elm327_client.dart';
import '../pids/pid_definition.dart';

/// Rodízio por prioridade (§10) — nunca mantém lista própria de PIDs: lê
/// `PidDefinition.priority` do catálogo já restrito aos PIDs suportados
/// (item 6), então incluir um parâmetro novo no catálogo nunca fica
/// esquecido no agendamento.
///
/// `sobDemanda` fica fora do rodízio regular — é acionado por ação do
/// usuário ou início/fim de sessão (§10), não por este ciclo.
class SamplingScheduler {
  SamplingScheduler({
    required this._client,
    required this._readingRepository,
    required List<PidDefinition> supportedCatalog,
    this.cycleInterval = const Duration(milliseconds: 200),
    this.onReading,
  }) : _catalog = supportedCatalog;

  final Elm327Client _client;
  final ReadingRepository _readingRepository;
  final List<PidDefinition> _catalog;
  final Duration cycleInterval;

  /// Chamado depois de cada leitura persistida — é o que alimenta o
  /// motor de análise (item 10) sem o agendador precisar conhecê-lo;
  /// quem monta o app decide o que fazer com cada leitura.
  final Future<void> Function(Reading reading)? onReading;

  Timer? _timer;
  int? _sessionId;
  int _cycle = 0;

  double _lastKnownSpeedKmh = 0;
  double _lastKnownCoolantTempC = 90;

  final Map<String, int> _sampleCounts = {};
  final Map<String, DateTime> _firstSampleAt = {};

  bool get isRunning => _sessionId != null;

  /// Taxa efetiva medida por PID (§10: "a resposta precisa ser medida, não
  /// estimada") — amostras / tempo decorrido desde a primeira amostra
  /// daquele PID nesta sessão.
  Map<String, double> effectiveHzByPid({DateTime Function()? now}) {
    final clock = now ?? DateTime.now;
    final result = <String, double>{};
    for (final entry in _sampleCounts.entries) {
      final firstAt = _firstSampleAt[entry.key];
      if (firstAt == null) continue;
      final elapsedS = clock().difference(firstAt).inMilliseconds / 1000.0;
      result[entry.key] = elapsedS <= 0 ? 0 : entry.value / elapsedS;
    }
    return result;
  }

  /// Associa uma sessão sem armar o `Timer` — usado em teste, onde os
  /// ciclos são disparados manualmente via [tick] (determinístico, sem
  /// depender de relógio real).
  void attachSession(int sessionId) {
    _sessionId = sessionId;
    _cycle = 0;
    _sampleCounts.clear();
    _firstSampleAt.clear();
  }

  void start(int sessionId) {
    attachSession(sessionId);
    _timer?.cancel();
    _timer = Timer.periodic(cycleInterval, (_) => tick());
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    _sessionId = null;
  }

  List<PidDefinition> _duePidsForCycle(int cycle) {
    final due = <PidDefinition>[];
    for (final def in _catalog) {
      switch (def.priority) {
        case SamplingPriority.alta:
          due.add(def);
        case SamplingPriority.media:
          if (cycle % 5 == 0) due.add(def);
        case SamplingPriority.baixa:
          if (cycle % 30 == 0) due.add(def);
        case SamplingPriority.sobDemanda:
          break;
      }
    }
    return due;
  }

  bool _tickInProgress = false;

  /// Um ciclo do rodízio. Público para que os testes disparem ciclos sem
  /// depender de `Timer` real — a lógica é a mesma que o `Timer.periodic`
  /// de [start] chama.
  ///
  /// Reentrância guardada: `Timer.periodic` não espera o callback anterior
  /// terminar, e o ciclo inteiro (todos os PIDs `alta` + o que mais
  /// vencer) pode legitimamente demorar mais que `cycleInterval` — sem a
  /// guarda, dois ciclos correndo ao mesmo tempo disputam `_cycle` e
  /// produzem contagem errada (foi exatamente o bug encontrado ao testar
  /// isso com 35 ciclos).
  Future<void> tick() async {
    if (_tickInProgress) return;
    final sessionId = _sessionId;
    if (sessionId == null) return;

    _tickInProgress = true;
    try {
      await _runCycle(sessionId);
    } finally {
      _tickInProgress = false;
    }
  }

  Future<void> _runCycle(int sessionId) async {
    final duePids = _duePidsForCycle(_cycle);
    _cycle++;

    for (final def in duePids) {
      final result = await _client.readPid(def);
      final value = result.valueOrNull;
      if (value == null) continue; // NO DATA/timeout — não persiste, ciclo segue

      if (def.key == 'vehicle_speed') _lastKnownSpeedKmh = value;
      if (def.key == 'coolant_temp') _lastKnownCoolantTempC = value;

      final contexto = classifyContext(
        speedKmh: _lastKnownSpeedKmh,
        coolantTempC: _lastKnownCoolantTempC,
      );

      final reading = await _readingRepository.record(
        sessionId: sessionId,
        ts: DateTime.now(),
        pidKey: def.key,
        valor: value,
        contexto: contexto,
      );
      await onReading?.call(reading);

      _sampleCounts.update(def.key, (n) => n + 1, ifAbsent: () => 1);
      _firstSampleAt.putIfAbsent(def.key, DateTime.now);
    }
  }
}
