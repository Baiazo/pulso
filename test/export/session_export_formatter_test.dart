import 'package:flutter_test/flutter_test.dart';
import 'package:pulso/domain/entities/anomaly.dart';
import 'package:pulso/domain/entities/baseline.dart';
import 'package:pulso/domain/entities/enums.dart';
import 'package:pulso/domain/entities/reading.dart';
import 'package:pulso/domain/entities/session.dart';
import 'package:pulso/domain/export/session_export_formatter.dart';

// Mini réplica do lookup de unidade que `trip_export.dart` monta a partir do
// catálogo de PIDs + PIDs derivados pelo motor de análise (§12.7) — não dá
// pra importar o catálogo aqui sem puxar Flutter, então duplicamos só as
// entradas usadas neste teste (convenção deste repo: pequeno helper por
// arquivo em vez de util compartilhado).
const _units = {
  'engine_rpm': 'rpm',
  'consumo_kml': 'km/l',
  'consumo_lh': 'L/h',
};

String _unitFor(String pidKey) => _units[pidKey] ?? '';

Reading _reading({
  required DateTime ts,
  required String pidKey,
  required double valor,
  required OperatingContext contexto,
}) {
  return Reading(
    uuid: 'r-$pidKey',
    sessionId: 1,
    ts: ts,
    pidKey: pidKey,
    valor: valor,
    contexto: contexto,
  );
}

void main() {
  group('buildReadingsCsv (RF20)', () {
    test('linha de cabeçalho é exatamente ts,pid_key,valor,unidade,contexto', () {
      final csv = buildReadingsCsv(readings: const [], unitFor: _unitFor);
      final firstLine = csv.split('\r\n').first;
      expect(firstLine, 'ts,pid_key,valor,unidade,contexto');
    });

    test('leituras conhecidas viram linhas exatas, com unidade resolvida '
        'por um PID do catálogo e por um PID derivado (consumo_kml)', () {
      final readings = [
        _reading(
          ts: DateTime.utc(2026, 1, 1, 10, 0),
          pidKey: 'engine_rpm',
          valor: 850,
          contexto: OperatingContext.urbano,
        ),
        _reading(
          ts: DateTime.utc(2026, 1, 1, 10, 0, 1),
          pidKey: 'consumo_kml',
          valor: 12.5,
          contexto: OperatingContext.rodovia,
        ),
      ];

      final csv = buildReadingsCsv(readings: readings, unitFor: _unitFor);
      final lines = csv.split('\r\n');

      expect(lines, [
        'ts,pid_key,valor,unidade,contexto',
        '2026-01-01T10:00:00.000Z,engine_rpm,850.0,rpm,urbano',
        '2026-01-01T10:00:01.000Z,consumo_kml,12.5,km/l,rodovia',
      ]);
    });

    test('pid_key desconhecido cai pra unidade vazia em vez de lançar', () {
      final readings = [
        _reading(
          ts: DateTime.utc(2026, 1, 1, 10, 0, 2),
          pidKey: 'pid_nunca_visto',
          valor: 1,
          contexto: OperatingContext.paradoFrio,
        ),
      ];

      expect(
        () => buildReadingsCsv(readings: readings, unitFor: _unitFor),
        returnsNormally,
      );

      final csv = buildReadingsCsv(readings: readings, unitFor: _unitFor);
      final dataLine = csv.split('\r\n')[1];
      expect(dataLine, '2026-01-01T10:00:02.000Z,pid_nunca_visto,1.0,,parado_frio');
    });
  });

  group('buildSessionExportJson (RF20)', () {
    final session = Session(
      id: 42,
      uuid: 'sess-uuid',
      vehicleId: 7,
      iniciadaEm: DateTime.utc(2026, 1, 1, 9, 0),
      encerradaEm: DateTime.utc(2026, 1, 1, 9, 30),
      protocolo: 'ISO 15765-4',
      adaptador: 'ELM327',
      origem: SessionOrigin.real,
      distanciaKm: 12.3,
      duracaoS: 1800,
      consumoMedioKml: 11.2,
    );

    final baselines = [
      Baseline(
        id: 1,
        uuid: 'b-uuid',
        vehicleId: 7,
        pidKey: 'coolant_temp',
        contexto: OperatingContext.urbano,
        n: 100,
        media: 90,
        m2: 50,
        atualizadoEm: DateTime.utc(2026, 1, 1, 9, 15),
      ),
    ];

    final anomalies = [
      Anomaly(
        id: 5,
        uuid: 'a-uuid',
        sessionId: 42,
        ts: DateTime.utc(2026, 1, 1, 9, 20),
        pidKey: 'engine_rpm',
        contexto: OperatingContext.urbano,
        valor: 4500,
        mediaEsperada: 2000,
        desvioPadrao: 300,
        z: 8.3,
        severidade: AnomalySeverity.critico,
        tipo: AnomalyType.pontual,
      ),
    ];

    test('mapa tem exatamente as três chaves de topo (garante estruturalmente '
        'que nenhum dado de veículo/VIN vaza pra exportação)', () {
      final json = buildSessionExportJson(
        session: session,
        baselines: baselines,
        anomalies: anomalies,
      );
      expect(json.keys.toSet(), {'sessao', 'baselines', 'anomalias'});
    });

    test('objetos aninhados usam o toJson() de cada entidade corretamente', () {
      final json = buildSessionExportJson(
        session: session,
        baselines: baselines,
        anomalies: anomalies,
      );

      expect(json['sessao'], isA<Map<String, dynamic>>());
      expect((json['sessao'] as Map)['id'], 42);
      expect((json['sessao'] as Map)['vehicle_id'], 7);

      final baselinesJson = json['baselines'] as List;
      expect(baselinesJson, hasLength(1));
      expect((baselinesJson.first as Map)['pid_key'], 'coolant_temp');

      final anomaliasJson = json['anomalias'] as List;
      expect(anomaliasJson, hasLength(1));
      expect((anomaliasJson.first as Map)['severidade'], 'critico');
    });

    test('sem leituras/baselines/anomalias o mapa continua com as três '
        'chaves e listas vazias', () {
      final json = buildSessionExportJson(
        session: session,
        baselines: const [],
        anomalies: const [],
      );
      expect(json['baselines'], isEmpty);
      expect(json['anomalias'], isEmpty);
    });
  });
}
