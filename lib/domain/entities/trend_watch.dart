import 'enums.dart';

/// Contador de quantas sessões consecutivas um `(parâmetro, contexto)`
/// veio se desviando da baseline via EWMA (§12.5) — "sustentado por 3
/// sessões consecutivas" exige estado entre sessões, que não existe em
/// nenhuma das tabelas do §11. Extensão mínima sobre o schema documentado,
/// só pra tornar esse critério do §12.5 implementável de verdade.
class TrendWatch {
  const TrendWatch({
    this.id,
    required this.uuid,
    this.syncedAt,
    required this.vehicleId,
    required this.pidKey,
    required this.contexto,
    required this.consecutiveDeviatedSessions,
    this.lastSessionId,
  });

  final int? id;
  final String uuid;
  final DateTime? syncedAt;
  final int vehicleId;
  final String pidKey;
  final OperatingContext contexto;
  final int consecutiveDeviatedSessions;
  final int? lastSessionId;

  Map<String, dynamic> toJson() => {
        'id': id,
        'uuid': uuid,
        'synced_at': syncedAt?.toIso8601String(),
        'vehicle_id': vehicleId,
        'pid_key': pidKey,
        'contexto': contexto.jsonValue,
        'consecutive_deviated_sessions': consecutiveDeviatedSessions,
        'last_session_id': lastSessionId,
      };

  factory TrendWatch.fromJson(Map<String, dynamic> json) => TrendWatch(
        id: json['id'] as int?,
        uuid: json['uuid'] as String,
        syncedAt: json['synced_at'] == null
            ? null
            : DateTime.parse(json['synced_at'] as String),
        vehicleId: json['vehicle_id'] as int,
        pidKey: json['pid_key'] as String,
        contexto: OperatingContextJson.fromJsonValue(json['contexto'] as String),
        consecutiveDeviatedSessions:
            json['consecutive_deviated_sessions'] as int,
        lastSessionId: json['last_session_id'] as int?,
      );
}
