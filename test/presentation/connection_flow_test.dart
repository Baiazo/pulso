import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulso/presentation/connection/connection_controller.dart';
import 'package:pulso/presentation/connection/connection_flow_screen.dart';
import 'package:pulso/presentation/connection/connection_state.dart';

Widget _app() => const ProviderScope(
      child: MaterialApp(home: ConnectionFlowScreen()),
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

    testWidgets('modo demonstração conecta de ponta a ponta contra o mock',
        (tester) async {
      await tester.pumpWidget(_app());
      await tester.pump();

      await tester.tap(find.text('VER EM MODO DEMONSTRAÇÃO'));
      await tester.pump(); // entra em ConnectionHandshaking

      expect(find.byType(CircularProgressIndicator), findsWidgets);

      // deixa o handshake real (contra o MockTransport) terminar
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.text('Conectado'), findsOneWidget);
      expect(find.textContaining('CAN'), findsOneWidget);
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
