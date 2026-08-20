import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulso/data/db/database.dart';
import 'package:pulso/data/obd/transport/mock/mock_vehicle.dart';
import 'package:pulso/data/repositories/anomaly_repository.dart';
import 'package:pulso/data/repositories/baseline_repository.dart';
import 'package:pulso/data/repositories/reading_repository.dart';
import 'package:pulso/data/repositories/session_repository.dart';
import 'package:pulso/data/repositories/trend_watch_repository.dart';
import 'package:pulso/data/repositories/vehicle_repository.dart';
import 'package:pulso/domain/analysis/analysis_engine.dart';
import 'package:pulso/domain/entities/enums.dart';

/// Monta um `AnalysisEngine` com repositórios reais sobre SQLite em
/// memória — nenhum mock de repositório: o motor de análise é testado
/// contra o banco de verdade, igual à produção.
({
  AppDatabase db,
  AnalysisEngine engine,
  ReadingRepository readings,
  AnomalyRepository anomalies,
  BaselineRepository baselines,
}) _harness() {
  final db = AppDatabase(NativeDatabase.memory());
  final readings = LocalReadingRepository(db);
  final anomalies = LocalAnomalyRepository(db);
  final baselines = LocalBaselineRepository(db);
  final trendWatches = LocalTrendWatchRepository(db);
  final engine = AnalysisEngine(
    baselineRepository: baselines,
    anomalyRepository: anomalies,
    readingRepository: readings,
    trendWatchRepository: trendWatches,
  );
  return (
    db: db,
    engine: engine,
    readings: readings,
    anomalies: anomalies,
    baselines: baselines,
  );
}

Future<int> _newVehicleAndSession(AppDatabase db) async {
  final vehicle = await LocalVehicleRepository(db).create(
    vin: 'YV1MZ7B2XPB123456',
    apelido: 'Meu Volvo',
    modelo: 'V40 2019',
    ano: 2019,
    cilindradaL: 2.0,
    tipoCombustivel: FuelType.flex,
  );
  final session = await LocalSessionRepository(db).start(
    vehicleId: vehicle.id!,
    iniciadaEm: DateTime(2026, 1, 1),
    protocolo: 'ISO 15765-4 (CAN 11/500)',
    adaptador: 'ELM327 v1.5',
    origem: SessionOrigin.simulado,
  );
  return session.id!;
}

Future<int> _vehicleIdOfSession(AppDatabase db, int sessionId) async {
  final session = await LocalSessionRepository(db).byId(sessionId);
  return session!.vehicleId;
}

void main() {
  group('AnalysisEngine.processReading — pipeline básico', () {
    test('constrói a baseline com leituras normais e não gera anomalia',
        () async {
      final h = _harness();
      addTearDown(h.db.close);
      final sessionId = await _newVehicleAndSession(h.db);
      final vehicleId = await _vehicleIdOfSession(h.db, sessionId);

      for (var i = 0; i < 150; i++) {
        final reading = await h.readings.record(
          sessionId: sessionId,
          ts: DateTime(2026, 1, 1).add(Duration(seconds: i)),
          pidKey: 'coolant_temp',
          valor: 90 + (i % 3 - 1) * 0.5, // 89.5–90.5, ruído pequeno
          contexto: OperatingContext.rodovia,
        );
        await h.engine.processReading(
          vehicleId: vehicleId,
          sessionId: sessionId,
          reading: reading,
        );
      }

      final baseline = await h.baselines.find(
        vehicleId: vehicleId,
        pidKey: 'coolant_temp',
        contexto: OperatingContext.rodovia,
      );
      expect(baseline, isNotNull);
      expect(baseline!.n, 150);
      expect(baseline.media, closeTo(90, 0.2));

      final anomalies = await h.anomalies.forSession(sessionId);
      expect(anomalies, isEmpty);
    });

    test('leitura muito fora da baseline gera anomalia pontual depois do '
        'debounce (§12.4) e não contamina a baseline (§12.5)', () async {
      final h = _harness();
      addTearDown(h.db.close);
      final sessionId = await _newVehicleAndSession(h.db);
      final vehicleId = await _vehicleIdOfSession(h.db, sessionId);

      // baseline: 150 amostras bem apertadas em torno de 90°C
      for (var i = 0; i < 150; i++) {
        final reading = await h.readings.record(
          sessionId: sessionId,
          ts: DateTime(2026, 1, 1).add(Duration(seconds: i)),
          pidKey: 'coolant_temp',
          valor: 90 + (i % 3 - 1) * 0.3,
          contexto: OperatingContext.rodovia,
        );
        await h.engine.processReading(
          vehicleId: vehicleId,
          sessionId: sessionId,
          reading: reading,
        );
      }

      final baselineBefore = await h.baselines.find(
        vehicleId: vehicleId,
        pidKey: 'coolant_temp',
        contexto: OperatingContext.rodovia,
      );

      // 6 leituras de superaquecimento seguidas — 5 bastam pro debounce,
      // a 6ª confirma que o alerta permanece.
      for (var i = 0; i < 6; i++) {
        final reading = await h.readings.record(
          sessionId: sessionId,
          ts: DateTime(2026, 1, 1).add(Duration(seconds: 150 + i)),
          pidKey: 'coolant_temp',
          valor: 125,
          contexto: OperatingContext.rodovia,
        );
        await h.engine.processReading(
          vehicleId: vehicleId,
          sessionId: sessionId,
          reading: reading,
        );
      }

      final anomalies = await h.anomalies.forSession(sessionId);
      expect(anomalies, isNotEmpty);
      expect(anomalies.first.severidade, AnomalySeverity.critico);
      expect(anomalies.first.tipo, AnomalyType.pontual);

      final baselineAfter = await h.baselines.find(
        vehicleId: vehicleId,
        pidKey: 'coolant_temp',
        contexto: OperatingContext.rodovia,
      );
      // baseline não deve ter absorvido os 125°C
      expect(baselineAfter!.n, baselineBefore!.n);
      expect(baselineAfter.media, baselineBefore.media);
    });
  });

  group('AnalysisEngine — consumo como parâmetro de primeira classe (§12.7)',
      () {
    test('fuel_rate gera consumo_lh sempre, e consumo_kml só com o '
        'veículo em movimento', () async {
      final h = _harness();
      addTearDown(h.db.close);
      final sessionId = await _newVehicleAndSession(h.db);
      final vehicleId = await _vehicleIdOfSession(h.db, sessionId);

      // parado: consumo_lh sim, consumo_kml não (indefinido)
      final speedZero = await h.readings.record(
        sessionId: sessionId,
        ts: DateTime(2026, 1, 1),
        pidKey: 'vehicle_speed',
        valor: 0,
        contexto: OperatingContext.paradoQuente,
      );
      await h.engine.processReading(
          vehicleId: vehicleId, sessionId: sessionId, reading: speedZero);

      final fuelReadingParado = await h.readings.record(
        sessionId: sessionId,
        ts: DateTime(2026, 1, 1, 0, 0, 1),
        pidKey: 'fuel_rate',
        valor: 0.8,
        contexto: OperatingContext.paradoQuente,
      );
      await h.engine.processReading(
          vehicleId: vehicleId, sessionId: sessionId, reading: fuelReadingParado);

      var lh = await h.readings.forSession(sessionId, pidKey: 'consumo_lh');
      var kml = await h.readings.forSession(sessionId, pidKey: 'consumo_kml');
      expect(lh, hasLength(1));
      expect(lh.single.valor, 0.8);
      expect(kml, isEmpty);

      // em movimento: consumo_kml também é gerado
      final speedMoving = await h.readings.record(
        sessionId: sessionId,
        ts: DateTime(2026, 1, 1, 0, 0, 2),
        pidKey: 'vehicle_speed',
        valor: 90,
        contexto: OperatingContext.rodovia,
      );
      await h.engine.processReading(
          vehicleId: vehicleId, sessionId: sessionId, reading: speedMoving);

      final fuelReadingMoving = await h.readings.record(
        sessionId: sessionId,
        ts: DateTime(2026, 1, 1, 0, 0, 3),
        pidKey: 'fuel_rate',
        valor: 7.5,
        contexto: OperatingContext.rodovia,
      );
      await h.engine.processReading(
          vehicleId: vehicleId, sessionId: sessionId, reading: fuelReadingMoving);

      lh = await h.readings.forSession(sessionId, pidKey: 'consumo_lh');
      kml = await h.readings.forSession(sessionId, pidKey: 'consumo_kml');
      expect(lh, hasLength(2));
      expect(kml, hasLength(1));
      expect(kml.single.valor, closeTo(90 / 7.5, 1e-9));
    });
  });

  group('AnalysisEngine.finalizeSession — tendência sustentada (§12.5)', () {
    test('só registra tendência na 3ª sessão consecutiva desviada', () async {
      final h = _harness();
      addTearDown(h.db.close);
      final vehicle = await LocalVehicleRepository(h.db).create(
        vin: 'YV1MZ7B2XPB123456',
        apelido: 'Meu Volvo',
        modelo: 'V40 2019',
        ano: 2019,
        cilindradaL: 2.0,
        tipoCombustivel: FuelType.flex,
      );
      final sessionRepo = LocalSessionRepository(h.db);

      Future<int> newSession() async {
        final s = await sessionRepo.start(
          vehicleId: vehicle.id!,
          iniciadaEm: DateTime(2026, 1, 1),
          protocolo: 'ISO 15765-4 (CAN 11/500)',
          adaptador: 'ELM327 v1.5',
          origem: SessionOrigin.simulado,
        );
        return s.id!;
      }

      // Sessão 0: constrói a baseline em torno de 90°C, bem apertada.
      final baselineSession = await newSession();
      for (var i = 0; i < 150; i++) {
        final reading = await h.readings.record(
          sessionId: baselineSession,
          ts: DateTime(2026, 1, 1).add(Duration(seconds: i)),
          pidKey: 'coolant_temp',
          valor: 90 + (i % 3 - 1) * 0.2,
          contexto: OperatingContext.rodovia,
        );
        await h.engine.processReading(
          vehicleId: vehicle.id!,
          sessionId: baselineSession,
          reading: reading,
        );
      }
      await h.engine.finalizeSession(
          vehicleId: vehicle.id!, sessionId: baselineSession);

      // 3 sessões seguidas com EWMA desviada (~93°C, > 1,5σ da baseline),
      // mas cada leitura sozinha dentro da faixa de detecção pontual —
      // não deve gerar `pontual`, só `tendencia` na 3ª.
      for (var s = 0; s < 3; s++) {
        final sessionId = await newSession();
        for (var i = 0; i < 20; i++) {
          final reading = await h.readings.record(
            sessionId: sessionId,
            ts: DateTime(2026, 1, 2 + s).add(Duration(seconds: i)),
            pidKey: 'coolant_temp',
            valor: 93 + (i % 3 - 1) * 0.2,
            contexto: OperatingContext.rodovia,
          );
          await h.engine.processReading(
            vehicleId: vehicle.id!,
            sessionId: sessionId,
            reading: reading,
          );
        }
        await h.engine.finalizeSession(
            vehicleId: vehicle.id!, sessionId: sessionId);

        final anomalies = await h.anomalies.forSession(sessionId);
        final trendAnomalies =
            anomalies.where((a) => a.tipo == AnomalyType.tendencia);

        if (s < 2) {
          expect(trendAnomalies, isEmpty, reason: 'sessão ${s + 1} de 3');
        } else {
          expect(trendAnomalies, isNotEmpty, reason: 'sessão 3 de 3');
        }
      }
    });
  });

  group('Motor de análise contra os perfis do simulador (§15, §18)', () {
    test('perfil superaquecimento dispara anomalia; perfil normal, não',
        () async {
      final h = _harness();
      addTearDown(h.db.close);
      final sessionId = await _newVehicleAndSession(h.db);
      final vehicleId = await _vehicleIdOfSession(h.db, sessionId);

      final normalVehicle = MockVehicle(profile: MockProfile.normal);

      // Constrói a baseline com o modelo físico real do simulador em
      // marcha normal, amostrando o aquecimento gradual até estabilizar
      // (~90°C) — 150 pontos ao longo de 15 minutos simulados.
      for (var i = 0; i < 150; i++) {
        final t = i * 6.0; // 0..894s
        final reading = await h.readings.record(
          sessionId: sessionId,
          ts: DateTime(2026, 1, 1).add(Duration(seconds: t.round())),
          pidKey: 'coolant_temp',
          valor: normalVehicle.coolantTempC(t),
          contexto: OperatingContext.paradoQuente,
        );
        await h.engine.processReading(
          vehicleId: vehicleId,
          sessionId: sessionId,
          reading: reading,
        );
      }

      final anomaliesAfterBaseline = await h.anomalies.forSession(sessionId);
      expect(
        anomaliesAfterBaseline,
        isEmpty,
        reason: 'perfil normal não deveria disparar nada (§18)',
      );

      // Agora injeta leituras do perfil superaquecimento — a mesma curva
      // física, mas convergindo pra ~128°C em vez de ~90°C.
      final overheatingVehicle = MockVehicle(profile: MockProfile.superaquecimento);
      for (var i = 0; i < 10; i++) {
        final t = 900.0 + i * 30; // depois de já ter estabilizado quente
        final reading = await h.readings.record(
          sessionId: sessionId,
          ts: DateTime(2026, 1, 1).add(Duration(seconds: (900 + i).round())),
          pidKey: 'coolant_temp',
          valor: overheatingVehicle.coolantTempC(t),
          contexto: OperatingContext.paradoQuente,
        );
        await h.engine.processReading(
          vehicleId: vehicleId,
          sessionId: sessionId,
          reading: reading,
        );
      }

      final anomaliesAfterOverheat = await h.anomalies.forSession(sessionId);
      expect(
        anomaliesAfterOverheat,
        isNotEmpty,
        reason: 'perfil superaquecimento deveria disparar anomalia (§18)',
      );
      expect(
        anomaliesAfterOverheat.every((a) => a.pidKey == 'coolant_temp'),
        isTrue,
      );
    });
  });
}
