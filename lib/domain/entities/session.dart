import 'enums.dart';

/// Uma sessão de coleta (§11, tabela `sessions`).
class Session {
  const Session({
    this.id,
    required this.uuid,
    this.syncedAt,
    required this.vehicleId,
    required this.iniciadaEm,
    this.encerradaEm,
    required this.protocolo,
    required this.adaptador,
    required this.origem,
    this.distanciaKm,
    this.duracaoS,
    this.consumoMedioKml,
  });

  final int? id;
  final String uuid;
  final DateTime? syncedAt;
  final int vehicleId;
  final DateTime iniciadaEm;
  final DateTime? encerradaEm;
  final String protocolo;
  final String adaptador;
  final SessionOrigin origem;
  final double? distanciaKm;
  final int? duracaoS;
  final double? consumoMedioKml;

  bool get emAndamento => encerradaEm == null;

  Session copyWith({
    int? id,
    DateTime? syncedAt,
    DateTime? encerradaEm,
    double? distanciaKm,
    int? duracaoS,
    double? consumoMedioKml,
  }) {
    return Session(
      id: id ?? this.id,
      uuid: uuid,
      syncedAt: syncedAt ?? this.syncedAt,
      vehicleId: vehicleId,
      iniciadaEm: iniciadaEm,
      encerradaEm: encerradaEm ?? this.encerradaEm,
      protocolo: protocolo,
      adaptador: adaptador,
      origem: origem,
      distanciaKm: distanciaKm ?? this.distanciaKm,
      duracaoS: duracaoS ?? this.duracaoS,
      consumoMedioKml: consumoMedioKml ?? this.consumoMedioKml,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'uuid': uuid,
        'synced_at': syncedAt?.toIso8601String(),
        'vehicle_id': vehicleId,
        'iniciada_em': iniciadaEm.toIso8601String(),
        'encerrada_em': encerradaEm?.toIso8601String(),
        'protocolo': protocolo,
        'adaptador': adaptador,
        'origem': origem.jsonValue,
        'distancia_km': distanciaKm,
        'duracao_s': duracaoS,
        'consumo_medio_kml': consumoMedioKml,
      };

  factory Session.fromJson(Map<String, dynamic> json) => Session(
        id: json['id'] as int?,
        uuid: json['uuid'] as String,
        syncedAt: json['synced_at'] == null
            ? null
            : DateTime.parse(json['synced_at'] as String),
        vehicleId: json['vehicle_id'] as int,
        iniciadaEm: DateTime.parse(json['iniciada_em'] as String),
        encerradaEm: json['encerrada_em'] == null
            ? null
            : DateTime.parse(json['encerrada_em'] as String),
        protocolo: json['protocolo'] as String,
        adaptador: json['adaptador'] as String,
        origem: SessionOriginJson.fromJsonValue(json['origem'] as String),
        distanciaKm: (json['distancia_km'] as num?)?.toDouble(),
        duracaoS: json['duracao_s'] as int?,
        consumoMedioKml: (json['consumo_medio_kml'] as num?)?.toDouble(),
      );
}
