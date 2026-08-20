import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/enums.dart';
import '../../domain/entities/trend_watch.dart' as domain;
import '../db/database.dart' as db;

abstract class TrendWatchRepository {
  Future<domain.TrendWatch?> find({
    required int vehicleId,
    required String pidKey,
    required OperatingContext contexto,
  });

  Future<domain.TrendWatch> upsert({
    required int vehicleId,
    required String pidKey,
    required OperatingContext contexto,
    required int consecutiveDeviatedSessions,
    required int lastSessionId,
  });
}

class LocalTrendWatchRepository implements TrendWatchRepository {
  LocalTrendWatchRepository(this._db, {Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  final db.AppDatabase _db;
  final Uuid _uuid;

  domain.TrendWatch _toDomain(db.TrendWatch row) => domain.TrendWatch(
        id: row.id,
        uuid: row.uuid,
        syncedAt: row.syncedAt,
        vehicleId: row.vehicleId,
        pidKey: row.pidKey,
        contexto: OperatingContextJson.fromJsonValue(row.contexto),
        consecutiveDeviatedSessions: row.consecutiveDeviatedSessions,
        lastSessionId: row.lastSessionId,
      );

  @override
  Future<domain.TrendWatch?> find({
    required int vehicleId,
    required String pidKey,
    required OperatingContext contexto,
  }) async {
    final row = await (_db.select(_db.trendWatches)
          ..where((t) =>
              t.vehicleId.equals(vehicleId) &
              t.pidKey.equals(pidKey) &
              t.contexto.equals(contexto.jsonValue)))
        .getSingleOrNull();
    return row == null ? null : _toDomain(row);
  }

  @override
  Future<domain.TrendWatch> upsert({
    required int vehicleId,
    required String pidKey,
    required OperatingContext contexto,
    required int consecutiveDeviatedSessions,
    required int lastSessionId,
  }) async {
    final existing = await find(
      vehicleId: vehicleId,
      pidKey: pidKey,
      contexto: contexto,
    );

    if (existing == null) {
      final companion = db.TrendWatchesCompanion.insert(
        uuid: _uuid.v4(),
        vehicleId: vehicleId,
        pidKey: pidKey,
        contexto: contexto.jsonValue,
        consecutiveDeviatedSessions: Value(consecutiveDeviatedSessions),
        lastSessionId: Value(lastSessionId),
      );
      final id = await _db.into(_db.trendWatches).insert(companion);
      final row = await (_db.select(_db.trendWatches)
            ..where((t) => t.id.equals(id)))
          .getSingle();
      return _toDomain(row);
    }

    await (_db.update(_db.trendWatches)..where((t) => t.id.equals(existing.id!)))
        .write(
      db.TrendWatchesCompanion(
        consecutiveDeviatedSessions: Value(consecutiveDeviatedSessions),
        lastSessionId: Value(lastSessionId),
      ),
    );
    final row = await (_db.select(_db.trendWatches)
          ..where((t) => t.id.equals(existing.id!)))
        .getSingle();
    return _toDomain(row);
  }
}
