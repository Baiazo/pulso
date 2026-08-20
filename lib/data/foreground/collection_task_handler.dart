import 'package:flutter_foreground_task/flutter_foreground_task.dart';

/// Handler mínimo — o serviço em primeiro plano existe só pra impedir o
/// Android de matar o isolate principal com a tela apagada ou o app em
/// segundo plano (item 17, RNF10). A coleta em si é o `Timer.periodic` do
/// `SamplingScheduler` (item 8), que já roda nesse mesmo isolate e não
/// precisa de nenhuma lógica extra aqui — o handler só precisa existir
/// pra satisfazer o contrato do plugin.
class CollectionTaskHandler extends TaskHandler {
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {}

  @override
  void onRepeatEvent(DateTime timestamp) {}

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {}
}

/// Função de nível superior exigida pelo plugin (não pode ser método de
/// instância nem closure) — roda antes do handler existir, é o que o
/// registra.
@pragma('vm:entry-point')
void startCollectionTaskCallback() {
  FlutterForegroundTask.setTaskHandler(CollectionTaskHandler());
}
