import 'enums.dart';

/// Uma anomalia registrada (§11, tabela `anomalies`). Guarda
/// `media_esperada`/`desvio_padrao` no momento do alerta de propósito: a
/// baseline muda com o tempo, e sem isso não dá pra auditar depois por que
/// o alerta disparou.
class Anomaly {
  const Anomaly({
    this.id,
    required this.uuid,
    this.syncedAt,
    required this.sessionId,
    required this.ts,
    required this.pidKey,
    required this.contexto,
    required this.valor,
    required this.mediaEsperada,
    required this.desvioPadrao,
    required this.z,
    required this.severidade,
    required this.tipo,
  });

  final int? id;
  final String uuid;
  final DateTime? syncedAt;
  final int sessionId;
  final DateTime ts;
  final String pidKey;
  final OperatingContext contexto;
  final double valor;
  final double mediaEsperada;
  final double desvioPadrao;
  final double z;
  final AnomalySeverity severidade;
  final AnomalyType tipo;

  Map<String, dynamic> toJson() => {
        'id': id,
        'uuid': uuid,
        'synced_at': syncedAt?.toIso8601String(),
        'session_id': sessionId,
        'ts': ts.toIso8601String(),
        'pid_key': pidKey,
        'contexto': contexto.jsonValue,
        'valor': valor,
        'media_esperada': mediaEsperada,
        'desvio_padrao': desvioPadrao,
        'z': z,
        'severidade': severidade.jsonValue,
        'tipo': tipo.jsonValue,
      };

  factory Anomaly.fromJson(Map<String, dynamic> json) => Anomaly(
        id: json['id'] as int?,
        uuid: json['uuid'] as String,
        syncedAt: json['synced_at'] == null
            ? null
            : DateTime.parse(json['synced_at'] as String),
        sessionId: json['session_id'] as int,
        ts: DateTime.parse(json['ts'] as String),
        pidKey: json['pid_key'] as String,
        contexto: OperatingContextJson.fromJsonValue(json['contexto'] as String),
        valor: (json['valor'] as num).toDouble(),
        mediaEsperada: (json['media_esperada'] as num).toDouble(),
        desvioPadrao: (json['desvio_padrao'] as num).toDouble(),
        z: (json['z'] as num).toDouble(),
        severidade:
            AnomalySeverityJson.fromJsonValue(json['severidade'] as String),
        tipo: AnomalyTypeJson.fromJsonValue(json['tipo'] as String),
      );
}
