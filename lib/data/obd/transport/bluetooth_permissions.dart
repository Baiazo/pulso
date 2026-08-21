import 'package:flutter_bluetooth_serial_plus/flutter_bluetooth_serial_plus.dart';
import 'package:permission_handler/permission_handler.dart';

/// Tempo máximo esperando o canal de plataforma do `permission_handler`
/// responder ao pedido de permissão — generoso o bastante pra um usuário
/// de verdade ler o diálogo do sistema e decidir, mas com limite: sem
/// canal nenhum registrado (teste de widget; canal que nunca responde por
/// qualquer outro motivo), a chamada nem lança nem resolve sozinha — trava
/// pra sempre sem isto.
const _permissionRequestTimeout = Duration(seconds: 30);

/// Permissões de runtime pra varredura/conexão Bluetooth real (item 9,
/// RF01, §14) — declarar no manifesto não basta a partir da API 23, o
/// usuário precisa conceder em tempo de execução. Sem `ACCESS_FINE_LOCATION`
/// em Android ≤ 30 a varredura clássica devolve lista vazia sem erro nenhum
/// (§14: "parece bug de adaptador não encontrado" — daqui vem a instrução
/// de nunca tratar permissão negada como travamento silencioso).
Future<bool> ensureBluetoothPermissions() async {
  // Sem canal de plataforma disponível (teste de widget; qualquer
  // plataforma fora de Android/iOS) os plugins lançam em vez de resolver
  // pra um status — trata como "não deu" em vez de derrubar a tela (RNF02),
  // igual já feito em `foreground_service.dart` (item 17).
  try {
    final statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
    ].request().timeout(
          _permissionRequestTimeout,
          onTimeout: () => const <Permission, PermissionStatus>{},
        );

    final granted = statuses.isNotEmpty &&
        statuses.values.every(
          (status) => status.isGranted || status.isLimited,
        );
    if (!granted) return false;

    final isEnabled = await (FlutterBluetoothSerial.instance.isEnabled)
        .timeout(_permissionRequestTimeout, onTimeout: () => false);
    if (!(isEnabled ?? false)) {
      final enabled = await FlutterBluetoothSerial.instance
          .requestEnable()
          .timeout(_permissionRequestTimeout, onTimeout: () => false);
      if (enabled != true) return false;
    }

    return true;
  } catch (_) {
    return false;
  }
}
