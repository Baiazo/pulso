import 'enums.dart';

/// Um DTC observado numa sessão, com o freeze frame associado (§11, tabela
/// `dtc_events`).
class DtcEvent {
  const DtcEvent({
    this.id,
    required this.uuid,
    this.syncedAt,
    required this.sessionId,
    required this.ts,
    required this.codigo,
    required this.tipo,
    required this.descricao,
    required this.freezeFrame,
  });

  final int? id;
  final String uuid;
  final DateTime? syncedAt;
  final int sessionId;
  final DateTime ts;
  final String codigo;
  final DtcEventType tipo;
  final String descricao;

  /// PID key -> valor, no instante em que o DTC foi detectado.
  final Map<String, double> freezeFrame;

  Map<String, dynamic> toJson() => {
        'id': id,
        'uuid': uuid,
        'synced_at': syncedAt?.toIso8601String(),
        'session_id': sessionId,
        'ts': ts.toIso8601String(),
        'codigo': codigo,
        'tipo': tipo.jsonValue,
        'descricao': descricao,
        'freeze_frame': freezeFrame,
      };

  factory DtcEvent.fromJson(Map<String, dynamic> json) => DtcEvent(
        id: json['id'] as int?,
        uuid: json['uuid'] as String,
        syncedAt: json['synced_at'] == null
            ? null
            : DateTime.parse(json['synced_at'] as String),
        sessionId: json['session_id'] as int,
        ts: DateTime.parse(json['ts'] as String),
        codigo: json['codigo'] as String,
        tipo: DtcEventTypeJson.fromJsonValue(json['tipo'] as String),
        descricao: json['descricao'] as String,
        freezeFrame: (json['freeze_frame'] as Map).map(
          (k, v) => MapEntry(k as String, (v as num).toDouble()),
        ),
      );
}
