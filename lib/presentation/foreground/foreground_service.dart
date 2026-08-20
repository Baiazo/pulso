import 'dart:io';

import 'package:flutter_foreground_task/flutter_foreground_task.dart';

import '../../data/foreground/collection_task_handler.dart';

/// Liga o serviço em primeiro plano (item 17, RNF10) — chamado quando uma
/// sessão de coleta começa. Pede a permissão de notificação primeiro: a
/// partir da API 33, sem ela a notificação do serviço não aparece e o
/// RNF10 falha silenciosamente (o processo até sobrevive, mas o motorista
/// não vê que a coleta continua rodando).
Future<void> startCollectionForegroundService() async {
  // Best-effort: roda em teste de widget (sem canal de plataforma real,
  // MissingPluginException) e em desktop/web (plugin é Android/iOS
  // apenas) — em nenhum dos dois casos falhar aqui deveria travar a
  // conexão (RNF02). O serviço em si é reforço de sobrevivência em
  // segundo plano, não algo que a sessão dependa pra funcionar.
  try {
    if (Platform.isAndroid || Platform.isIOS) {
      final permission = await FlutterForegroundTask.checkNotificationPermission();
      if (permission != NotificationPermission.granted) {
        await FlutterForegroundTask.requestNotificationPermission();
      }
    }

    if (await FlutterForegroundTask.isRunningService) {
      await FlutterForegroundTask.restartService();
      return;
    }

    await FlutterForegroundTask.startService(
      serviceId: 1,
      notificationTitle: 'Pulso está coletando',
      notificationText: 'Lendo o veículo em segundo plano. Toque para voltar ao app.',
      callback: startCollectionTaskCallback,
    );
  } catch (_) {
    // Sem plataforma suportada ou sem canal disponível — segue sem o
    // serviço; a coleta em si (SamplingScheduler) não depende dele.
  }
}

/// Desliga o serviço — chamado quando a sessão termina (item 17, RNF10):
/// nada de notificação nem de processo protegido sobrando depois que a
/// coleta já acabou. Mesmo motivo do try/catch acima.
Future<void> stopCollectionForegroundService() async {
  try {
    await FlutterForegroundTask.stopService();
  } catch (_) {}
}
