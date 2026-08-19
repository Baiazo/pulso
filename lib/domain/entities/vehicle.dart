import 'enums.dart';

/// Perfil de um veículo monitorado (§11, tabela `vehicles`).
class Vehicle {
  const Vehicle({
    this.id,
    required this.uuid,
    this.syncedAt,
    required this.vin,
    required this.apelido,
    required this.modelo,
    required this.ano,
    required this.cilindradaL,
    required this.tipoCombustivel,
    required this.pidsSuportados,
  });

  /// `null` antes de inserir — o banco atribui o autoincremento.
  final int? id;
  final String uuid;
  final DateTime? syncedAt;
  final String vin;
  final String apelido;
  final String modelo;
  final int ano;
  final double cilindradaL;
  final FuelType tipoCombustivel;

  /// PIDs suportados descobertos em campo (§7.5) — só esses devem ser
  /// agendados (§10).
  final List<int> pidsSuportados;

  Vehicle copyWith({int? id, DateTime? syncedAt, List<int>? pidsSuportados}) {
    return Vehicle(
      id: id ?? this.id,
      uuid: uuid,
      syncedAt: syncedAt ?? this.syncedAt,
      vin: vin,
      apelido: apelido,
      modelo: modelo,
      ano: ano,
      cilindradaL: cilindradaL,
      tipoCombustivel: tipoCombustivel,
      pidsSuportados: pidsSuportados ?? this.pidsSuportados,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'uuid': uuid,
        'synced_at': syncedAt?.toIso8601String(),
        'vin': vin,
        'apelido': apelido,
        'modelo': modelo,
        'ano': ano,
        'cilindrada_l': cilindradaL,
        'tipo_combustivel': tipoCombustivel.jsonValue,
        'pids_suportados': pidsSuportados,
      };

  factory Vehicle.fromJson(Map<String, dynamic> json) => Vehicle(
        id: json['id'] as int?,
        uuid: json['uuid'] as String,
        syncedAt: json['synced_at'] == null
            ? null
            : DateTime.parse(json['synced_at'] as String),
        vin: json['vin'] as String,
        apelido: json['apelido'] as String,
        modelo: json['modelo'] as String,
        ano: json['ano'] as int,
        cilindradaL: (json['cilindrada_l'] as num).toDouble(),
        tipoCombustivel:
            FuelTypeJson.fromJsonValue(json['tipo_combustivel'] as String),
        pidsSuportados:
            (json['pids_suportados'] as List).map((e) => e as int).toList(),
      );
}
