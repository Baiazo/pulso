import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/enums.dart';
import '../../domain/entities/reading.dart' as domain;
import '../db/database.dart' as db;

abstract class ReadingRepository {
  Future<domain.Reading> record({
    required int sessionId,
    required DateTime ts,
    required String pidKey,
    required double valor,
    required OperatingContext contexto,
  });

  Future<List<domain.Reading>> forSession(int sessionId, {String? pidKey});

  /// Fonte do painel ao vivo (RF15) e dos gráficos (RF16) — reativo,
  /// porque a tela precisa atualizar sozinha conforme chega leitura nova.
  Stream<List<domain.Reading>> watchForSession(int sessionId, {String? pidKey});

  /// Só a leitura mais recente de um PID — o painel ao vivo observa isso
  /// por parâmetro em vez de carregar a lista inteira da sessão, que só
  /// cresce (§11: `readings` é a tabela que mais cresce).
  Stream<domain.Reading?> watchLatest({required int sessionId, required String pidKey});
}

class LocalReadingRepository implements ReadingRepository {
  LocalReadingRepository(this._db, {Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  final db.AppDatabase _db;
  final Uuid _uuid;

  domain.Reading _toDomain(db.Reading row) => domain.Reading(
        id: row.id,
        uuid: row.uuid,
        syncedAt: row.syncedAt,
        sessionId: row.sessionId,
        ts: row.ts,
        pidKey: row.pidKey,
        valor: row.valor,
        contexto: OperatingContextJson.fromJsonValue(row.contexto),
      );

  @override
  Future<domain.Reading> record({
    required int sessionId,
    required DateTime ts,
    required String pidKey,
    required double valor,
    required OperatingContext contexto,
  }) async {
    final companion = db.ReadingsCompanion.insert(
      uuid: _uuid.v4(),
      sessionId: sessionId,
      ts: ts,
      pidKey: pidKey,
      valor: valor,
      contexto: contexto.jsonValue,
    );
    final id = await _db.into(_db.readings).insert(companion);
    final row = await (_db.select(_db.readings)..where((t) => t.id.equals(id)))
        .getSingle();
    return _toDomain(row);
  }

  @override
  Future<List<domain.Reading>> forSession(
    int sessionId, {
    String? pidKey,
  }) async {
    final query = _db.select(_db.readings)
      ..where((t) => t.sessionId.equals(sessionId))
      ..orderBy([(t) => OrderingTerm.asc(t.ts)]);
    if (pidKey != null) {
      query.where((t) => t.pidKey.equals(pidKey));
    }
    final rows = await query.get();
    return rows.map(_toDomain).toList();
  }

  @override
  Stream<List<domain.Reading>> watchForSession(
    int sessionId, {
    String? pidKey,
  }) {
    final query = _db.select(_db.readings)
      ..where((t) => t.sessionId.equals(sessionId))
      ..orderBy([(t) => OrderingTerm.asc(t.ts)]);
    if (pidKey != null) {
      query.where((t) => t.pidKey.equals(pidKey));
    }
    return query.watch().map((rows) => rows.map(_toDomain).toList());
  }

  @override
  Stream<domain.Reading?> watchLatest({
    required int sessionId,
    required String pidKey,
  }) {
    final query = _db.select(_db.readings)
      ..where((t) => t.sessionId.equals(sessionId) & t.pidKey.equals(pidKey))
      ..orderBy([(t) => OrderingTerm.desc(t.ts)])
      ..limit(1);
    return query.watchSingleOrNull().map((row) => row == null ? null : _toDomain(row));
  }
}
