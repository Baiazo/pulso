import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/enums.dart';
import '../../domain/entities/session.dart' as domain;
import '../db/database.dart' as db;

abstract class SessionRepository {
  Future<domain.Session> start({
    required int vehicleId,
    required DateTime iniciadaEm,
    required String protocolo,
    required String adaptador,
    required SessionOrigin origem,
  });

  Future<domain.Session> end(
    int sessionId, {
    required DateTime encerradaEm,
    double? distanciaKm,
    int? duracaoS,
    double? consumoMedioKml,
  });

  Future<domain.Session?> byId(int id);
  Future<List<domain.Session>> forVehicle(int vehicleId);
  Stream<List<domain.Session>> watchForVehicle(int vehicleId);
}

class LocalSessionRepository implements SessionRepository {
  LocalSessionRepository(this._db, {Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  final db.AppDatabase _db;
  final Uuid _uuid;

  domain.Session _toDomain(db.Session row) => domain.Session(
        id: row.id,
        uuid: row.uuid,
        syncedAt: row.syncedAt,
        vehicleId: row.vehicleId,
        iniciadaEm: row.iniciadaEm,
        encerradaEm: row.encerradaEm,
        protocolo: row.protocolo,
        adaptador: row.adaptador,
        origem: SessionOriginJson.fromJsonValue(row.origem),
        distanciaKm: row.distanciaKm,
        duracaoS: row.duracaoS,
        consumoMedioKml: row.consumoMedioKml,
      );

  @override
  Future<domain.Session> start({
    required int vehicleId,
    required DateTime iniciadaEm,
    required String protocolo,
    required String adaptador,
    required SessionOrigin origem,
  }) async {
    final companion = db.SessionsCompanion.insert(
      uuid: _uuid.v4(),
      vehicleId: vehicleId,
      iniciadaEm: iniciadaEm,
      protocolo: protocolo,
      adaptador: adaptador,
      origem: origem.jsonValue,
    );
    final id = await _db.into(_db.sessions).insert(companion);
    return (await byId(id))!;
  }

  @override
  Future<domain.Session> end(
    int sessionId, {
    required DateTime encerradaEm,
    double? distanciaKm,
    int? duracaoS,
    double? consumoMedioKml,
  }) async {
    await (_db.update(_db.sessions)..where((t) => t.id.equals(sessionId)))
        .write(
      db.SessionsCompanion(
        encerradaEm: Value(encerradaEm),
        distanciaKm: Value(distanciaKm),
        duracaoS: Value(duracaoS),
        consumoMedioKml: Value(consumoMedioKml),
      ),
    );
    return (await byId(sessionId))!;
  }

  @override
  Future<domain.Session?> byId(int id) async {
    final row = await (_db.select(_db.sessions)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _toDomain(row);
  }

  @override
  Future<List<domain.Session>> forVehicle(int vehicleId) async {
    final rows = await (_db.select(_db.sessions)
          ..where((t) => t.vehicleId.equals(vehicleId))
          ..orderBy([(t) => OrderingTerm.desc(t.iniciadaEm)]))
        .get();
    return rows.map(_toDomain).toList();
  }

  @override
  Stream<List<domain.Session>> watchForVehicle(int vehicleId) {
    final query = _db.select(_db.sessions)
      ..where((t) => t.vehicleId.equals(vehicleId))
      ..orderBy([(t) => OrderingTerm.desc(t.iniciadaEm)]);
    return query.watch().map((rows) => rows.map(_toDomain).toList());
  }
}
