import 'enums.dart';

/// Uma leitura decodificada de um parâmetro, em um instante (§11, tabela
/// `readings` — a que mais cresce; índice composto
/// `(session_id, pid_key, ts)` sustenta a consulta do gráfico).
class Reading {
  const Reading({
    this.id,
    required this.uuid,
    this.syncedAt,
    required this.sessionId,
    required this.ts,
    required this.pidKey,
    required this.valor,
    required this.contexto,
  });

  final int? id;
  final String uuid;
  final DateTime? syncedAt;
  final int sessionId;
  final DateTime ts;
  final String pidKey;
  final double valor;
  final OperatingContext contexto;

  Map<String, dynamic> toJson() => {
        'id': id,
        'uuid': uuid,
        'synced_at': syncedAt?.toIso8601String(),
        'session_id': sessionId,
        'ts': ts.toIso8601String(),
        'pid_key': pidKey,
        'valor': valor,
        'contexto': contexto.jsonValue,
      };

  factory Reading.fromJson(Map<String, dynamic> json) => Reading(
        id: json['id'] as int?,
        uuid: json['uuid'] as String,
        syncedAt: json['synced_at'] == null
            ? null
            : DateTime.parse(json['synced_at'] as String),
        sessionId: json['session_id'] as int,
        ts: DateTime.parse(json['ts'] as String),
        pidKey: json['pid_key'] as String,
        valor: (json['valor'] as num).toDouble(),
        contexto: OperatingContextJson.fromJsonValue(json['contexto'] as String),
      );
}
