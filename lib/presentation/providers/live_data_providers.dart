import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/analysis/anomaly_resolution.dart';
import '../../domain/entities/anomaly.dart';
import '../../domain/entities/baseline.dart';
import '../../domain/entities/enums.dart';
import '../../domain/entities/reading.dart';
import '../../domain/entities/session.dart';
import '../../domain/entities/vehicle.dart';
import 'active_session_controller.dart';
import 'app_providers.dart';

/// O único veículo do app na Fase 1 — sem seletor de veículo (§19), mas
/// as telas de histórico/veículo precisam de um `vehicleId` mesmo sem
/// sessão ativa (revisar viagens antigas desconectado, por exemplo).
final defaultVehicleIdProvider = FutureProvider<int?>((ref) async {
  final active = ref.watch(activeSessionProvider);
  if (active != null) return active.vehicleId;
  final vehicles = await ref.read(vehicleRepositoryProvider).all();
  return vehicles.isEmpty ? null : vehicles.first.id;
});

final defaultVehicleProvider = FutureProvider<Vehicle?>((ref) async {
  final id = await ref.watch(defaultVehicleIdProvider.future);
  if (id == null) return null;
  return ref.read(vehicleRepositoryProvider).byId(id);
});

/// Sessões de um veículo — fonte da tela de viagens (item 13, RF17).
final sessionsForVehicleProvider =
    StreamProvider.family<List<Session>, int>((ref, vehicleId) {
  return ref.watch(sessionRepositoryProvider).watchForVehicle(vehicleId);
});

/// Série completa de um PID numa sessão — fonte do gráfico de 30 min da
/// tela de detalhe do parâmetro (item 13, RF16).
final readingsForSessionProvider =
    StreamProvider.family<List<Reading>, ({int sessionId, String pidKey})>((ref, args) {
  return ref.watch(readingRepositoryProvider).watchForSession(
        args.sessionId,
        pidKey: args.pidKey,
      );
});

/// Última leitura de um PID numa sessão — reativo (painel ao vivo, RF15).
final latestReadingProvider =
    StreamProvider.family<Reading?, ({int sessionId, String pidKey})>((ref, args) {
  return ref.watch(readingRepositoryProvider).watchLatest(
        sessionId: args.sessionId,
        pidKey: args.pidKey,
      );
});

/// Baseline de um `(veículo, PID, contexto)` — fonte do "MÉD 88°".
final baselineProvider = StreamProvider.family<Baseline?,
    ({int vehicleId, String pidKey, OperatingContext contexto})>((ref, args) {
  return ref.watch(baselineRepositoryProvider).watch(
        vehicleId: args.vehicleId,
        pidKey: args.pidKey,
        contexto: args.contexto,
      );
});

/// Todas as anomalias de uma sessão — o painel deriva a severidade atual
/// de cada parâmetro olhando a mais recente aqui.
final sessionAnomaliesProvider =
    StreamProvider.family<List<Anomaly>, int>((ref, sessionId) {
  return ref.watch(anomalyRepositoryProvider).watchForSession(sessionId);
});

/// Alertas agrupados/classificados de um veículo inteiro — fonte da tela
/// de histórico (item 15, RF14/RF23). Deliberadamente um-tiro (`Future`),
/// não `.watch()`: é tela de histórico, não painel ao vivo, então não
/// precisa recalcular a cada leitura gravada. Não existe consulta
/// "todas as anomalias do veículo" no schema (§11 só indexa anomalias por
/// sessão) — busca as sessões do veículo e faz N+1 (`forSession` por
/// sessão), aceitável nos volumes da Fase 1; virar um JOIN fica pra quando
/// isso doer de verdade.
final vehicleAlertGroupsProvider =
    FutureProvider.family<List<AlertGroup>, int>((ref, vehicleId) async {
  final sessionRepo = ref.watch(sessionRepositoryProvider);
  final anomalyRepo = ref.watch(anomalyRepositoryProvider);

  final sessions = await sessionRepo.forVehicle(vehicleId);
  final anomalies = <Anomaly>[];
  for (final session in sessions) {
    final id = session.id;
    if (id == null) continue;
    anomalies.addAll(await anomalyRepo.forSession(id));
  }

  return groupAndClassifyAlerts(anomalies: anomalies, sessions: sessions);
});
