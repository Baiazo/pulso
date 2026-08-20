import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulso/data/db/database.dart';
import 'package:pulso/domain/entities/enums.dart';
import 'package:pulso/presentation/providers/app_providers.dart';
import 'package:pulso/presentation/trips/trip_detail_screen.dart';
import 'package:pulso/presentation/trips/trips_list_screen.dart';

/// Banco em memória — mesmo motivo do teste de conexão (item 11): evita
/// bater no `path_provider` real, sem implementação de plataforma aqui.
ProviderContainer _containerWithSeededTrip(AppDatabase db) {
  return ProviderContainer(overrides: [databaseProvider.overrideWithValue(db)]);
}

void main() {
  group('TripsListScreen (item 13)', () {
    testWidgets('sem veículo/sessão mostra o estado vazio', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [databaseProvider.overrideWithValue(AppDatabase(NativeDatabase.memory()))],
          child: const MaterialApp(home: TripsListScreen()),
        ),
      );
      await tester.pump();

      expect(find.text('Nenhuma viagem gravada'), findsOneWidget);
    });

    testWidgets('lista viagens concluídas, ignora a em andamento, e abre o detalhe ao tocar',
        (tester) async {
      final db = AppDatabase(NativeDatabase.memory());
      final container = _containerWithSeededTrip(db);
      addTearDown(container.dispose);

      final vehicleRepo = container.read(vehicleRepositoryProvider);
      final sessionRepo = container.read(sessionRepositoryProvider);
      final readingRepo = container.read(readingRepositoryProvider);

      final vehicle = await vehicleRepo.create(
        vin: 'YV1MZ7B2XPB123456',
        apelido: 'Meu Volvo',
        modelo: 'V40 2019',
        ano: 2019,
        cilindradaL: 2.0,
        tipoCombustivel: FuelType.flex,
      );

      final finished = await sessionRepo.start(
        vehicleId: vehicle.id!,
        iniciadaEm: DateTime(2026, 8, 10, 8, 0),
        protocolo: 'ISO 15765-4 (CAN 11/500)',
        adaptador: 'ELM327',
        origem: SessionOrigin.simulado,
      );
      await sessionRepo.end(
        finished.id!,
        encerradaEm: DateTime(2026, 8, 10, 8, 20),
        distanciaKm: 12.5,
        consumoMedioKml: 11.2,
      );
      for (var i = 0; i < 3; i++) {
        await readingRepo.record(
          sessionId: finished.id!,
          ts: DateTime(2026, 8, 10, 8, i),
          pidKey: 'vehicle_speed',
          valor: 40.0 + i,
          contexto: OperatingContext.urbano,
        );
      }

      // Sessão em andamento — não deve aparecer na lista (só finalizadas).
      await sessionRepo.start(
        vehicleId: vehicle.id!,
        iniciadaEm: DateTime(2026, 8, 11, 9, 0),
        protocolo: 'ISO 15765-4 (CAN 11/500)',
        adaptador: 'ELM327',
        origem: SessionOrigin.simulado,
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: TripsListScreen()),
        ),
      );
      await tester.pump();
      await tester.pump();

      expect(find.text('Viagens'), findsOneWidget);
      expect(find.textContaining('1 sessões'), findsOneWidget);
      expect(find.text('12.5 km'), findsOneWidget);
      expect(find.text('11.2 km/l'), findsOneWidget);

      await tester.tap(find.text('12.5 km'));
      await tester.pumpAndSettle();

      expect(find.byType(TripDetailScreen), findsOneWidget);
      expect(find.text('VELOCIDADE'), findsOneWidget);
      expect(find.text('ROTAÇÃO'), findsOneWidget);
    });
  });
}
