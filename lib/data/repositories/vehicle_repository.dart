import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/enums.dart';
import '../../domain/entities/vehicle.dart' as domain;
import '../db/database.dart' as db;

/// Atrás de interface (§2.1) — a Fase 2 acrescenta uma implementação
/// remota sem tocar em nada acima.
abstract class VehicleRepository {
  Future<domain.Vehicle> create({
    required String vin,
    required String apelido,
    required String modelo,
    required int ano,
    required double cilindradaL,
    required FuelType tipoCombustivel,
  });

  Future<domain.Vehicle?> byId(int id);
  Future<List<domain.Vehicle>> all();
  Future<domain.Vehicle> updateSupportedPids(int vehicleId, List<int> pids);
}

class LocalVehicleRepository implements VehicleRepository {
  LocalVehicleRepository(this._db, {Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  final db.AppDatabase _db;
  final Uuid _uuid;

  domain.Vehicle _toDomain(db.Vehicle row) => domain.Vehicle(
        id: row.id,
        uuid: row.uuid,
        syncedAt: row.syncedAt,
        vin: row.vin,
        apelido: row.apelido,
        modelo: row.modelo,
        ano: row.ano,
        cilindradaL: row.cilindradaL,
        tipoCombustivel: FuelTypeJson.fromJsonValue(row.tipoCombustivel),
        pidsSuportados: row.pidsSuportados,
      );

  @override
  Future<domain.Vehicle> create({
    required String vin,
    required String apelido,
    required String modelo,
    required int ano,
    required double cilindradaL,
    required FuelType tipoCombustivel,
  }) async {
    final companion = db.VehiclesCompanion.insert(
      uuid: _uuid.v4(),
      vin: vin,
      apelido: apelido,
      modelo: modelo,
      ano: ano,
      cilindradaL: cilindradaL,
      tipoCombustivel: tipoCombustivel.jsonValue,
    );
    final id = await _db.into(_db.vehicles).insert(companion);
    final row = await (_db.select(_db.vehicles)
          ..where((t) => t.id.equals(id)))
        .getSingle();
    return _toDomain(row);
  }

  @override
  Future<domain.Vehicle?> byId(int id) async {
    final row = await (_db.select(_db.vehicles)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _toDomain(row);
  }

  @override
  Future<List<domain.Vehicle>> all() async {
    final rows = await _db.select(_db.vehicles).get();
    return rows.map(_toDomain).toList();
  }

  @override
  Future<domain.Vehicle> updateSupportedPids(
    int vehicleId,
    List<int> pids,
  ) async {
    await (_db.update(_db.vehicles)..where((t) => t.id.equals(vehicleId)))
        .write(db.VehiclesCompanion(pidsSuportados: Value(pids)));
    final row = await (_db.select(_db.vehicles)
          ..where((t) => t.id.equals(vehicleId)))
        .getSingle();
    return _toDomain(row);
  }
}
