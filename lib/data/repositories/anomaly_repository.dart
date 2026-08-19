import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/anomaly.dart' as domain;
import '../../domain/entities/enums.dart';
import '../db/database.dart' as db;

abstract class AnomalyRepository {
  Future<domain.Anomaly> record({
    required int sessionId,
    required DateTime ts,
    required String pidKey,
    required OperatingContext contexto,
    required double valor,
    required double mediaEsperada,
    required double desvioPadrao,
    required double z,
    required AnomalySeverity severidade,
    required AnomalyType tipo,
  });

  /// Alimenta a timeline de anomalias (RF14, tela do item 15).
  Future<List<domain.Anomaly>> forSession(int sessionId);
  Stream<List<domain.Anomaly>> watchForSession(int sessionId);
}

class LocalAnomalyRepository implements AnomalyRepository {
  LocalAnomalyRepository(this._db, {Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  final db.AppDatabase _db;
  final Uuid _uuid;

  domain.Anomaly _toDomain(db.Anomaly row) => domain.Anomaly(
        id: row.id,
        uuid: row.uuid,
        syncedAt: row.syncedAt,
        sessionId: row.sessionId,
        ts: row.ts,
        pidKey: row.pidKey,
        contexto: OperatingContextJson.fromJsonValue(row.contexto),
        valor: row.valor,
        mediaEsperada: row.mediaEsperada,
        desvioPadrao: row.desvioPadrao,
        z: row.z,
        severidade: AnomalySeverityJson.fromJsonValue(row.severidade),
        tipo: AnomalyTypeJson.fromJsonValue(row.tipo),
      );

  @override
  Future<domain.Anomaly> record({
    required int sessionId,
    required DateTime ts,
    required String pidKey,
    required OperatingContext contexto,
    required double valor,
    required double mediaEsperada,
    required double desvioPadrao,
    required double z,
    required AnomalySeverity severidade,
    required AnomalyType tipo,
  }) async {
    final companion = db.AnomaliesCompanion.insert(
      uuid: _uuid.v4(),
      sessionId: sessionId,
      ts: ts,
      pidKey: pidKey,
      contexto: contexto.jsonValue,
      valor: valor,
      mediaEsperada: mediaEsperada,
      desvioPadrao: desvioPadrao,
      z: z,
      severidade: severidade.jsonValue,
      tipo: tipo.jsonValue,
    );
    final id = await _db.into(_db.anomalies).insert(companion);
    final row = await (_db.select(_db.anomalies)
          ..where((t) => t.id.equals(id)))
        .getSingle();
    return _toDomain(row);
  }

  @override
  Future<List<domain.Anomaly>> forSession(int sessionId) async {
    final rows = await (_db.select(_db.anomalies)
          ..where((t) => t.sessionId.equals(sessionId))
          ..orderBy([(t) => OrderingTerm.desc(t.ts)]))
        .get();
    return rows.map(_toDomain).toList();
  }

  @override
  Stream<List<domain.Anomaly>> watchForSession(int sessionId) {
    final query = _db.select(_db.anomalies)
      ..where((t) => t.sessionId.equals(sessionId))
      ..orderBy([(t) => OrderingTerm.desc(t.ts)]);
    return query.watch().map((rows) => rows.map(_toDomain).toList());
  }
}
