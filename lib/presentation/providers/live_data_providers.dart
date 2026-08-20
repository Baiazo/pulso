import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/anomaly.dart';
import '../../domain/entities/baseline.dart';
import '../../domain/entities/enums.dart';
import '../../domain/entities/reading.dart';
import 'app_providers.dart';

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
