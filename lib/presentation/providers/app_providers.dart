import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/database.dart';
import '../../data/repositories/anomaly_repository.dart';
import '../../data/repositories/baseline_repository.dart';
import '../../data/repositories/dtc_repository.dart';
import '../../data/repositories/raw_frame_repository.dart';
import '../../data/repositories/reading_repository.dart';
import '../../data/repositories/session_repository.dart';
import '../../data/repositories/trend_watch_repository.dart';
import '../../data/repositories/vehicle_repository.dart';

/// Uma única instância de banco por app — repositórios são leves e
/// recriados sob demanda a partir dela (§2.1: repositório atrás de
/// interface, aqui a implementação local).
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final vehicleRepositoryProvider = Provider<VehicleRepository>(
  (ref) => LocalVehicleRepository(ref.watch(databaseProvider)),
);

final sessionRepositoryProvider = Provider<SessionRepository>(
  (ref) => LocalSessionRepository(ref.watch(databaseProvider)),
);

final readingRepositoryProvider = Provider<ReadingRepository>(
  (ref) => LocalReadingRepository(ref.watch(databaseProvider)),
);

final baselineRepositoryProvider = Provider<BaselineRepository>(
  (ref) => LocalBaselineRepository(ref.watch(databaseProvider)),
);

final anomalyRepositoryProvider = Provider<AnomalyRepository>(
  (ref) => LocalAnomalyRepository(ref.watch(databaseProvider)),
);

final trendWatchRepositoryProvider = Provider<TrendWatchRepository>(
  (ref) => LocalTrendWatchRepository(ref.watch(databaseProvider)),
);

final dtcRepositoryProvider = Provider<DtcRepository>(
  (ref) => LocalDtcRepository(ref.watch(databaseProvider)),
);

final rawFrameRepositoryProvider = Provider<RawFrameRepository>(
  (ref) => LocalRawFrameRepository(ref.watch(databaseProvider)),
);
