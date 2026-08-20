import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulso/data/db/database.dart';
import 'package:pulso/presentation/connection/connection_controller.dart';
import 'package:pulso/presentation/connection/connection_flow_screen.dart';
import 'package:pulso/presentation/connection/connection_state.dart';
import 'package:pulso/presentation/providers/active_session_controller.dart';
import 'package:pulso/presentation/providers/app_providers.dart';

Widget _app() => const ProviderScope(
      child: MaterialApp(home: ConnectionFlowScreen()),
    );

/// Banco em memória — evita que a sessão pós-conexão (ActiveSessionController)
/// bata no `path_provider` real, que não tem implementação de plataforma
/// em teste de widget.
Widget _appWithInMemoryDb() => ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(AppDatabase(NativeDatabase.memory())),
      ],
      child: const MaterialApp(home: ConnectionFlowScreen()),
    );

void main() {
  group('ConnectionFlowScreen (item 11)', () {
    testWidgets('tela de abertura mostra os dois caminhos de entrada',
        (tester) async {
      await tester.pumpWidget(_app());
      await tester.pump();

      expect(find.text('PULSO'), findsOneWidget);
      expect(find.text('CONECTAR UM ADAPTADOR'), findsOneWidget);
      expect(find.text('VER EM MODO DEMONSTRAÇÃO'), findsOneWidget);
    });

    testWidgets('modo demonstração conecta de ponta a ponta contra o mock '
        'e chega no painel (item 12)', (tester) async {
      await tester.pumpWidget(_appWithInMemoryDb());
      await tester.pump();

      await tester.tap(find.text('VER EM MODO DEMONSTRAÇÃO'));
      await tester.pump(); // entra em ConnectionHandshaking

      expect(find.byType(CircularProgressIndicator), findsWidgets);

      // Não dá pra usar pumpAndSettle: uma vez conectado, o painel ao vivo
      // liga um Timer.periodic real (item 8) que nunca "assenta" sozinho.
      // Avança o tempo em passos limitados até o handshake + descoberta
      // de PIDs (item 6) terminarem.
      for (var i = 0; i < 30; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      expect(find.text('Conectado'), findsOneWidget);
      expect(find.textContaining('CAN'), findsOneWidget);
      expect(find.text('RPM'), findsOneWidget);

      // Para o agendador explicitamente ANTES de desmontar — parar só via
      // dispose do ProviderScope corre risco de deixar um comando ELM327
      // em voo (com seu próprio timeout pendente) bem no instante do
      // corte. Parando aqui, o que sobra são só os timers já em vias de
      // resolver, que os pumps seguintes dão conta de assentar.
      final container = ProviderScope.containerOf(
        tester.element(find.byType(ConnectionFlowScreen)),
      );
      await container.read(activeSessionProvider.notifier).stop();
      for (var i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Desmonta a árvore explicitamente: derruba o ProviderScope e as
      // streams do Drift ainda inscritas nos providers do painel (cada
      // uma agenda seu próprio Timer.zero de limpeza ao cancelar — o
      // painel observa ~8 streams, então precisa de mais de um pump pra
      // essa cascata de cancelamento assentar de vez).
      await tester.pumpWidget(const SizedBox());
      // Precisa de duração explícita: um pump() sem argumento não avança
      // o relógio fake, e um Timer de duração zero só dispara quando o
      // relógio avança — mesmo que seja 1ms.
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 1));
      }
    });

    testWidgets('buscar adaptador mostra os dispositivos do MockDeviceScanner',
        (tester) async {
      await tester.pumpWidget(_app());
      await tester.pump();

      await tester.tap(find.text('CONECTAR UM ADAPTADOR'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('OBDII'), findsOneWidget);
      expect(find.text('V-LINK'), findsOneWidget);
      expect(find.text('HC-05'), findsOneWidget);
    });

    testWidgets('tela de erro mostra título, motivo e passos numerados',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            connectionControllerProvider.overrideWith(_FailedController.new),
          ],
          child: const MaterialApp(home: ConnectionFlowScreen()),
        ),
      );
      await tester.pump();

      expect(find.text('Conexão perdida'), findsOneWidget);
      expect(find.text('TENTE NESTA ORDEM'), findsOneWidget);
      expect(find.text('TENTAR DE NOVO'), findsOneWidget);
    });
  });
}

class _FailedController extends ConnectionController {
  @override
  ObdConnectionState build() =>
      const ConnectionFailed(ConnectionErrorKind.lostConnection);
}
