/// Sistema do veículo indicado pelos 2 bits mais altos do byte A (§9).
enum DtcSystem { powertrain, chassis, body, network }

/// Um código de falha decodificado (SAE J2012 / ISO 15031-6).
class DtcCode {
  const DtcCode({
    required this.system,
    required this.isManufacturerSpecific,
    required this.digits,
  });

  final DtcSystem system;

  /// Primeiro dígito do código: `0` = genérico SAE/ISO, `1` = específico do
  /// fabricante (§9).
  final bool isManufacturerSpecific;

  /// Os 3 últimos dígitos, em hexadecimal maiúsculo (ex.: `"133"`, `"420"`).
  final String digits;

  static const _systemLetter = {
    DtcSystem.powertrain: 'P',
    DtcSystem.chassis: 'C',
    DtcSystem.body: 'B',
    DtcSystem.network: 'U',
  };

  /// Representação textual completa, ex.: `P0133`.
  String get code {
    final letter = _systemLetter[system]!;
    final firstDigit = isManufacturerSpecific ? '1' : '0';
    return '$letter$firstDigit$digits';
  }

  @override
  String toString() => code;

  @override
  bool operator ==(Object other) => other is DtcCode && other.code == code;

  @override
  int get hashCode => code.hashCode;
}

const Map<int, DtcSystem> _systemByBits = {
  0: DtcSystem.powertrain,
  1: DtcSystem.chassis,
  2: DtcSystem.body,
  3: DtcSystem.network,
};

/// Decodifica os 2 bytes de um DTC (§9). `a` e `b` já convertidos de
/// hexadecimal para inteiro sem sinal.
DtcCode decodeDtc(int a, int b) {
  final system = _systemByBits[a >> 6]!;
  final isManufacturerSpecific = ((a >> 4) & 0x03) != 0;
  final digits =
      ((a & 0x0F) << 8 | b).toRadixString(16).toUpperCase().padLeft(3, '0');
  return DtcCode(
    system: system,
    isManufacturerSpecific: isManufacturerSpecific,
    digits: digits,
  );
}

/// `true` quando o par de bytes é preenchimento (`0000`), não um DTC real —
/// aparece em respostas do Modo 03 quando o frame carrega menos códigos do
/// que o número de slots (§9).
bool isDtcPadding(int a, int b) => a == 0 && b == 0;

/// Decodifica uma sequência plana de bytes de DTC (pares A,B já sem o modo
/// de serviço e, no caso CAN, sem o byte de contagem — isso é
/// responsabilidade de quem monta essa lista a partir do frame bruto),
/// descartando os pares de preenchimento `0000`.
List<DtcCode> decodeDtcFrame(List<int> bytes) {
  final codes = <DtcCode>[];
  for (var i = 0; i + 1 < bytes.length; i += 2) {
    final a = bytes[i];
    final b = bytes[i + 1];
    if (isDtcPadding(a, b)) continue;
    codes.add(decodeDtc(a, b));
  }
  return codes;
}
