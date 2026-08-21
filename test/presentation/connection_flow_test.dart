import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulso/data/db/database.dart';
import 'package:pulso/data/obd/transport/device_scanner.dart';
import 'package:pulso/presentation/connection/connection_controller.dart';
import 'package:pulso/presentation/connection/connection_flow_screen.dart';
import 'package:pulso/presentation/connection/connection_state.dart';
import 'package:pulso/presentation/providers/active_session_controller.dart';
import 'package:pulso/presentation/providers/app_providers.dart';

Widget _app() => const ProviderScope(
      child: MaterialApp(home: ConnectionFlowScreen()),
    );

/// A varredura real (item 9) precisa de permissão de runtime e de rádio
/// Bluetooth de verdade — nenhum dos dois existe em teste de widget.
/// `deviceScannerProvider`/`bluetoothPermissionsProvider` existem
/// justamente pra poder sobrescrever os dois aqui, do mesmo jeito que
/// `databaseProvider` é sobrescrito pra fugir do `path_provider` real.
Widget _appWithMockScanner() => ProviderScope(
      overrides: [
        deviceScannerProvider.overrideWithValue(MockDeviceScanner()),
        bluetoothPermissionsProvider.overrideWithValue(() async => true),
      ],
      child: const MaterialApp(home: ConnectionFlowScreen()),
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
      await tester.pumpWidget(_appWithMockScanner());
      await tester.pump();

      await tester.tap(find.text('CONECTAR UM ADAPTADOR'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('OBDII'), findsOneWidget);
      expect(find.text('V-LINK'), findsOneWidget);
      expect(find.text('HC-05'), findsOneWidget);
    });

    testWidgets('a seta de voltar na busca de adaptador retorna pra tela de '
        'abertura', (tester) async {
      await tester.pumpWidget(_appWithMockScanner());
      await tester.pump();

      await tester.tap(find.text('CONECTAR UM ADAPTADOR'));
      await tester.pump();
      // Deixa os dois `Future.delayed` do MockDeviceScanner (500ms + 400ms)
      // resolverem antes de sair da tela — senão sobra Timer pendente na
      // desmontagem, mesmo que a resposta não importe mais pro teste.
      await tester.pump(const Duration(milliseconds: 1000));

      // Sem isso o usuário fica preso na busca — não há Navigator (a tela
      // de conexão é a raiz do app), então só a máquina de estados do
      // ConnectionController consegue tirar daqui.
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pump();

      expect(find.text('PULSO'), findsOneWidget);
      expect(find.text('CONECTAR UM ADAPTADOR'), findsOneWidget);
    });

    testWidgets(
        'sem permissão de Bluetooth (padrão de teste, sem canal de '
        'plataforma) mostra a tela de erro em vez de travar ou lançar',
        (tester) async {
      // Nenhuma sobrescrita: usa o `ensureBluetoothPermissions` de
      // verdade, que em teste de widget não tem canal de plataforma do
      // `permission_handler` — precisa resolver pra `false` de forma
      // limpa, não travar nem lançar (item 9, §14).
      await tester.pumpWidget(_app());
      await tester.pump();

      await tester.tap(find.text('CONECTAR UM ADAPTADOR'));
      // Sem handler de canal nenhum registrado, o pedido de permissão nem
      // lança nem resolve sozinho — só o timeout defensivo de
      // `ensureBluetoothPermissions` (30s) desbloqueia. Relógio falso: um
      // pump grande custa nada de verdade.
      await tester.pump(const Duration(seconds: 31));

      expect(find.text('Bluetooth indisponível'), findsOneWidget);
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
