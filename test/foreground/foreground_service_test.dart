import 'package:flutter_test/flutter_test.dart';
import 'package:pulso/presentation/foreground/foreground_service.dart';

/// Sem canal de plataforma real em teste (nem em desktop/web, onde o
/// plugin não é suportado) — este é o cenário que quebrou item 17 na
/// primeira versão: `ActiveSessionController.startFor` travava esperando
/// esta chamada. As funções precisam ser best-effort e nunca lançar aqui.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('startCollectionForegroundService não lança sem canal de plataforma',
      () async {
    await expectLater(startCollectionForegroundService(), completes);
  });

  test('stopCollectionForegroundService não lança sem canal de plataforma',
      () async {
    await expectLater(stopCollectionForegroundService(), completes);
  });
}
