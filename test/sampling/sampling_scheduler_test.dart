import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulso/data/db/database.dart';
import 'package:pulso/data/obd/elm327/elm327_client.dart';
import 'package:pulso/data/obd/pids/supported_pids.dart';
import 'package:pulso/data/obd/sampling/sampling_scheduler.dart';
import 'package:pulso/data/obd/transport/mock/mock_vehicle.dart';
import 'package:pulso/data/obd/transport/mock_transport.dart';
import 'package:pulso/data/repositories/reading_repository.dart';
import 'package:pulso/data/repositories/session_repository.dart';
import 'package:pulso/data/repositories/vehicle_repository.dart';
import 'package:pulso/domain/entities/enums.dart';

void main() {
  group('SamplingScheduler — gravação de sessão ponta a ponta contra o mock '
      '(item 8, §17)', () {
    test('rodízio por prioridade grava alta todo ciclo, media a cada 5, '
        'baixa a cada 30 (§10)', () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);

      // latência mínima: este teste dispara dezenas de comandos em
      // sequência (fila serial), e a realidade de 30-80ms/comando (§13)
      // faria o teste levar minutos sem exercitar nada a mais.
      final transport = MockTransport(
        profile: MockProfile.normal,
        minLatencyMs: 0,
        maxLatencyMs: 1,
      );
      await transport.connect();
      final client = Elm327Client(transport);
      await client.handshake();

      final discovery = await discoverSupportedPids(client);
      final supportedCatalog = filterSupportedCatalog(discovery.valueOrNull!);

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
        iniciadaEm: DateTime.now(),
        protocolo: 'ISO 15765-4 (CAN 11/500)',
        adaptador: 'ELM327 v1.5',
        origem: SessionOrigin.simulado,
      );

      final readingRepository = LocalReadingRepository(db);
      final scheduler = SamplingScheduler(
        client: client,
        readingRepository: readingRepository,
        supportedCatalog: supportedCatalog,
      );

      scheduler.attachSession(session.id!);
      // 35 ciclos: cobre alta (todo ciclo), media (%5) e baixa (%30) pelo
      // menos duas vezes cada uma das duas primeiras.
      for (var i = 0; i < 35; i++) {
        await scheduler.tick();
      }
      scheduler.stop();

      final rpmReadings =
          await readingRepository.forSession(session.id!, pidKey: 'engine_rpm');
      expect(rpmReadings, hasLength(35), reason: 'alta: todo ciclo');

      final ectReadings =
          await readingRepository.forSession(session.id!, pidKey: 'coolant_temp');
      expect(ectReadings, hasLength(7), reason: 'media: ciclos 0,5,...,30 = 7');

      final voltageReadings = await readingRepository.forSession(
        session.id!,
        pidKey: 'control_module_voltage',
      );
      expect(voltageReadings, hasLength(2), reason: 'baixa: ciclos 0 e 30');

      // sobDemanda nunca entra no rodízio regular (§10)
      final runTimeReadings = await readingRepository.forSession(
        session.id!,
        pidKey: 'run_time_since_start',
      );
      expect(runTimeReadings, isEmpty);
    });

    test('contexto persistido bate com velocidade/ECT conhecidos no momento '
        'da leitura (§12.2)', () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);

      // latência mínima: este teste dispara dezenas de comandos em
      // sequência (fila serial), e a realidade de 30-80ms/comando (§13)
      // faria o teste levar minutos sem exercitar nada a mais.
      final transport = MockTransport(
        profile: MockProfile.normal,
        minLatencyMs: 0,
        maxLatencyMs: 1,
      );
      await transport.connect();
      final client = Elm327Client(transport);
      await client.handshake();

      final discovery = await discoverSupportedPids(client);
      final supportedCatalog = filterSupportedCatalog(discovery.valueOrNull!);

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
        iniciadaEm: DateTime.now(),
        protocolo: 'ISO 15765-4 (CAN 11/500)',
        adaptador: 'ELM327 v1.5',
        origem: SessionOrigin.simulado,
      );

      final readingRepository = LocalReadingRepository(db);
      final scheduler = SamplingScheduler(
        client: client,
        readingRepository: readingRepository,
        supportedCatalog: supportedCatalog,
      );

      scheduler.attachSession(session.id!);
      // perfil "normal" fica parado (speed=0) e recém-ligado (ECT baixo)
      // — os ciclos rodam quase instantaneamente no teste, então o motor
      // não teve tempo de esquentar: parado_frio.
      await scheduler.tick();
      scheduler.stop();

      final speedReadings = await readingRepository.forSession(
        session.id!,
        pidKey: 'vehicle_speed',
      );
      expect(speedReadings.single.contexto, OperatingContext.paradoFrio);
    });

    test('effectiveHzByPid mede taxa não-negativa para PIDs amostrados',
        () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);

      // latência mínima: este teste dispara dezenas de comandos em
      // sequência (fila serial), e a realidade de 30-80ms/comando (§13)
      // faria o teste levar minutos sem exercitar nada a mais.
      final transport = MockTransport(
        profile: MockProfile.normal,
        minLatencyMs: 0,
        maxLatencyMs: 1,
      );
      await transport.connect();
      final client = Elm327Client(transport);
      await client.handshake();

      final discovery = await discoverSupportedPids(client);
      final supportedCatalog = filterSupportedCatalog(discovery.valueOrNull!);

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
        iniciadaEm: DateTime.now(),
        protocolo: 'ISO 15765-4 (CAN 11/500)',
        adaptador: 'ELM327 v1.5',
        origem: SessionOrigin.simulado,
      );

      final scheduler = SamplingScheduler(
        client: client,
        readingRepository: LocalReadingRepository(db),
        supportedCatalog: supportedCatalog,
      );

      scheduler.attachSession(session.id!);
      for (var i = 0; i < 5; i++) {
        await scheduler.tick();
      }
      scheduler.stop();

      final hz = scheduler.effectiveHzByPid();
      expect(hz, isNotEmpty);
      expect(hz['engine_rpm'], isNotNull);
      for (final value in hz.values) {
        expect(value, greaterThanOrEqualTo(0));
      }
    });
  });
}
