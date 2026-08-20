import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/obd/elm327/elm327_client.dart';
import '../../data/obd/pids/pid_definition.dart';
import '../../data/obd/pids/supported_pids.dart';
import '../../data/obd/sampling/sampling_scheduler.dart';
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
  // Espelha `state?.scheduler` em campo Dart puro: dentro de um callback
  // de onDispose não dá pra ler `state` (o getter passa pelo Ref, que
  // recusa uso durante o próprio ciclo de dispose — "Cannot use Ref or
  // modify other providers inside life-cycles/selectors").
  SamplingScheduler? _runningScheduler;

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
    await ref.read(sessionRepositoryProvider).end(
          current.sessionId,
          encerradaEm: DateTime.now(),
        );
    state = null;
  }
}
