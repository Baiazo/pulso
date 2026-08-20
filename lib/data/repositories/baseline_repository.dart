import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/baseline.dart' as domain;
import '../../domain/entities/enums.dart';
import '../db/database.dart' as db;

abstract class BaselineRepository {
  Future<domain.Baseline?> find({
    required int vehicleId,
    required String pidKey,
    required OperatingContext contexto,
  });

  /// Cria ou substitui o estado de Welford de um `(veículo, parâmetro,
  /// contexto)` — chave natural da tabela `baselines` (§11).
  Future<domain.Baseline> upsert({
    required int vehicleId,
    required String pidKey,
    required OperatingContext contexto,
    required int n,
    required double media,
    required double m2,
    required DateTime atualizadoEm,
  });

  Future<List<domain.Baseline>> forVehicle(int vehicleId);

  /// Fonte do "MÉD 88°" no painel ao vivo (item 12) — reativo porque a
  /// baseline muda a cada leitura não-anômala.
  Stream<domain.Baseline?> watch({
    required int vehicleId,
    required String pidKey,
    required OperatingContext contexto,
  });
}

class LocalBaselineRepository implements BaselineRepository {
  LocalBaselineRepository(this._db, {Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  final db.AppDatabase _db;
  final Uuid _uuid;

  domain.Baseline _toDomain(db.Baseline row) => domain.Baseline(
        id: row.id,
        uuid: row.uuid,
        syncedAt: row.syncedAt,
        vehicleId: row.vehicleId,
        pidKey: row.pidKey,
        contexto: OperatingContextJson.fromJsonValue(row.contexto),
        n: row.n,
        media: row.media,
        m2: row.m2,
        atualizadoEm: row.atualizadoEm,
      );

  @override
  Future<domain.Baseline?> find({
    required int vehicleId,
    required String pidKey,
    required OperatingContext contexto,
  }) async {
    final row = await (_db.select(_db.baselines)
          ..where((t) =>
              t.vehicleId.equals(vehicleId) &
              t.pidKey.equals(pidKey) &
              t.contexto.equals(contexto.jsonValue)))
        .getSingleOrNull();
    return row == null ? null : _toDomain(row);
  }

  @override
  Future<domain.Baseline> upsert({
    required int vehicleId,
    required String pidKey,
    required OperatingContext contexto,
    required int n,
    required double media,
    required double m2,
    required DateTime atualizadoEm,
  }) async {
    final existing = await find(
      vehicleId: vehicleId,
      pidKey: pidKey,
      contexto: contexto,
    );

    if (existing == null) {
      final companion = db.BaselinesCompanion.insert(
        uuid: _uuid.v4(),
        vehicleId: vehicleId,
        pidKey: pidKey,
        contexto: contexto.jsonValue,
        n: n,
        media: media,
        m2: m2,
        atualizadoEm: atualizadoEm,
      );
      final id = await _db.into(_db.baselines).insert(companion);
      final row = await (_db.select(_db.baselines)
            ..where((t) => t.id.equals(id)))
          .getSingle();
      return _toDomain(row);
    }

    await (_db.update(_db.baselines)
          ..where((t) => t.id.equals(existing.id!)))
        .write(
      db.BaselinesCompanion(
        n: Value(n),
        media: Value(media),
        m2: Value(m2),
        atualizadoEm: Value(atualizadoEm),
      ),
    );
    final row = await (_db.select(_db.baselines)
          ..where((t) => t.id.equals(existing.id!)))
        .getSingle();
    return _toDomain(row);
  }

  @override
  Future<List<domain.Baseline>> forVehicle(int vehicleId) async {
    final rows = await (_db.select(_db.baselines)
          ..where((t) => t.vehicleId.equals(vehicleId)))
        .get();
    return rows.map(_toDomain).toList();
  }

  @override
  Stream<domain.Baseline?> watch({
    required int vehicleId,
    required String pidKey,
    required OperatingContext contexto,
  }) {
    final query = _db.select(_db.baselines)
      ..where((t) =>
          t.vehicleId.equals(vehicleId) &
          t.pidKey.equals(pidKey) &
          t.contexto.equals(contexto.jsonValue));
    return query.watchSingleOrNull().map((row) => row == null ? null : _toDomain(row));
  }
}
