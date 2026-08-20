import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/obd/elm327/elm327_client.dart';
import '../../data/obd/pids/pid_definition.dart';
import '../../data/obd/pids/supported_pids.dart';
import '../../data/obd/sampling/sampling_scheduler.dart';
import '../../data/repositories/reading_repository.dart';
import '../../domain/analysis/analysis_engine.dart';
import '../../domain/entities/enums.dart';
import 'app_providers.dart';

/// Uma sessão de coleta em andamento, com o agendador já rodando — é o
/// que o painel ao vivo (item 12) observa pra saber o `sessionId` a
/// consultar nos repositórios reativos.
class ActiveSession {
  const ActiveSession({
    required this.vehicleId,
    required this.sessionId,
    required this.scheduler,
    required this.supportedCatalog,
  });

  final int vehicleId;
  final int sessionId;
  final SamplingScheduler scheduler;
  final List<PidDefinition> supportedCatalog;
}

final activeSessionProvider =
    NotifierProvider<ActiveSessionController, ActiveSession?>(ActiveSessionController.new);

/// Orquestra a ponta a ponta descrita no §17: descobre PIDs suportados
/// (item 6), abre a sessão (§11), liga o agendador (item 8) ao motor de
/// análise (item 10) via o hook `onReading` — nenhum dos dois precisa
/// conhecer o outro.
class ActiveSessionController extends Notifier<ActiveSession?> {
  // Espelham o que `state` carrega, em campos Dart puros: dentro de um
  // callback de onDispose não dá pra ler `state` nem usar `ref` (passa
  // pelo Ref, que recusa uso durante o próprio ciclo de dispose —
  // "Cannot use Ref or modify other providers inside life-cycles/selectors").
  SamplingScheduler? _runningScheduler;
  AnalysisEngine? _runningEngine;

  @override
  ActiveSession? build() {
    // Sem isso, o Timer.periodic do agendador (item 8) continua rodando
    // mesmo depois do provider ser descartado — vaza em produção e
    // derruba teste de widget com "Timer ainda pendente".
    ref.onDispose(() => _runningScheduler?.stop());
    return null;
  }

  Future<void> startFor(Elm327Client client, {required String protocolDescription}) async {
    final vehicleRepo = ref.read(vehicleRepositoryProvider);
    final sessionRepo = ref.read(sessionRepositoryProvider);
    final readingRepo = ref.read(readingRepositoryProvider);

    final vehicles = await vehicleRepo.all();
    final vehicle = vehicles.isNotEmpty
        ? vehicles.first
        : await vehicleRepo.create(
            vin: 'YV1MZ7B2XPB123456',
            apelido: 'Meu Volvo',
            modelo: 'V40 2019',
            ano: 2019,
            cilindradaL: 2.0,
            tipoCombustivel: FuelType.flex,
          );

    final discovery = await discoverSupportedPids(client);
    final supportedPids = discovery.valueOrNull ?? const <int>{};
    await vehicleRepo.updateSupportedPids(vehicle.id!, supportedPids.toList());
    final supportedCatalog = filterSupportedCatalog(supportedPids);

    final session = await sessionRepo.start(
      vehicleId: vehicle.id!,
      iniciadaEm: DateTime.now(),
      protocolo: protocolDescription,
      adaptador: 'ELM327',
      // Item 9 distingue real de simulado pelo tipo de transporte —
      // por enquanto só existe o simulado (MockTransport).
      origem: SessionOrigin.simulado,
    );

    final engine = AnalysisEngine(
      baselineRepository: ref.read(baselineRepositoryProvider),
      anomalyRepository: ref.read(anomalyRepositoryProvider),
      readingRepository: readingRepo,
      trendWatchRepository: ref.read(trendWatchRepositoryProvider),
    );
    _runningEngine = engine;

    final scheduler = SamplingScheduler(
      client: client,
      readingRepository: readingRepo,
      supportedCatalog: supportedCatalog,
      onReading: (reading) => engine.processReading(
        vehicleId: vehicle.id!,
        sessionId: session.id!,
        reading: reading,
      ),
    );
    scheduler.start(session.id!);
    _runningScheduler = scheduler;

    state = ActiveSession(
      vehicleId: vehicle.id!,
      sessionId: session.id!,
      scheduler: scheduler,
      supportedCatalog: supportedCatalog,
    );
  }

  Future<void> stop() async {
    final current = state;
    if (current == null) return;
    current.scheduler.stop();
    _runningScheduler = null;

    final readingRepo = ref.read(readingRepositoryProvider);

    // Tendência (§12.5) é avaliada ao fim da sessão, contra a EWMA de
    // tudo que foi observado — precisa acontecer antes da sessão fechar.
    await _runningEngine?.finalizeSession(
      vehicleId: current.vehicleId,
      sessionId: current.sessionId,
    );
    _runningEngine = null;

    final summary = await _computeTripSummary(readingRepo, current.sessionId);
    await ref.read(sessionRepositoryProvider).end(
          current.sessionId,
          encerradaEm: DateTime.now(),
          distanciaKm: summary.distanciaKm,
          consumoMedioKml: summary.consumoMedioKml,
        );
    state = null;
  }

  /// Distância por integração trapezoidal da velocidade ao longo do
  /// tempo, e consumo médio como a média simples das leituras de
  /// `consumo_kml` (§12.7) — não há odômetro nem PID de distância total
  /// acumulada confiável entre adaptadores, então isso é derivado das
  /// próprias leituras já gravadas.
  Future<({double? distanciaKm, double? consumoMedioKml})> _computeTripSummary(
    ReadingRepository readingRepo,
    int sessionId,
  ) async {
    final speedReadings = await readingRepo.forSession(sessionId, pidKey: 'vehicle_speed');
    var distanceKm = 0.0;
    for (var i = 1; i < speedReadings.length; i++) {
      final dtSeconds =
          speedReadings[i].ts.difference(speedReadings[i - 1].ts).inMilliseconds / 1000.0;
      final avgSpeedKmh = (speedReadings[i].valor + speedReadings[i - 1].valor) / 2;
      distanceKm += avgSpeedKmh * dtSeconds / 3600.0;
    }

    final consumptionReadings = await readingRepo.forSession(sessionId, pidKey: 'consumo_kml');
    double? avgConsumption;
    if (consumptionReadings.isNotEmpty) {
      final sum = consumptionReadings.fold<double>(0, (acc, r) => acc + r.valor);
      avgConsumption = sum / consumptionReadings.length;
    }

    return (
      distanciaKm: speedReadings.isEmpty ? null : distanceKm,
      consumoMedioKml: avgConsumption,
    );
  }
}
