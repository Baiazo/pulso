import 'package:csv/csv.dart';

import '../entities/anomaly.dart';
import '../entities/baseline.dart';
import '../entities/enums.dart';
import '../entities/reading.dart';
import '../entities/session.dart';

/// Cabeçalho fixo da exportação de leituras (RF20) — uma linha por leitura,
/// nessa ordem exata.
const List<String> csvReadingsHeader = ['ts', 'pid_key', 'valor', 'unidade', 'contexto'];

/// Monta o CSV de leituras de uma sessão (RF20, tela "Viagem — detalhe").
/// `Reading` não guarda unidade — vem do catálogo de PIDs, por isso
/// `unitFor` é injetado em vez de resolvido aqui (mantém este arquivo livre
/// de dependência do catálogo/Flutter, só monta string a partir do que já
/// foi buscado). `ListToCsvConverter` cuida de aspas/escape de campos com
/// vírgula — não fazemos join manual.
String buildReadingsCsv({
  required List<Reading> readings,
  required String Function(String pidKey) unitFor,
}) {
  final rows = [
    csvReadingsHeader,
    for (final r in readings)
      [
        r.ts.toIso8601String(),
        r.pidKey,
        r.valor,
        unitFor(r.pidKey),
        r.contexto.jsonValue,
      ],
  ];
  return const ListToCsvConverter().convert(rows);
}

/// Empacota sessão + baselines do veículo + anomalias da sessão (RF20).
/// Escopo deliberadamente não inclui nada de `Vehicle` (nem VIN): as três
/// chaves de topo garantem isso estruturalmente, sem precisar de uma lista
/// de exclusão que alguém poderia esquecer de manter.
Map<String, dynamic> buildSessionExportJson({
  required Session session,
  required List<Baseline> baselines,
  required List<Anomaly> anomalies,
}) {
  return {
    'sessao': session.toJson(),
    'baselines': [for (final b in baselines) b.toJson()],
    'anomalias': [for (final a in anomalies) a.toJson()],
  };
}
