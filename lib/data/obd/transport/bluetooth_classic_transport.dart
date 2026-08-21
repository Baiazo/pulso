import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_bluetooth_serial_plus/flutter_bluetooth_serial_plus.dart';

import '../../../core/errors.dart';
import '../../../core/result.dart';
import 'obd_transport.dart';

/// Bluetooth clássico (SPP) contra um adaptador ELM327 real (item 9) — a
/// maioria dos clones baratos é Bluetooth 2.0 SPP, não BLE (§5). Só
/// transporta texto bruto; não sabe nada de handshake nem de PIDs — isso é
/// trabalho do `Elm327Client` por cima.
class BluetoothClassicTransport implements ObdTransport {
  BluetoothClassicTransport(this.address);

  final String address;

  BluetoothConnection? _connection;
  StreamSubscription<List<int>>? _inputSub;
  final _controller = StreamController<String>.broadcast();

  @override
  Stream<String> get incoming => _controller.stream;

  @override
  bool get isConnected => _connection?.isConnected ?? false;

  @override
  Future<Result<void, ObdError>> connect() async {
    if (isConnected) return const Ok(null);
    try {
      final connection = await BluetoothConnection.toAddress(address);
      _connection = connection;
      // `input` decodifica byte a byte, sem framing por resposta — juntar
      // até o prompt `>` é responsabilidade de quem lê (Elm327Client),
      // igual já documentado no contrato de `ObdTransport.incoming`.
      _inputSub = connection.input.listen(
        (bytes) => _controller.add(utf8.decode(bytes, allowMalformed: true)),
        onError: (_) {},
      );
      return const Ok(null);
    } catch (e) {
      return Err(AdapterError('$e'));
    }
  }

  @override
  Future<Result<void, ObdError>> write(String command) async {
    final connection = _connection;
    if (connection == null || !connection.isConnected) {
      return const Err(AdapterError('UNABLE TO CONNECT'));
    }
    try {
      // O ELM327 espera `\r` como terminador de linha (§7.2) — quem chama
      // `write` nunca inclui isso, é responsabilidade do transporte.
      connection.output.add(Uint8List.fromList(utf8.encode('$command\r')));
      await connection.output.allSent;
      return const Ok(null);
    } catch (e) {
      return Err(AdapterError('$e'));
    }
  }

  @override
  Future<void> dispose() async {
    await _inputSub?.cancel();
    _inputSub = null;
    await _connection?.finish();
    _connection = null;
    if (!_controller.isClosed) await _controller.close();
  }
}
