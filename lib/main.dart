import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterForegroundTask.initCommunicationPort();
  _initForegroundTask();
  runApp(const ProviderScope(child: PulsoApp()));
}

/// Configuração do serviço em primeiro plano (item 17, RNF10) — só
/// registro, não liga o serviço ainda; isso acontece quando uma sessão de
/// coleta começa de verdade (`ActiveSessionController.startFor`).
void _initForegroundTask() {
  FlutterForegroundTask.init(
    androidNotificationOptions: AndroidNotificationOptions(
      channelId: 'pulso_coleta',
      channelName: 'Coleta em andamento',
      channelDescription: 'Aparece enquanto o Pulso está lendo o veículo.',
      onlyAlertOnce: true,
    ),
    iosNotificationOptions: const IOSNotificationOptions(
      showNotification: false,
      playSound: false,
    ),
    foregroundTaskOptions: ForegroundTaskOptions(
      // Nada pra repetir: a coleta é o Timer.periodic do SamplingScheduler
      // (item 8), não algo que o TaskHandler precise reexecutar sozinho.
      eventAction: ForegroundTaskEventAction.nothing(),
      autoRunOnBoot: false,
      allowWakeLock: true,
      allowWifiLock: false,
    ),
  );
}
