import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulso/data/db/database.dart';
import 'package:pulso/data/obd/elm327/elm327_client.dart';
import 'package:pulso/data/obd/sampling/sampling_scheduler.dart';
import 'package:pulso/data/obd/transport/mock_transport.dart';
import 'package:pulso/data/repositories/reading_repository.dart';
import 'package:pulso/data/repositories/session_repository.dart';
import 'package:pulso/data/repositories/vehicle_repository.dart';
import 'package:pulso/domain/entities/enums.dart';
import 'package:pulso/presentation/driving/driving_mode_disclaimer.dart';
import 'package:pulso/presentation/driving/driving_mode_screen.dart';
import 'package:pulso/presentation/providers/active_session_controller.dart';
import 'package:pulso/presentation/providers/app_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Fixa `activeSessionProvider` numa sessão já aberta, sem passar pelo
/// `startFor` real — mesmo padrão de test/presentation/validation_mode_test.dart.
class _FixedActiveSessionController extends ActiveSessionController {
  _FixedActiveSessionController(this._initial);
  final ActiveSession _initial;

  @override
  ActiveSession? build() {
    ref.onDispose(() => _initial.scheduler.stop());
    return _initial;
  }
}

final _navigatorKey = GlobalKey<NavigatorState>();

void main() {
  group('DrivingModeScreen (item 18, §16)', () {
    testWidgets('mostra os quatro números e sai com toque duplo', (tester) async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);

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
        iniciadaEm: DateTime(2026, 8, 20, 9),
        protocolo: 'ISO 15765-4 (CAN 11/500)',
        adaptador: 'ELM327',
        origem: SessionOrigin.simulado,
      );

      final readingRepo = LocalReadingRepository(db);
      final now = DateTime(2026, 8, 20, 9, 5);
      for (final entry in {
        'vehicle_speed': 62.0,
        'engine_rpm': 1840.0,
        'coolant_temp': 92.0,
        'consumo_kml': 11.0,
      }.entries) {
        await readingRepo.record(
          sessionId: session.id!,
          ts: now,
          pidKey: entry.key,
          valor: entry.value,
          contexto: OperatingContext.urbano,
        );
      }

      // Nunca `.start()`-ado: este teste não dirige tráfego OBD nenhum, só
      // precisa existir pra satisfazer o campo obrigatório de `ActiveSession`.
      final scheduler = SamplingScheduler(
        client: Elm327Client(MockTransport()),
        readingRepository: readingRepo,
        supportedCatalog: const [],
      );

      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          activeSessionProvider.overrideWith(
            () => _FixedActiveSessionController(
              ActiveSession(
                vehicleId: vehicle.id!,
                sessionId: session.id!,
                scheduler: scheduler,
                supportedCatalog: const [],
              ),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            navigatorKey: _navigatorKey,
            home: const Scaffold(body: Center(child: Text('painel'))),
          ),
        ),
      );
      await tester.pump();

      _navigatorKey.currentState!.push(
        MaterialPageRoute<void>(builder: (_) => const DrivingModeScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.text('VELOCIDADE'), findsOneWidget);
      expect(find.text('62'), findsOneWidget);
      expect(find.text('ROTAÇÃO'), findsOneWidget);
      expect(find.text('1840'), findsOneWidget);
      expect(find.text('MOTOR'), findsOneWidget);
      expect(find.text('92'), findsOneWidget);
      expect(find.text('CONSUMO'), findsOneWidget);
      expect(find.text('11'), findsOneWidget);
      expect(find.text('TELA TRAVADA · TOQUE DUAS VEZES PARA SAIR'), findsOneWidget);
      expect(find.text('painel'), findsNothing);

      // Dois toques dentro da janela de double-tap do Flutter — um único
      // `tap()` não deveria sair da tela (é o ponto de "trava").
      await tester.tap(find.byType(DrivingModeScreen));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.byType(DrivingModeScreen));
      await tester.pumpAndSettle();

      expect(find.text('painel'), findsOneWidget);
    });
  });

  group('showDrivingModeDisclaimerIfNeeded (§16)', () {
    testWidgets('mostra uma vez só, persistindo entre chamadas', (tester) async {
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showDrivingModeDisclaimerIfNeeded(context),
              child: const Text('abrir'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();
      expect(find.text('Antes de dirigir'), findsOneWidget);

      await tester.tap(find.text('Entendi'));
      await tester.pumpAndSettle();
      expect(find.text('Antes de dirigir'), findsNothing);

      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();
      expect(find.text('Antes de dirigir'), findsNothing);
    });
  });
}
