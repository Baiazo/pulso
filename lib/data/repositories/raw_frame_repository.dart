import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/raw_frame.dart' as domain;
import '../db/database.dart' as db;

/// Gravada só com o modo de validação ligado (RF22) — evidência bruta
/// para a seção 5.7 do TCC.
abstract class RawFrameRepository {
  Future<domain.RawFrame> record({
    required int sessionId,
    required DateTime ts,
    required String comando,
    required String respostaBruta,
  });

  Future<List<domain.RawFrame>> forSession(int sessionId);
}

class LocalRawFrameRepository implements RawFrameRepository {
  LocalRawFrameRepository(this._db, {Uuid? uuid})
      : _uuid = uuid ?? const Uuid();

  final db.AppDatabase _db;
  final Uuid _uuid;

  domain.RawFrame _toDomain(db.RawFrame row) => domain.RawFrame(
        id: row.id,
        uuid: row.uuid,
        syncedAt: row.syncedAt,
        sessionId: row.sessionId,
        ts: row.ts,
        comando: row.comando,
        respostaBruta: row.respostaBruta,
      );

  @override
  Future<domain.RawFrame> record({
    required int sessionId,
    required DateTime ts,
    required String comando,
    required String respostaBruta,
  }) async {
    final companion = db.RawFramesCompanion.insert(
      uuid: _uuid.v4(),
      sessionId: sessionId,
      ts: ts,
      comando: comando,
      respostaBruta: respostaBruta,
    );
    final id = await _db.into(_db.rawFrames).insert(companion);
    final row = await (_db.select(_db.rawFrames)
          ..where((t) => t.id.equals(id)))
        .getSingle();
    return _toDomain(row);
  }

  @override
  Future<List<domain.RawFrame>> forSession(int sessionId) async {
    final rows = await (_db.select(_db.rawFrames)
          ..where((t) => t.sessionId.equals(sessionId))
          ..orderBy([(t) => OrderingTerm.asc(t.ts)]))
        .get();
    return rows.map(_toDomain).toList();
  }
}
