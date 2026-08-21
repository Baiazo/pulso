import 'package:flutter_bluetooth_serial_plus/flutter_bluetooth_serial_plus.dart';

import 'device_scanner.dart';

const _obdNameHints = ['OBD', 'ELM', 'VLINK', 'V-LINK'];

/// Varredura real (item 9, RF01) — pareados primeiro (aparecem na hora,
/// sem esperar descoberta), depois descoberta ao vivo pra pegar
/// adaptadores ainda não pareados (mockup "02 · CONEXÃO — BUSCA" mostra os
/// dois tipos juntos, distinguidos só pelo selo "· pareado").
class BluetoothClassicDeviceScanner implements DeviceScanner {
  @override
  Stream<List<DiscoveredDevice>> scan() async* {
    final bonded = await FlutterBluetoothSerial.instance.getBondedDevices();
    var devices = [for (final d in bonded) _toDiscovered(d)];
    yield devices;

    try {
      await for (final result in FlutterBluetoothSerial.instance.startDiscovery()) {
        final device = result.device;
        final withoutThis = devices.where((d) => d.id != device.address);
        devices = [...withoutThis, _toDiscovered(device)];
        yield devices;
      }
    } finally {
      // Sem isso a varredura do rádio continua ligada em segundo plano
      // (gasta bateria) mesmo depois que ninguém mais está ouvindo este
      // stream — acontece, por exemplo, quando o usuário sai da tela de
      // busca antes da descoberta terminar sozinha.
      await FlutterBluetoothSerial.instance.cancelDiscovery();
    }
  }

  @override
  Future<void> stopScan() => FlutterBluetoothSerial.instance.cancelDiscovery();

  DiscoveredDevice _toDiscovered(BluetoothDevice device) {
    final name = device.name ?? device.address;
    return DiscoveredDevice(
      id: device.address,
      name: name,
      address: device.address,
      paired: device.isBonded,
      looksLikeObd: _looksLikeObd(name),
    );
  }

  bool _looksLikeObd(String name) {
    final upper = name.toUpperCase();
    return _obdNameHints.any(upper.contains);
  }
}
