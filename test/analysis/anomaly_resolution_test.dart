import 'package:flutter_test/flutter_test.dart';
import 'package:pulso/domain/analysis/anomaly_resolution.dart';
import 'package:pulso/domain/entities/anomaly.dart';
import 'package:pulso/domain/entities/enums.dart';
import 'package:pulso/domain/entities/session.dart';

Session _session(
  int id, {
  required DateTime iniciadaEm,
  DateTime? encerradaEm,
}) {
  return Session(
    id: id,
    uuid: 'session-$id',
    vehicleId: 1,
    iniciadaEm: iniciadaEm,
    encerradaEm: encerradaEm,
    protocolo: 'ISO 15765-4 (CAN 11/500)',
    adaptador: 'ELM327',
    origem: SessionOrigin.simulado,
  );
}

Anomaly _anomaly({
  required int sessionId,
  required DateTime ts,
  String pidKey = 'coolant_temp',
  AnomalyType tipo = AnomalyType.pontual,
  AnomalySeverity severidade = AnomalySeverity.serio,
}) {
  return Anomaly(
    uuid: 'anomaly-$sessionId-${ts.millisecondsSinceEpoch}',
    sessionId: sessionId,
    ts: ts,
    pidKey: pidKey,
    contexto: OperatingContext.urbano,
    valor: 106,
    mediaEsperada: 88,
    desvioPadrao: 3.1,
    z: 5.8,
    severidade: severidade,
    tipo: tipo,
  );
}

void main() {
  group('groupAndClassifyAlerts (item 15, §17)', () {
    test('lista vazia não quebra e não gera grupo', () {
      final groups = groupAndClassifyAlerts(anomalies: const [], sessions: const []);
      expect(groups, isEmpty);
    });

    test('3+ sessões finalizadas depois sem recorrência → resolvido', () {
      final sessions = [
        _session(1, iniciadaEm: DateTime(2026, 8, 10), encerradaEm: DateTime(2026, 8, 10, 1)),
        _session(2, iniciadaEm: DateTime(2026, 8, 11), encerradaEm: DateTime(2026, 8, 11, 1)),
        _session(3, iniciadaEm: DateTime(2026, 8, 12), encerradaEm: DateTime(2026, 8, 12, 1)),
        _session(4, iniciadaEm: DateTime(2026, 8, 13), encerradaEm: DateTime(2026, 8, 13, 1)),
      ];
      final anomalies = [_anomaly(sessionId: 1, ts: DateTime(2026, 8, 10, 0, 30))];

      final groups = groupAndClassifyAlerts(anomalies: anomalies, sessions: sessions);

      expect(groups, hasLength(1));
      expect(groups.single.status, AlertStatus.resolved);
      expect(groups.single.sessionsSinceCount, 3);
    });

    test('só 1 sessão finalizada depois → continua aberto', () {
      final sessions = [
        _session(1, iniciadaEm: DateTime(2026, 8, 10), encerradaEm: DateTime(2026, 8, 10, 1)),
        _session(2, iniciadaEm: DateTime(2026, 8, 11), encerradaEm: DateTime(2026, 8, 11, 1)),
      ];
      final anomalies = [_anomaly(sessionId: 1, ts: DateTime(2026, 8, 10, 0, 30))];

      final groups = groupAndClassifyAlerts(anomalies: anomalies, sessions: sessions);

      expect(groups.single.status, AlertStatus.open);
      expect(groups.single.sessionsSinceCount, 1);
    });

    test('recorrência numa sessão posterior reabre o grupo a partir da nova ocorrência', () {
      final sessions = [
        _session(1, iniciadaEm: DateTime(2026, 8, 10), encerradaEm: DateTime(2026, 8, 10, 1)),
        _session(2, iniciadaEm: DateTime(2026, 8, 11), encerradaEm: DateTime(2026, 8, 11, 1)),
        _session(3, iniciadaEm: DateTime(2026, 8, 12), encerradaEm: DateTime(2026, 8, 12, 1)),
        _session(4, iniciadaEm: DateTime(2026, 8, 13), encerradaEm: DateTime(2026, 8, 13, 1)),
      ];
      // Primeira ocorrência na sessão 1 teria 3 sessões depois (resolvido),
      // mas recorre de novo na sessão 3 — só 1 sessão finalizada depois
      // dela (a 4), então o grupo volta a ficar aberto.
      final anomalies = [
        _anomaly(sessionId: 1, ts: DateTime(2026, 8, 10, 0, 30)),
        _anomaly(sessionId: 3, ts: DateTime(2026, 8, 12, 0, 30)),
      ];

      final groups = groupAndClassifyAlerts(anomalies: anomalies, sessions: sessions);

      expect(groups, hasLength(1));
      final group = groups.single;
      expect(group.latest.sessionId, 3);
      expect(group.sessionsSinceCount, 1);
      expect(group.status, AlertStatus.open);
    });

    test('sessão em andamento depois da ocorrência não conta pra confirmação', () {
      final sessions = [
        _session(1, iniciadaEm: DateTime(2026, 8, 10), encerradaEm: DateTime(2026, 8, 10, 1)),
        _session(2, iniciadaEm: DateTime(2026, 8, 11), encerradaEm: DateTime(2026, 8, 11, 1)),
        _session(3, iniciadaEm: DateTime(2026, 8, 12), encerradaEm: DateTime(2026, 8, 12, 1)),
        // Em andamento — encerradaEm nulo, não pode confirmar resolução.
        _session(4, iniciadaEm: DateTime(2026, 8, 13)),
      ];
      final anomalies = [_anomaly(sessionId: 1, ts: DateTime(2026, 8, 10, 0, 30))];

      final groups = groupAndClassifyAlerts(anomalies: anomalies, sessions: sessions);

      expect(groups.single.sessionsSinceCount, 2);
      expect(groups.single.status, AlertStatus.open);
    });

    test('grupos de (pidKey, tipo) distintos são classificados de forma independente', () {
      final sessions = [
        _session(1, iniciadaEm: DateTime(2026, 8, 10), encerradaEm: DateTime(2026, 8, 10, 1)),
        _session(2, iniciadaEm: DateTime(2026, 8, 11), encerradaEm: DateTime(2026, 8, 11, 1)),
        _session(3, iniciadaEm: DateTime(2026, 8, 12), encerradaEm: DateTime(2026, 8, 12, 1)),
        _session(4, iniciadaEm: DateTime(2026, 8, 13), encerradaEm: DateTime(2026, 8, 13, 1)),
      ];
      final anomalies = [
        // coolant_temp/pontual: resolvido (3 sessões finalizadas depois).
        _anomaly(sessionId: 1, ts: DateTime(2026, 8, 10, 0, 30), pidKey: 'coolant_temp'),
        // control_module_voltage/pontual: só 1 sessão depois, aberto.
        _anomaly(sessionId: 3, ts: DateTime(2026, 8, 12, 0, 30), pidKey: 'control_module_voltage'),
      ];

      final groups = groupAndClassifyAlerts(anomalies: anomalies, sessions: sessions);

      expect(groups, hasLength(2));
      final coolant = groups.firstWhere((g) => g.pidKey == 'coolant_temp');
      final voltage = groups.firstWhere((g) => g.pidKey == 'control_module_voltage');
      expect(coolant.status, AlertStatus.resolved);
      expect(coolant.sessionsSinceCount, 3);
      expect(voltage.status, AlertStatus.open);
      expect(voltage.sessionsSinceCount, 1);
    });

    test('mesmo pidKey com tipos diferentes (pontual vs tendência) vira grupos separados', () {
      final sessions = [
        _session(1, iniciadaEm: DateTime(2026, 8, 10), encerradaEm: DateTime(2026, 8, 10, 1)),
      ];
      final anomalies = [
        _anomaly(sessionId: 1, ts: DateTime(2026, 8, 10, 0, 10), tipo: AnomalyType.pontual),
        _anomaly(sessionId: 1, ts: DateTime(2026, 8, 10, 0, 20), tipo: AnomalyType.tendencia),
      ];

      final groups = groupAndClassifyAlerts(anomalies: anomalies, sessions: sessions);

      expect(groups, hasLength(2));
    });

    test('resultado vem ordenado por ts do latest, mais recente primeiro', () {
      final sessions = [
        _session(1, iniciadaEm: DateTime(2026, 8, 10), encerradaEm: DateTime(2026, 8, 10, 1)),
        _session(2, iniciadaEm: DateTime(2026, 8, 11), encerradaEm: DateTime(2026, 8, 11, 1)),
      ];
      final anomalies = [
        _anomaly(sessionId: 1, ts: DateTime(2026, 8, 10, 0, 30), pidKey: 'coolant_temp'),
        _anomaly(sessionId: 2, ts: DateTime(2026, 8, 11, 0, 30), pidKey: 'control_module_voltage'),
      ];

      final groups = groupAndClassifyAlerts(anomalies: anomalies, sessions: sessions);

      expect(groups.map((g) => g.pidKey), ['control_module_voltage', 'coolant_temp']);
    });
  });
}
