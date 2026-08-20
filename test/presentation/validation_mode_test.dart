import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulso/data/db/database.dart';
import 'package:pulso/data/obd/elm327/elm327_client.dart';
import 'package:pulso/data/obd/pids/pid_decoder.dart';
import 'package:pulso/data/obd/sampling/sampling_scheduler.dart';
import 'package:pulso/data/obd/transport/mock_transport.dart';
import 'package:pulso/data/repositories/reading_repository.dart';
import 'package:pulso/data/repositories/session_repository.dart';
import 'package:pulso/data/repositories/vehicle_repository.dart';
import 'package:pulso/domain/entities/enums.dart';
import 'package:pulso/presentation/connection/connection_controller.dart';
import 'package:pulso/presentation/connection/connection_state.dart';
import 'package:pulso/presentation/providers/active_session_controller.dart';
import 'package:pulso/presentation/providers/app_providers.dart';
import 'package:pulso/presentation/validation/validation_mode_screen.dart';

/// Fixa `connectionControllerProvider` num `ConnectionEstablished` já
/// pronto — mesmo padrão de `_FailedController` em connection_flow_test.dart
/// (sobrescrever só `build()`).
class _FixedConnectionController extends ConnectionController {
  _FixedConnectionController(this._state);
  final ObdConnectionState _state;

  @override
  ObdConnectionState build() => _state;
}

/// Fixa `activeSessionProvider` numa sessão já aberta, sem passar pelo
/// `startFor` real (que dependeria de descoberta de PID e do agendador
/// rodando) — os métodos herdados (`setValidationMode`, `stop`) continuam
/// os de verdade, só o estado inicial é substituído.
class _FixedActiveSessionController extends ActiveSessionController {
  _FixedActiveSessionController(this._initial);
  final ActiveSession _initial;

  @override
  ActiveSession? build() {
    ref.onDispose(() => _initial.scheduler.stop());
    return _initial;
  }
}

void main() {
  group('ValidationModeScreen (item 16, RF22)', () {
    testWidgets(
        'liga o modo de validação e mostra o quadro capturado na lista',
        (tester) async {
      final transport = MockTransport();
      await transport.connect();
      final client = Elm327Client(transport);

      // Mesma dança de item 14 (test/presentation/diagnostics_test.dart):
      // o handshake usa Timer reais do MockTransport, e um `await` direto
      // aqui — antes de existir árvore de widget bombeando o relógio
      // falso — trava pelo timeout inteiro do teste.
      final handshakeFuture = client.handshake();
      for (var i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      final handshakeResult = await handshakeFuture;
      expect(handshakeResult.isOk, isTrue);

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

      // Nunca `.start()`-ado: este teste dirige o tráfego manualmente
      // (abaixo), só precisa existir pra satisfazer o campo obrigatório
      // de `ActiveSession`.
      final scheduler = SamplingScheduler(
        client: client,
        readingRepository: LocalReadingRepository(db),
        supportedCatalog: const [],
      );

      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          connectionControllerProvider.overrideWith(
            () => _FixedConnectionController(
              ConnectionEstablished(
                protocolDescription: 'ISO 15765-4 (CAN 11/500)',
                transport: transport,
                client: client,
              ),
            ),
          ),
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
          child: const MaterialApp(home: ValidationModeScreen()),
        ),
      );
      await tester.pump();

      expect(find.text('Modo de validação'), findsWidgets);
      expect(tester.widget<Switch>(find.byType(Switch)).value, isFalse);
      expect(
        find.text('Ligue para começar a gravar o tráfego bruto desta sessão.'),
        findsOneWidget,
      );

      await tester.tap(find.byType(Switch));
      await tester.pump();
      // `setHeadersEnabled` manda ATH1 pelo mesmo transporte com latência
      // real simulada (§13: 30–80 ms) — precisa de ciclos de pump com
      // duração pra resolver.
      for (var i = 0; i < 15; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      expect(tester.widget<Switch>(find.byType(Switch)).value, isTrue);
      expect(find.text('Nenhum quadro capturado ainda.'), findsOneWidget);

      // Dispara tráfego real pelo client — não há agendador rodando neste
      // teste, então a leitura é acionada manualmente. `onRawFrame` já
      // está armado (ligado dentro de `setValidationMode`), então esta
      // consulta é quem gera o quadro que o teste procura na lista.
      final def = findPidByKey('engine_rpm')!;
      unawaited(client.readPid(def));
      for (var i = 0; i < 15; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      expect(find.text('010C'), findsOneWidget);
      expect(find.text('Nenhum quadro capturado ainda.'), findsNothing);

      // Desmonta explicitamente antes do teste acabar: a lista observa um
      // stream reativo do Drift (`watchForSession`), e cancelar essa
      // inscrição agenda seu próprio Timer.zero de limpeza (mesmo motivo
      // documentado em connection_flow_test.dart) — sem isso,
      // `flutter_test` reprova o teste na verificação final por "Timer
      // ainda pendente", mesmo com todas as asserções acima corretas.
      await tester.pumpWidget(const SizedBox());
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 1));
      }
    });
  });
}
