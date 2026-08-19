import 'dart:async';
import 'dart:math';

import '../../../core/errors.dart';
import '../../../core/result.dart';
import '../dtc/dtc_decoder.dart';
import '../pids/pid_catalog.dart';
import '../pids/pid_decoder.dart';
import 'mock/mock_vehicle.dart';
import 'obd_transport.dart';

/// Simulador de adaptador ELM327 + ECU (§13). Não é um enfeite de
/// desenvolvimento: é o que torna possível programar sem o carro ligado,
/// escrever testes de integração determinísticos, e validar a detecção de
/// anomalia (RF12/RF13) sem arriscar um carro real.
class MockTransport implements ObdTransport {
  MockTransport({
    MockProfile profile = MockProfile.normal,
    DateTime Function()? clock,
    Random? random,
  })  : vehicle = MockVehicle(profile: profile),
        _now = clock ?? DateTime.now,
        _random = random ?? Random() {
    if (profile == MockProfile.dtcAtivo) {
      _stored.add(
        StoredDtc(code: decodeDtc(0x04, 0x20), freezeFrame: const {}), // P0420
      );
      _milOverride = true;
    } else if (profile == MockProfile.falhaSensorO2) {
      _stored.add(
        StoredDtc(code: decodeDtc(0x01, 0x35), freezeFrame: const {}), // P0135
      );
      _milOverride = true;
    }
  }

  final MockVehicle vehicle;
  final DateTime Function() _now;
  final Random _random;

  DateTime? _engineStartedAt;
  bool _connected = false;
  bool? _milOverride;
  bool _forceNoDataOnce = false;
  bool _forceTimeoutOnce = false;

  bool _echoEnabled = true;
  bool _linefeedsEnabled = true;
  bool _spacesEnabled = true;
  bool _headersEnabled = false;

  final List<StoredDtc> _stored = [];
  final List<StoredDtc> _pending = [];
  final List<StoredDtc> _permanent = [];

  final _controller = StreamController<String>.broadcast();

  @override
  Stream<String> get incoming => _controller.stream;

  @override
  bool get isConnected => _connected;

  /// Faz a próxima consulta de PID do Modo 01 responder `NO DATA`, como um
  /// sensor real faria (§7.4) — para testar que o app trata isso como
  /// ausência de dado, não como erro.
  void forceNoDataOnce() => _forceNoDataOnce = true;

  /// Faz o próximo comando não gerar nenhuma resposta — simula timeout de
  /// comunicação, para testar RNF04 (detecção de perda de conexão em até
  /// 3 s).
  void forceTimeoutOnce() => _forceTimeoutOnce = true;

  /// Simula queda abrupta da conexão Bluetooth.
  void simulateDisconnect() {
    _connected = false;
  }

  /// Injeta um DTC no veículo simulado, com freeze frame coerente (usa o
  /// estado físico atual se nenhum for informado). Liga o MIL.
  void injectDtc(DtcCode code, {Map<String, double>? freezeFrame}) {
    _stored.add(
      StoredDtc(code: code, freezeFrame: freezeFrame ?? _currentSnapshot()),
    );
    _milOverride = true;
  }

  double get _t {
    _engineStartedAt ??= _now();
    return _now().difference(_engineStartedAt!).inMilliseconds / 1000.0;
  }

  bool get _milOn => _milOverride ?? vehicle.milOn;

  Map<String, double> _currentSnapshot() {
    final t = _t;
    return {
      for (final def in pidCatalog) def.key: _valueForKey(def.key, t),
    };
  }

  @override
  Future<Result<void, ObdError>> connect() async {
    _connected = true;
    _engineStartedAt ??= _now();
    return const Ok(null);
  }

  @override
  Future<void> dispose() async {
    _connected = false;
    await _controller.close();
  }

  @override
  Future<Result<void, ObdError>> write(String command) async {
    if (!_connected) {
      return const Err(AdapterError('UNABLE TO CONNECT'));
    }

    final cmd = command.trim().toUpperCase();
    final echo = _echoEnabled ? cmd : null;

    if (_forceTimeoutOnce) {
      _forceTimeoutOnce = false;
      return const Ok(null); // nenhuma resposta chega — quem chama expira
    }

    final latencyMs = 30 + _random.nextInt(51); // 30–80 ms, §13
    unawaited(
      Future.delayed(Duration(milliseconds: latencyMs), () {
        if (!_connected || _controller.isClosed) return;
        final body = _dispatch(cmd);
        _controller.add(_formatFrame(echo: echo, body: body));
      }),
    );

    return const Ok(null);
  }

  /// Formata a resposta como o adaptador real: `echo` (se ligado), o corpo
  /// da resposta, e o prompt `>` — ex.: `"410C1AF8\r\r>"` (§7.3).
  String _formatFrame({required String? echo, required String body}) {
    final nl = _linefeedsEnabled ? '\r\n' : '\r';
    final lines = [?echo, body];
    return '${lines.join(nl)}$nl$nl>';
  }

  String _dispatch(String cmd) {
    if (cmd.startsWith('AT')) return _dispatchAt(cmd);
    return _dispatchObd(cmd);
  }

  String _dispatchAt(String cmd) {
    switch (cmd) {
      case 'ATZ':
        _echoEnabled = true;
        _linefeedsEnabled = true;
        _spacesEnabled = true;
        _headersEnabled = false;
        return 'ELM327 v1.5';
      case 'ATE0':
        _echoEnabled = false;
        return 'OK';
      case 'ATE1':
        _echoEnabled = true;
        return 'OK';
      case 'ATL0':
        _linefeedsEnabled = false;
        return 'OK';
      case 'ATL1':
        _linefeedsEnabled = true;
        return 'OK';
      case 'ATS0':
        _spacesEnabled = false;
        return 'OK';
      case 'ATS1':
        _spacesEnabled = true;
        return 'OK';
      case 'ATH0':
        _headersEnabled = false;
        return 'OK';
      case 'ATH1':
        _headersEnabled = true;
        return 'OK';
      case 'ATDP':
        return 'ISO 15765-4 (CAN 11/500)';
      case 'ATAT0':
      case 'ATAT1':
      case 'ATAT2':
        return 'OK';
    }
    if (RegExp(r'^ATSP\d$').hasMatch(cmd)) return 'OK';
    return '?';
  }

  String _dispatchObd(String cmd) {
    if (cmd.length < 2) return '?';
    final mode = int.tryParse(cmd.substring(0, 2), radix: 16);
    if (mode == null) return '?';

    switch (mode) {
      case 0x01:
        return _dispatchMode01(cmd);
      case 0x02:
        return _dispatchMode02(cmd);
      case 0x03:
        return _dispatchDtcList(0x43, _stored);
      case 0x04:
        _stored.clear();
        _pending.clear();
        _permanent.clear();
        _milOverride = false;
        return 'OK';
      case 0x07:
        return _dispatchDtcList(0x47, _pending);
      case 0x09:
        return _dispatchMode09(cmd);
      case 0x0A:
        return _dispatchDtcList(0x4A, _permanent);
    }
    return 'NO DATA';
  }

  String _dispatchMode01(String cmd) {
    if (cmd.length < 4) return '?';
    final pidHex = cmd.substring(2, 4);
    final pid = int.parse(pidHex, radix: 16);

    if (pid == 0x00 || pid == 0x20 || pid == 0x40 || pid == 0x60) {
      return _bitmapResponse(pid);
    }

    if (pid == 0x01) {
      return _hexLine([0x41, 0x01, ..._monitorStatusBytes()]);
    }

    if (_forceNoDataOnce) {
      _forceNoDataOnce = false;
      return 'NO DATA';
    }

    final def = findPidByCode(mode: 0x01, pid: pid);
    if (def == null) return 'NO DATA';

    final value = _valueForKey(def.key, _t);
    final bytes = _encodePidValue(def.key, value);
    return _hexLine([0x41, pid, ...bytes]);
  }

  String _dispatchMode02(String cmd) {
    // "02" + PID + frame# — freeze frame do primeiro DTC armazenado
    // (simulador não modela múltiplos freeze frames simultâneos).
    if (_stored.isEmpty || cmd.length < 6) return 'NO DATA';
    final pidHex = cmd.substring(2, 4);
    final pid = int.parse(pidHex, radix: 16);
    final frame = _stored.first.freezeFrame;
    final def = findPidByCode(mode: 0x01, pid: pid);
    if (def == null) return 'NO DATA';
    final value = frame[def.key] ?? _valueForKey(def.key, _t);
    final bytes = _encodePidValue(def.key, value);
    return _hexLine([0x42, pid, 0x00, ...bytes]);
  }

  String _dispatchMode09(String cmd) {
    if (!cmd.startsWith('0902')) return 'NO DATA';
    final vinBytes = mockVin.codeUnits;
    return _hexLine([0x49, 0x02, 0x01, ...vinBytes]);
  }

  String _dispatchDtcList(int responseMode, List<StoredDtc> list) {
    final bytes = <int>[responseMode, list.length];
    for (final dtc in list) {
      final a = (_dtcSystemBits(dtc.code) << 6) |
          ((dtc.code.isManufacturerSpecific ? 1 : 0) << 4) |
          (int.parse(dtc.code.digits, radix: 16) >> 8);
      final b = int.parse(dtc.code.digits, radix: 16) & 0xFF;
      bytes.addAll([a, b]);
    }
    return _hexLine(bytes);
  }

  int _dtcSystemBits(DtcCode code) => switch (code.system) {
        DtcSystem.powertrain => 0,
        DtcSystem.chassis => 1,
        DtcSystem.body => 2,
        DtcSystem.network => 3,
      };

  List<int> _monitorStatusBytes() {
    final a = (_milOn ? 0x80 : 0) | (_stored.length & 0x7F);
    const b = 0x07; // misfire+fuel_system+comprehensive_component suportados e prontos
    const c = 0xE1; // catalyst, o2_sensor, o2_sensor_heater, egr_system suportados
    final d = _milOn ? 0x01 : 0x00; // catalyst não completo quando MIL acesa
    return [a, b, c, d];
  }

  Set<int> get _supportedPids => {0x01, ...pidCatalog.map((d) => d.pid)};

  String _bitmapResponse(int basePid) {
    var bitmap = 0;
    for (var offset = 1; offset <= 32; offset++) {
      // O último bit do bloco (PID base+0x20) nunca é um PID de dado real
      // — por convenção do padrão, ele sinaliza "existe PID suportado
      // além deste bloco, consulte o próximo" (§7.5).
      final supported = offset == 32
          ? _supportedPids.any((p) => p > basePid + 31)
          : _supportedPids.contains(basePid + offset);
      if (supported) bitmap |= 1 << (32 - offset);
    }
    final bytes = [
      (bitmap >> 24) & 0xFF,
      (bitmap >> 16) & 0xFF,
      (bitmap >> 8) & 0xFF,
      bitmap & 0xFF,
    ];
    return _hexLine([0x41, basePid, ...bytes]);
  }

  /// Prefixo de cabeçalho CAN da ECU (0x7E8 — ID de resposta padrão para
  /// uma requisição em 0x7E0), só aparece com ATH1 ligado (modo de
  /// validação, RF22/§14).
  String get _headerPrefix => _headersEnabled ? '7E8 ' : '';

  String _hexLine(List<int> bytes) {
    if (bytes.length <= 7) {
      return '$_headerPrefix${bytes.map(_hex2).join(_spacesEnabled ? ' ' : '')}';
    }
    return _multiFrame(bytes);
  }

  String _multiFrame(List<int> bytes) {
    final nl = _linefeedsEnabled ? '\r\n' : '\r';
    final lines = <String>[
      bytes.length.toRadixString(16).toUpperCase().padLeft(3, '0'),
    ];
    var idx = 0;
    var frameNum = 0;
    while (idx < bytes.length) {
      final chunkSize = frameNum == 0 ? 6 : 7;
      final chunk = bytes.skip(idx).take(chunkSize).toList();
      lines.add('$_headerPrefix$frameNum:${chunk.map(_hex2).join()}');
      idx += chunk.length;
      frameNum++;
    }
    return lines.join(nl);
  }

  String _hex2(int b) => b.toRadixString(16).toUpperCase().padLeft(2, '0');

  double _valueForKey(String key, double t) => switch (key) {
        'engine_load' => vehicle.engineLoadPct(t),
        'coolant_temp' => vehicle.coolantTempC(t),
        'short_fuel_trim_1' => vehicle.shortFuelTrim1Pct(t),
        'long_fuel_trim_1' => vehicle.longFuelTrim1Pct(t),
        'fuel_pressure' => vehicle.fuelPressureKpa(t),
        'intake_map' => vehicle.intakeMapKpa(t),
        'engine_rpm' => vehicle.engineRpm(t),
        'vehicle_speed' => vehicle.speedKmh(t),
        'timing_advance' => vehicle.timingAdvanceDeg(t),
        'intake_air_temp' => vehicle.intakeAirTempC(t),
        'maf_rate' => vehicle.mafRateGs(t),
        'throttle_position' => vehicle.throttlePosition(t),
        'run_time_since_start' => vehicle.runTimeSinceStartS(t),
        'distance_with_mil' => vehicle.distanceWithMilKm(t),
        'fuel_level' => vehicle.fuelLevelPct(t),
        'barometric_pressure' => vehicle.barometricPressureKpa(t),
        'catalyst_temp_b1s1' => vehicle.catalystTempC(t),
        'control_module_voltage' => vehicle.controlModuleVoltage(t),
        'absolute_load' => vehicle.absoluteLoadPct(t),
        'commanded_equiv_ratio' => vehicle.commandedEquivRatio(t),
        'ambient_air_temp' => vehicle.ambientAirTempC(t),
        'engine_oil_temp' => vehicle.engineOilTempC(t),
        'fuel_rate' => vehicle.fuelRateLh(t),
        _ => 0,
      };

  List<int> _encodePidValue(String key, double value) {
    int clampByte(num v) => v.round().clamp(0, 255);
    List<int> twoBytes(num total) {
      final t = total.round().clamp(0, 65535);
      return [(t >> 8) & 0xFF, t & 0xFF];
    }

    switch (key) {
      case 'engine_load':
      case 'throttle_position':
      case 'fuel_level':
        return [clampByte(value * 255 / 100)];
      case 'coolant_temp':
      case 'intake_air_temp':
      case 'ambient_air_temp':
      case 'engine_oil_temp':
        return [clampByte(value + 40)];
      case 'short_fuel_trim_1':
      case 'long_fuel_trim_1':
        return [clampByte(value * 128 / 100 + 128)];
      case 'fuel_pressure':
        return [clampByte(value / 3)];
      case 'intake_map':
      case 'vehicle_speed':
      case 'barometric_pressure':
        return [clampByte(value)];
      case 'engine_rpm':
        return twoBytes(value * 4);
      case 'timing_advance':
        return [clampByte((value + 64) * 2)];
      case 'maf_rate':
        return twoBytes(value * 100);
      case 'run_time_since_start':
      case 'distance_with_mil':
        return twoBytes(value);
      case 'catalyst_temp_b1s1':
        return twoBytes((value + 40) * 10);
      case 'control_module_voltage':
        return twoBytes(value * 1000);
      case 'absolute_load':
        return twoBytes(value * 255 / 100);
      case 'commanded_equiv_ratio':
        return twoBytes(value * 32768);
      case 'fuel_rate':
        return twoBytes(value * 20);
    }
    return [0];
  }
}
