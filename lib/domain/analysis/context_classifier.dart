import '../entities/enums.dart';

/// Classifica o contexto operacional (§12.2) — pré-requisito de
/// `SamplingScheduler` (item 8): toda leitura persistida precisa de um
/// contexto, então essa parte do motor de análise (item 10) precisou vir
/// antes do previsto na ordem do §17. O resto do motor (Welford, Z-score,
/// EWMA) continua no item 10.
///
/// Dart puro — nenhum import de `package:flutter/...` (§2.1, regra 3):
/// roda em teste unitário sem framework, e o serviço Python da Fase 3 vai
/// reimplementar o mesmo contrato.
OperatingContext classifyContext({
  required double speedKmh,
  required double coolantTempC,
}) {
  if (speedKmh <= 0) {
    return coolantTempC < 70
        ? OperatingContext.paradoFrio
        : OperatingContext.paradoQuente;
  }
  return speedKmh <= 60 ? OperatingContext.urbano : OperatingContext.rodovia;
}
