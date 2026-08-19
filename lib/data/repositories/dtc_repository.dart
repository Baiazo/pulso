import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/dtc_event.dart' as domain;
import '../../domain/entities/enums.dart';
import '../db/database.dart' as db;

abstract class DtcRepository {
  Future<domain.DtcEvent> record({
    required int sessionId,
    required DateTime ts,
    required String codigo,
    required DtcEventType tipo,
    required String descricao,
    required Map<String, double> freezeFrame,
  });

  Future<List<domain.DtcEvent>> forSession(int sessionId);
  Stream<List<domain.DtcEvent>> watchForSession(int sessionId);
}

class LocalDtcRepository implements DtcRepository {
  LocalDtcRepository(this._db, {Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  final db.AppDatabase _db;
  final Uuid _uuid;

  domain.DtcEvent _toDomain(db.DtcEvent row) => domain.DtcEvent(
        id: row.id,
        uuid: row.uuid,
        syncedAt: row.syncedAt,
        sessionId: row.sessionId,
        ts: row.ts,
        codigo: row.codigo,
        tipo: DtcEventTypeJson.fromJsonValue(row.tipo),
        descricao: row.descricao,
        freezeFrame: row.freezeFrame,
      );

  @override
  Future<domain.DtcEvent> record({
    required int sessionId,
    required DateTime ts,
    required String codigo,
    required DtcEventType tipo,
    required String descricao,
    required Map<String, double> freezeFrame,
  }) async {
    final companion = db.DtcEventsCompanion.insert(
      uuid: _uuid.v4(),
      sessionId: sessionId,
      ts: ts,
      codigo: codigo,
      tipo: tipo.jsonValue,
      descricao: descricao,
      freezeFrame: Value(freezeFrame),
    );
    final id = await _db.into(_db.dtcEvents).insert(companion);
    final row = await (_db.select(_db.dtcEvents)
          ..where((t) => t.id.equals(id)))
        .getSingle();
    return _toDomain(row);
  }

  @override
  Future<List<domain.DtcEvent>> forSession(int sessionId) async {
    final rows = await (_db.select(_db.dtcEvents)
          ..where((t) => t.sessionId.equals(sessionId))
          ..orderBy([(t) => OrderingTerm.asc(t.ts)]))
        .get();
    return rows.map(_toDomain).toList();
  }

  @override
  Stream<List<domain.DtcEvent>> watchForSession(int sessionId) {
    final query = _db.select(_db.dtcEvents)
      ..where((t) => t.sessionId.equals(sessionId))
      ..orderBy([(t) => OrderingTerm.asc(t.ts)]);
    return query.watch().map((rows) => rows.map(_toDomain).toList());
  }
}
