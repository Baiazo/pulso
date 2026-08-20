import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulso/data/db/database.dart';
import 'package:pulso/data/obd/dtc/dtc_decoder.dart';
import 'package:pulso/data/obd/elm327/elm327_client.dart';
import 'package:pulso/data/obd/transport/mock_transport.dart';
import 'package:pulso/domain/entities/enums.dart';
import 'package:pulso/presentation/diagnostics/clear_dtcs_confirmation_screen.dart';
import 'package:pulso/presentation/diagnostics/dtc_detail_screen.dart';
import 'package:pulso/presentation/diagnostics/dtc_list_screen.dart';
import 'package:pulso/presentation/providers/app_providers.dart';

void main() {
  group('DtcListScreen (item 14, §9/§10)', () {
    testWidgets('lê o DTC ativo injetado, mostra o freeze frame no detalhe '
        'e apaga pelo fluxo de confirmação', (tester) async {
      // Perfil normal, não dtcAtivo: aquele perfil já nasce com um P0420
      // guardado (mock/mock_vehicle.dart), e o freeze frame do Modo 02 do
      // simulador é sempre o do primeiro DTC da lista (§13 — só modela um
      // buffer). Injetar sobre uma lista vazia garante que o freeze frame
      // lido abaixo é mesmo o que este teste injetou.
      final transport = MockTransport();
      await transport.connect();
      final client = Elm327Client(transport);

      // O handshake usa os Timer reais do MockTransport/Elm327Client — sem
      // nada pra avançar o relógio falso do teste de widget, um `await`
      // direto aqui trava pra sempre. Dispara sem esperar e bombeia o
      // tempo com `pump(duration)` até resolver, exatamente como o fluxo
      // de conexão de verdade (item 11) já faz dentro da árvore de
      // widget — aqui só não há árvore ainda.
      final handshakeFuture = client.handshake();
      for (var i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      final handshakeResult = await handshakeFuture;
      expect(handshakeResult.isOk, isTrue);

      transport.injectDtc(
        decodeDtc(0x01, 0x33), // P0133
        freezeFrame: const {
          'engine_rpm': 2380,
          'vehicle_speed': 78,
          'coolant_temp': 91,
          'engine_load': 46,
        },
      );

      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final container = ProviderContainer(
        overrides: [databaseProvider.overrideWithValue(db)],
      );
      addTearDown(container.dispose);
      final vehicle = await container.read(vehicleRepositoryProvider).create(
            vin: 'YV1MZ7B2XPB123456',
            apelido: 'Meu Volvo',
            modelo: 'V40 2019',
            ano: 2019,
            cilindradaL: 2.0,
            tipoCombustivel: FuelType.flex,
          );
      final session = await container.read(sessionRepositoryProvider).start(
            vehicleId: vehicle.id!,
            iniciadaEm: DateTime(2026, 8, 14, 9),
            protocolo: 'ISO 15765-4 (CAN 11/500)',
            adaptador: 'ELM327',
            origem: SessionOrigin.simulado,
          );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: DtcListScreen(client: client, sessionId: session.id!),
          ),
        ),
      );
      await tester.pump(); // dispara _refresh()
      for (var i = 0; i < 30; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      expect(find.text('ATIVO · 1'), findsOneWidget);
      expect(find.text('P0133'), findsOneWidget);

      await tester.tap(find.text('P0133'));
      await tester.pumpAndSettle();

      expect(find.byType(DtcDetailScreen), findsOneWidget);
      expect(find.text('2380'), findsOneWidget);
      expect(find.text('78'), findsOneWidget);
      expect(find.text('91'), findsOneWidget);
      expect(find.text('46'), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Apagar códigos'));
      await tester.pumpAndSettle();

      expect(find.byType(ClearDtcsConfirmationScreen), findsOneWidget);
      expect(find.text('Apagar os 1 códigos'), findsOneWidget);

      await tester.tap(find.text('Apagar os 1 códigos'));
      await tester.pump();
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      expect(find.text('Nenhuma falha guardada'), findsOneWidget);
    });
  });
}
