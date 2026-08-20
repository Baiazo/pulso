/// Um adaptador Bluetooth encontrado na varredura — antes do handshake
/// ELM327, só o que o SO expõe (nome, endereço, se já está pareado).
class DiscoveredDevice {
  const DiscoveredDevice({
    required this.id,
    required this.name,
    required this.address,
    this.paired = false,
    this.looksLikeObd = true,
  });

  final String id;
  final String name;
  final String address;
  final bool paired;

  /// Heurística de nome (`OBDII`, `ELM327`, `OBD`...) — um HC-05 genérico
  /// também aparece na varredura, mas provavelmente não é um adaptador.
  final bool looksLikeObd;
}

/// Varredura de adaptadores Bluetooth próximos (RF01) — atrás de
/// interface pelo mesmo motivo do `ObdTransport` (§5): a Fase 1 só tem a
/// implementação simulada; o item 9 acrescenta a real (`flutter_blue_plus`
/// / `flutter_bluetooth_serial`) sem mudar a UI que consome isto.
abstract class DeviceScanner {
  Stream<List<DiscoveredDevice>> scan();
  Future<void> stopScan();
}

/// Devolve os três dispositivos de exemplo do mockup — permite construir e
/// testar todo o fluxo de conexão sem hardware (RF21), igual ao
/// `MockTransport` faz para o ELM327.
class MockDeviceScanner implements DeviceScanner {
  @override
  Stream<List<DiscoveredDevice>> scan() async* {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    yield const [
      DiscoveredDevice(
        id: '00:1D:A5:68:98:8B',
        name: 'OBDII',
        address: '00:1D:A5:68:98:8B',
        paired: true,
      ),
    ];
    await Future<void>.delayed(const Duration(milliseconds: 400));
    yield const [
      DiscoveredDevice(
        id: '00:1D:A5:68:98:8B',
        name: 'OBDII',
        address: '00:1D:A5:68:98:8B',
        paired: true,
      ),
      DiscoveredDevice(
        id: '04:B1:67:2C:11:9F',
        name: 'V-LINK',
        address: '04:B1:67:2C:11:9F',
      ),
      DiscoveredDevice(
        id: '98:D3:31:F4:02:AA',
        name: 'HC-05',
        address: '98:D3:31:F4:02:AA',
        looksLikeObd: false,
      ),
    ];
  }

  @override
  Future<void> stopScan() async {}
}
