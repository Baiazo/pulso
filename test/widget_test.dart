import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulso/app.dart';

void main() {
  testWidgets('PulsoApp sobe sem erro e mostra a tela de abertura', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: PulsoApp()));
    await tester.pump();

    expect(find.text('PULSO'), findsOneWidget);
    expect(find.text('CONECTAR UM ADAPTADOR'), findsOneWidget);
  });
}
