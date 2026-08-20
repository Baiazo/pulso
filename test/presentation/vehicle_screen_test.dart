import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulso/data/db/database.dart';
import 'package:pulso/domain/entities/enums.dart';
import 'package:pulso/presentation/providers/app_providers.dart';
import 'package:pulso/presentation/vehicle/vehicle_screen.dart';

void main() {
  group('VehicleScreen (item 15)', () {
    testWidgets('sem veículo mostra o estado vazio', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [databaseProvider.overrideWithValue(AppDatabase(NativeDatabase.memory()))],
          child: const MaterialApp(home: VehicleScreen()),
        ),
      );
      await tester.pump();

      expect(find.text('Nenhum veículo configurado ainda.'), findsOneWidget);
    });

    testWidgets('mostra dados do veículo e progresso de calibração', (tester) async {
      final db = AppDatabase(NativeDatabase.memory());
      final container = ProviderContainer(overrides: [databaseProvider.overrideWithValue(db)]);
      addTearDown(container.dispose);

      final vehicleRepo = container.read(vehicleRepositoryProvider);
      final sessionRepo = container.read(sessionRepositoryProvider);
      final baselineRepo = container.read(baselineRepositoryProvider);

      final vehicle = await vehicleRepo.create(
        vin: 'YV1MZ7B2XPB123456',
        apelido: 'Meu Volvo',
        modelo: 'Volvo V40 2019',
        ano: 2019,
        cilindradaL: 2.0,
        tipoCombustivel: FuelType.flex,
      );
      await vehicleRepo.updateSupportedPids(vehicle.id!, [0x0C, 0x0D]);

      final finished = await sessionRepo.start(
        vehicleId: vehicle.id!,
        iniciadaEm: DateTime(2026, 3, 12, 8, 0),
        protocolo: 'ISO 15765-4 (CAN 11/500)',
        adaptador: 'ELM327',
        origem: SessionOrigin.simulado,
      );
      await sessionRepo.end(
        finished.id!,
        encerradaEm: DateTime(2026, 3, 12, 8, 30),
        distanciaKm: 15.0,
        consumoMedioKml: 11.0,
      );

      await sessionRepo.start(
        vehicleId: vehicle.id!,
        iniciadaEm: DateTime(2026, 8, 15, 9, 0),
        protocolo: 'ISO 15765-4 (CAN 11/500)',
        adaptador: 'ELM327',
        origem: SessionOrigin.simulado,
      );

      await baselineRepo.upsert(
        vehicleId: vehicle.id!,
        pidKey: 'engine_rpm',
        contexto: OperatingContext.urbano,
        n: 62,
        media: 1800,
        m2: 4000,
        atualizadoEm: DateTime(2026, 8, 15, 9, 10),
      );
      await baselineRepo.upsert(
        vehicleId: vehicle.id!,
        pidKey: 'engine_rpm',
        contexto: OperatingContext.paradoQuente,
        n: 150,
        media: 850,
        m2: 900,
        atualizadoEm: DateTime(2026, 8, 15, 9, 10),
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: VehicleScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Volvo V40 2019'), findsOneWidget);
      expect(find.text('YV1MZ7B2XPB123456'), findsOneWidget);
      expect(find.text('62%'), findsOneWidget);

      // A seção "PERFIL" fica abaixo da dobra na altura de tela do teste —
      // rola até o fim pra montar a barra "Perfil parado".
      await tester.drag(find.byType(Scrollable), const Offset(0, -600));
      await tester.pumpAndSettle();

      expect(find.text('Confiável'), findsOneWidget);
    });
  });
}
