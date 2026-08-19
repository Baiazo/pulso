/// Tipo de ignição do veículo, indicado pelo bit 7 do byte B — determina
/// quais monitores contínuos/não-contínuos existem nos bytes C e D
/// (SAE J1979 / ISO 15031-5, PID 01).
enum IgnitionType { spark, compression }

/// Estado de um monitor de emissão: se o veículo o suporta, e se o ciclo de
/// diagnóstico dele já completou.
class MonitorTestStatus {
  const MonitorTestStatus({required this.supported, required this.ready});

  final bool supported;

  /// `true` quando o monitor já completou o ciclo de diagnóstico nesta
  /// sessão de condução. `false` com `supported = true` é o estado comum
  /// logo após limpar DTCs (Modo 04) — os monitores ainda não rodaram.
  final bool ready;
}

/// Resultado estruturado do PID 01 (Modo 01) — não é um valor escalar, por
/// isso fica fora do catálogo numérico do §8: carrega o estado da luz de
/// injeção, a contagem de DTCs e a prontidão de cada monitor de emissão.
class MonitorStatus {
  const MonitorStatus({
    required this.milOn,
    required this.dtcCount,
    required this.ignitionType,
    required this.monitors,
  });

  final bool milOn;
  final int dtcCount;
  final IgnitionType ignitionType;

  /// Chaveado pelo nome do monitor (`'catalyst'`, `'egr_system'`, etc — ver
  /// [_sparkMonitorNames] / [_compressionMonitorNames]).
  final Map<String, MonitorTestStatus> monitors;
}

const List<String> _sparkMonitorNames = [
  'catalyst',
  'heated_catalyst',
  'evap_system',
  'secondary_air',
  'ac_refrigerant',
  'o2_sensor',
  'o2_sensor_heater',
  'egr_system',
];

const List<String> _compressionMonitorNames = [
  'nmhc_catalyst',
  'nox_scr_monitor',
  'reserved_1',
  'boost_pressure',
  'reserved_2',
  'exhaust_gas_sensor',
  'pm_filter',
  'egr_vvt_system',
];

/// Decodifica os 4 bytes de dado do PID 01, Modo 01 (`0141` na resposta
/// ELM327). `bytes` já convertidos de hexadecimal para inteiro sem sinal,
/// na ordem A, B, C, D.
MonitorStatus decodeMonitorStatus(List<int> bytes) {
  final a = bytes[0];
  final b = bytes[1];
  final c = bytes[2];
  final d = bytes[3];

  final milOn = (a & 0x80) != 0;
  final dtcCount = a & 0x7F;
  final ignitionType =
      (b & 0x80) != 0 ? IgnitionType.compression : IgnitionType.spark;

  final monitors = <String, MonitorTestStatus>{
    'misfire': MonitorTestStatus(
      supported: (b & 0x01) != 0,
      ready: (b & 0x10) == 0,
    ),
    'fuel_system': MonitorTestStatus(
      supported: (b & 0x02) != 0,
      ready: (b & 0x20) == 0,
    ),
    'comprehensive_component': MonitorTestStatus(
      supported: (b & 0x04) != 0,
      ready: (b & 0x40) == 0,
    ),
  };

  final names = ignitionType == IgnitionType.spark
      ? _sparkMonitorNames
      : _compressionMonitorNames;
  for (var i = 0; i < names.length; i++) {
    if (names[i].startsWith('reserved_')) continue;
    final bit = 1 << i;
    monitors[names[i]] = MonitorTestStatus(
      supported: (c & bit) != 0,
      ready: (d & bit) == 0,
    );
  }

  return MonitorStatus(
    milOn: milOn,
    dtcCount: dtcCount,
    ignitionType: ignitionType,
    monitors: monitors,
  );
}
