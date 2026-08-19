/// Constantes de comando AT do handshake (§7.1) — evita string mágica
/// espalhada pelo client e pelos testes.
class AtCommands {
  const AtCommands._();

  static const reset = 'ATZ';
  static const echoOff = 'ATE0';
  static const echoOn = 'ATE1';
  static const linefeedsOff = 'ATL0';
  static const linefeedsOn = 'ATL1';
  static const spacesOff = 'ATS0';
  static const spacesOn = 'ATS1';
  static const headersOff = 'ATH0';
  static const headersOn = 'ATH1';
  static const describeProtocol = 'ATDP';
  static const adaptiveTimingOn = 'ATAT1';

  static String setProtocol(int number) => 'ATSP$number';

  /// CAN 11 bits / 500 kbps (ISO 15765-4) — protocolo do Volvo V40 2019
  /// de referência (§7.1).
  static const protocolCan11Bit500k = 6;
  static const protocolAuto = 0;
}

/// Modos de serviço SAE J1979 usados fora do catálogo de PIDs do Modo 01.
class ObdServiceModes {
  const ObdServiceModes._();

  static const currentData = 0x01;
  static const freezeFrame = 0x02;
  static const storedDtcs = 0x03;
  static const clearDtcs = 0x04;
  static const pendingDtcs = 0x07;
  static const vehicleInfo = 0x09;
  static const permanentDtcs = 0x0A;
}
