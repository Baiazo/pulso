import 'dart:math' as math;

import 'enums.dart';

/// Estado persistido do algoritmo de Welford para um `(parâmetro,
/// contexto)` — não guarda a amostra em si, só `n`, `media`, `m2` (§11,
/// §12.3).
class Baseline {
  const Baseline({
    this.id,
    required this.uuid,
    this.syncedAt,
    required this.vehicleId,
    required this.pidKey,
    required this.contexto,
    required this.n,
    required this.media,
    required this.m2,
    required this.atualizadoEm,
  });

  final int? id;
  final String uuid;
  final DateTime? syncedAt;
  final int vehicleId;
  final String pidKey;
  final OperatingContext contexto;
  final int n;
  final double media;
  final double m2;
  final DateTime atualizadoEm;

  double get variance => n < 2 ? 0 : m2 / (n - 1);

  double get stdDev => variance <= 0 ? 0 : math.sqrt(variance);

  Baseline copyWith({
    int? id,
    DateTime? syncedAt,
    int? n,
    double? media,
    double? m2,
    DateTime? atualizadoEm,
  }) {
    return Baseline(
      id: id ?? this.id,
      uuid: uuid,
      syncedAt: syncedAt ?? this.syncedAt,
      vehicleId: vehicleId,
      pidKey: pidKey,
      contexto: contexto,
      n: n ?? this.n,
      media: media ?? this.media,
      m2: m2 ?? this.m2,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'uuid': uuid,
        'synced_at': syncedAt?.toIso8601String(),
        'vehicle_id': vehicleId,
        'pid_key': pidKey,
        'contexto': contexto.jsonValue,
        'n': n,
        'media': media,
        'm2': m2,
        'atualizado_em': atualizadoEm.toIso8601String(),
      };

  factory Baseline.fromJson(Map<String, dynamic> json) => Baseline(
        id: json['id'] as int?,
        uuid: json['uuid'] as String,
        syncedAt: json['synced_at'] == null
            ? null
            : DateTime.parse(json['synced_at'] as String),
        vehicleId: json['vehicle_id'] as int,
        pidKey: json['pid_key'] as String,
        contexto: OperatingContextJson.fromJsonValue(json['contexto'] as String),
        n: json['n'] as int,
        media: (json['media'] as num).toDouble(),
        m2: (json['m2'] as num).toDouble(),
        atualizadoEm: DateTime.parse(json['atualizado_em'] as String),
      );
}
