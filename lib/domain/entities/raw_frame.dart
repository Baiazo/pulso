/// Um quadro bruto de comunicação, gravado só com o modo de validação
/// ligado (§11, tabela `raw_frames`) — evidência para a comparação contra
/// scanner comercial (§5.7 do TCC, RF22).
class RawFrame {
  const RawFrame({
    this.id,
    required this.uuid,
    this.syncedAt,
    required this.sessionId,
    required this.ts,
    required this.comando,
    required this.respostaBruta,
  });

  final int? id;
  final String uuid;
  final DateTime? syncedAt;
  final int sessionId;
  final DateTime ts;
  final String comando;
  final String respostaBruta;

  Map<String, dynamic> toJson() => {
        'id': id,
        'uuid': uuid,
        'synced_at': syncedAt?.toIso8601String(),
        'session_id': sessionId,
        'ts': ts.toIso8601String(),
        'comando': comando,
        'resposta_bruta': respostaBruta,
      };

  factory RawFrame.fromJson(Map<String, dynamic> json) => RawFrame(
        id: json['id'] as int?,
        uuid: json['uuid'] as String,
        syncedAt: json['synced_at'] == null
            ? null
            : DateTime.parse(json['synced_at'] as String),
        sessionId: json['session_id'] as int,
        ts: DateTime.parse(json['ts'] as String),
        comando: json['comando'] as String,
        respostaBruta: json['resposta_bruta'] as String,
      );
}
