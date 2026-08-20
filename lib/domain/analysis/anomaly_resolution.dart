import '../entities/anomaly.dart';
import '../entities/enums.dart';
import '../entities/session.dart';

/// Sessões finalizadas sem recorrência exigidas pra considerar um alerta
/// resolvido — mesmo número e mesmo raciocínio do `trendSustainedSessions`
/// do §12.5 (`AnalysisThresholds`): um evento isolado não confirma nada,
/// precisa de sessões seguidas confirmando a ausência do problema. Não dá
/// pra importar a constante de lá direto (é limiar do motor de análise,
/// avaliado sessão a sessão; isto é um resumo derivado pro histórico), daí
/// a duplicação deliberada do valor.
const _sessionsToConfirmResolved = 3;

enum AlertStatus { open, resolved }

/// Um "alerta" do ponto de vista do usuário: todas as ocorrências de um
/// `(pidKey, tipo)` num só grupo — uma linha por leitura seria ruído, não
/// o resumo que a RF23 pede.
class AlertGroup {
  const AlertGroup({
    required this.pidKey,
    required this.tipo,
    required this.anomalies,
    required this.status,
    required this.sessionsSinceCount,
  });

  final String pidKey;
  final AnomalyType tipo;

  /// Ordenadas por `ts` decrescente — `anomalies.first` é a mais recente.
  final List<Anomaly> anomalies;
  final AlertStatus status;

  /// Sessões finalizadas depois da sessão de `latest`, sem recorrência.
  /// Uma sessão em andamento nunca conta (§17, item 15): não dá pra
  /// confirmar ausência de problema no meio de uma viagem.
  final int sessionsSinceCount;

  Anomaly get latest => anomalies.first;
}

/// Agrupa e classifica anomalias em abertas/resolvidas pro histórico de
/// veículo (item 15, RF14/RF23). É a versão "olha o histórico inteiro" do
/// que `_AlertBanner` do painel ao vivo já faz na janela de uma sessão só.
List<AlertGroup> groupAndClassifyAlerts({
  required List<Anomaly> anomalies,
  required List<Session> sessions,
}) {
  final byKey = <(String, AnomalyType), List<Anomaly>>{};
  for (final anomaly in anomalies) {
    byKey.putIfAbsent((anomaly.pidKey, anomaly.tipo), () => []).add(anomaly);
  }

  final sortedSessions = [...sessions]
    ..sort((a, b) => a.iniciadaEm.compareTo(b.iniciadaEm));

  final groups = <AlertGroup>[];
  for (final entry in byKey.entries) {
    final occurrences = [...entry.value]..sort((a, b) => b.ts.compareTo(a.ts));
    final latest = occurrences.first;

    // Por construção `latest` é a ocorrência mais recente do grupo, então
    // nenhuma sessão depois da dela pode conter uma recorrência — não há
    // necessidade de reverificar isso na janela de confirmação.
    final latestIndex = sortedSessions.indexWhere((s) => s.id == latest.sessionId);
    var sessionsSince = 0;
    if (latestIndex != -1) {
      for (var i = latestIndex + 1; i < sortedSessions.length; i++) {
        if (sortedSessions[i].encerradaEm != null) sessionsSince++;
      }
    }

    groups.add(AlertGroup(
      pidKey: entry.key.$1,
      tipo: entry.key.$2,
      anomalies: occurrences,
      status: sessionsSince >= _sessionsToConfirmResolved
          ? AlertStatus.resolved
          : AlertStatus.open,
      sessionsSinceCount: sessionsSince,
    ));
  }

  groups.sort((a, b) => b.latest.ts.compareTo(a.latest.ts));
  return groups;
}
