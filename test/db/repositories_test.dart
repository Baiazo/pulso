import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulso/data/db/database.dart';
import 'package:pulso/data/repositories/anomaly_repository.dart';
import 'package:pulso/data/repositories/baseline_repository.dart';
import 'package:pulso/data/repositories/dtc_repository.dart';
import 'package:pulso/data/repositories/raw_frame_repository.dart';
import 'package:pulso/data/repositories/reading_repository.dart';
import 'package:pulso/data/repositories/session_repository.dart';
import 'package:pulso/data/repositories/vehicle_repository.dart';
import 'package:pulso/domain/entities/enums.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  test('cria o índice composto (session_id, pid_key, ts) em readings (§11)',
      () async {
    final rows = await db
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'index' "
          "AND name = 'idx_readings_session_pid_ts'",
        )
        .get();
    expect(rows, hasLength(1));
  });

  group('VehicleRepository', () {
    test('cria, busca por id e lista', () async {
      final repo = LocalVehicleRepository(db);
      final vehicle = await repo.create(
        vin: 'YV1MZ7B2XPB123456',
        apelido: 'Meu Volvo',
        modelo: 'V40 2019',
        ano: 2019,
        cilindradaL: 2.0,
        tipoCombustivel: FuelType.flex,
      );

      expect(vehicle.id, isNotNull);
      expect(vehicle.uuid, isNotEmpty);
      expect(vehicle.pidsSuportados, isEmpty);

      final fetched = await repo.byId(vehicle.id!);
      expect(fetched?.vin, 'YV1MZ7B2XPB123456');

      final all = await repo.all();
      expect(all, hasLength(1));
    });

    test('updateSupportedPids persiste a lista descoberta (§7.5)', () async {
      final repo = LocalVehicleRepository(db);
      final vehicle = await repo.create(
        vin: 'YV1MZ7B2XPB123456',
        apelido: 'Meu Volvo',
        modelo: 'V40 2019',
        ano: 2019,
        cilindradaL: 2.0,
        tipoCombustivel: FuelType.flex,
      );

      final updated =
          await repo.updateSupportedPids(vehicle.id!, [0x01, 0x0C, 0x0D]);
      expect(updated.pidsSuportados, [0x01, 0x0C, 0x0D]);

      final fetched = await repo.byId(vehicle.id!);
      expect(fetched?.pidsSuportados, [0x01, 0x0C, 0x0D]);
    });
  });

  group('SessionRepository', () {
    late int vehicleId;

    setUp(() async {
      final vehicle = await LocalVehicleRepository(db).create(
        vin: 'YV1MZ7B2XPB123456',
        apelido: 'Meu Volvo',
        modelo: 'V40 2019',
        ano: 2019,
        cilindradaL: 2.0,
        tipoCombustivel: FuelType.flex,
      );
      vehicleId = vehicle.id!;
    });

    test('inicia, encerra e lista por veículo', () async {
      final repo = LocalSessionRepository(db);
      final started = await repo.start(
        vehicleId: vehicleId,
        iniciadaEm: DateTime(2026, 1, 1, 8),
        protocolo: 'ISO 15765-4 (CAN 11/500)',
        adaptador: 'ELM327 v1.5',
        origem: SessionOrigin.real,
      );

      expect(started.emAndamento, isTrue);

      final ended = await repo.end(
        started.id!,
        encerradaEm: DateTime(2026, 1, 1, 8, 30),
        distanciaKm: 12.5,
        duracaoS: 1800,
        consumoMedioKml: 11.2,
      );

      expect(ended.emAndamento, isFalse);
      expect(ended.consumoMedioKml, 11.2);

      final list = await repo.forVehicle(vehicleId);
      expect(list, hasLength(1));
    });

    test('watchForVehicle emite de novo quando uma sessão é criada',
        () async {
      final repo = LocalSessionRepository(db);
      final emissions = <int>[];
      final sub = repo
          .watchForVehicle(vehicleId)
          .listen((sessions) => emissions.add(sessions.length));

      await pumpEventQueue();
      await repo.start(
        vehicleId: vehicleId,
        iniciadaEm: DateTime(2026, 1, 1),
        protocolo: 'ISO 15765-4 (CAN 11/500)',
        adaptador: 'ELM327 v1.5',
        origem: SessionOrigin.simulado,
      );
      await pumpEventQueue();

      await sub.cancel();
      expect(emissions, [0, 1]);
    });
  });

  group('ReadingRepository', () {
    late int sessionId;

    setUp(() async {
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
      sessionId = session.id!;
    });

    test('grava e lê de volta, filtrando por pid_key', () async {
      final repo = LocalReadingRepository(db);
      await repo.record(
        sessionId: sessionId,
        ts: DateTime(2026, 1, 1, 8, 0, 1),
        pidKey: 'engine_rpm',
        valor: 780,
        contexto: OperatingContext.paradoQuente,
      );
      await repo.record(
        sessionId: sessionId,
        ts: DateTime(2026, 1, 1, 8, 0, 2),
        pidKey: 'vehicle_speed',
        valor: 0,
        contexto: OperatingContext.paradoQuente,
      );

      final all = await repo.forSession(sessionId);
      expect(all, hasLength(2));

      final rpmOnly = await repo.forSession(sessionId, pidKey: 'engine_rpm');
      expect(rpmOnly, hasLength(1));
      expect(rpmOnly.single.valor, 780);
    });
  });

  group('DtcRepository', () {
    test('grava um DTC com freeze frame e lê de volta', () async {
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

      final repo = LocalDtcRepository(db);
      await repo.record(
        sessionId: session.id!,
        ts: DateTime(2026, 1, 1),
        codigo: 'P0420',
        tipo: DtcEventType.ativo,
        descricao: 'Eficiência do catalisador abaixo do limiar, banco 1',
        freezeFrame: {'engine_rpm': 2200, 'vehicle_speed': 80},
      );

      final events = await repo.forSession(session.id!);
      expect(events, hasLength(1));
      expect(events.single.freezeFrame['engine_rpm'], 2200);
    });
  });

  group('BaselineRepository', () {
    test('upsert cria na primeira vez e atualiza nas seguintes (Welford)',
        () async {
      final vehicle = await LocalVehicleRepository(db).create(
        vin: 'YV1MZ7B2XPB123456',
        apelido: 'Meu Volvo',
        modelo: 'V40 2019',
        ano: 2019,
        cilindradaL: 2.0,
        tipoCombustivel: FuelType.flex,
      );

      final repo = LocalBaselineRepository(db);
      final first = await repo.upsert(
        vehicleId: vehicle.id!,
        pidKey: 'engine_rpm',
        contexto: OperatingContext.paradoQuente,
        n: 1,
        media: 780,
        m2: 0,
        atualizadoEm: DateTime(2026, 1, 1),
      );

      final second = await repo.upsert(
        vehicleId: vehicle.id!,
        pidKey: 'engine_rpm',
        contexto: OperatingContext.paradoQuente,
        n: 2,
        media: 782,
        m2: 8,
        atualizadoEm: DateTime(2026, 1, 2),
      );

      expect(second.id, first.id); // mesma linha, não duplicou
      expect(second.n, 2);
      expect(second.variance, 8.0); // m2 / (n - 1)

      final all = await repo.forVehicle(vehicle.id!);
      expect(all, hasLength(1));
    });
  });

  group('AnomalyRepository', () {
    test('grava e lista em ordem decrescente de tempo', () async {
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

      final repo = LocalAnomalyRepository(db);
      await repo.record(
        sessionId: session.id!,
        ts: DateTime(2026, 1, 1, 8, 0),
        pidKey: 'coolant_temp',
        contexto: OperatingContext.rodovia,
        valor: 125,
        mediaEsperada: 90,
        desvioPadrao: 3,
        z: 11.6,
        severidade: AnomalySeverity.critico,
        tipo: AnomalyType.pontual,
      );
      await repo.record(
        sessionId: session.id!,
        ts: DateTime(2026, 1, 1, 8, 5),
        pidKey: 'coolant_temp',
        contexto: OperatingContext.rodovia,
        valor: 128,
        mediaEsperada: 90,
        desvioPadrao: 3,
        z: 12.6,
        severidade: AnomalySeverity.critico,
        tipo: AnomalyType.pontual,
      );

      final list = await repo.forSession(session.id!);
      expect(list, hasLength(2));
      expect(list.first.ts.isAfter(list.last.ts), isTrue);
    });
  });

  group('RawFrameRepository', () {
    test('grava e lê o tráfego bruto do modo de validação (RF22)', () async {
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

      final repo = LocalRawFrameRepository(db);
      await repo.record(
        sessionId: session.id!,
        ts: DateTime(2026, 1, 1),
        comando: '010C',
        respostaBruta: '7E8 410C1AF8',
      );

      final frames = await repo.forSession(session.id!);
      expect(frames, hasLength(1));
      expect(frames.single.respostaBruta, contains('410C1AF8'));
    });
  });
}
