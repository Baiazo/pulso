import 'package:flutter_test/flutter_test.dart';
import 'package:pulso/core/errors.dart';
import 'package:pulso/data/obd/pids/pid_catalog.dart';
import 'package:pulso/data/obd/pids/pid_decoder.dart';

/// Converte uma string hex ("1AF8") na lista de bytes ([0x1A, 0xF8]) que o
/// [PidDefinition.decode] espera — já "convertidos de hexadecimal para
/// inteiro sem sinal", como o §8 descreve.
List<int> hexBytes(String hex) {
  final bytes = <int>[];
  for (var i = 0; i < hex.length; i += 2) {
    bytes.add(int.parse(hex.substring(i, i + 2), radix: 16));
  }
  return bytes;
}

class _Case {
  const _Case(this.key, this.hex, this.expected);
  final String key;
  final String hex;
  final double expected;
}

void main() {
  group('pidCatalog', () {
    test('tem uma definição por PID, sem duplicata de (mode, pid) ou key',
        () {
      final codes = <String>{};
      final keys = <String>{};
      for (final def in pidCatalog) {
        final code = '${def.mode}:${def.pid}';
        expect(codes.contains(code), isFalse, reason: 'código duplicado $code');
        expect(keys.contains(def.key), isFalse, reason: 'key duplicada ${def.key}');
        codes.add(code);
        keys.add(def.key);
      }
      expect(pidCatalog, isNotEmpty);
    });

    test('min <= max em toda definição', () {
      for (final def in pidCatalog) {
        expect(def.min <= def.max, isTrue, reason: def.key);
      }
    });
  });

  group('findPidByKey / findPidByCode', () {
    test('encontra por key', () {
      expect(findPidByKey('engine_rpm')?.pid, 0x0C);
      expect(findPidByKey('inexistente'), isNull);
    });

    test('encontra por (mode, pid) — não confunde PID com modo de serviço',
        () {
      // PID 0x0A (Modo 01) é pressão de combustível; Modo 0x0A (serviço) é
      // DTCs permanentes — são coisas diferentes (nota do §10).
      expect(findPidByCode(mode: 0x01, pid: 0x0A)?.key, 'fuel_pressure');
      expect(findPidByCode(mode: 0x0A, pid: 0x01), isNull);
    });
  });

  group('decodePidValue — vetores golden (§8), com extremos de faixa', () {
    final cases = [
      // engine_load (04): A×100/255, 0–100
      const _Case('engine_load', '00', 0.0),
      const _Case('engine_load', 'FF', 100.0),
      const _Case('engine_load', '80', 50.19607843137255),

      // coolant_temp (05): A−40, −40–215
      const _Case('coolant_temp', '00', -40.0),
      const _Case('coolant_temp', 'FF', 215.0),
      const _Case('coolant_temp', '50', 40.0),

      // short_fuel_trim_1 (06): (A−128)×100/128, −100–99,2
      const _Case('short_fuel_trim_1', '00', -100.0),
      const _Case('short_fuel_trim_1', 'FE', 98.4375),

      // long_fuel_trim_1 (07): mesma fórmula
      const _Case('long_fuel_trim_1', '80', 0.0),

      // fuel_pressure (0A): A×3, 0–765
      const _Case('fuel_pressure', '00', 0.0),
      const _Case('fuel_pressure', 'FF', 765.0),
      const _Case('fuel_pressure', '32', 150.0),

      // intake_map (0B): A, 0–255
      const _Case('intake_map', '00', 0.0),
      const _Case('intake_map', 'FF', 255.0),
      const _Case('intake_map', '64', 100.0),

      // engine_rpm (0C): (256A+B)/4, 0–16383,75 — bytes do exemplo do §7.3
      const _Case('engine_rpm', '0000', 0.0),
      const _Case('engine_rpm', 'FFFF', 16383.75),
      const _Case('engine_rpm', '1AF8', 1726.0),

      // vehicle_speed (0D): A, 0–255
      const _Case('vehicle_speed', '00', 0.0),
      const _Case('vehicle_speed', 'FF', 255.0),
      const _Case('vehicle_speed', '64', 100.0),

      // timing_advance (0E): A/2−64, −64–63,5
      const _Case('timing_advance', '00', -64.0),
      const _Case('timing_advance', 'FF', 63.5),
      const _Case('timing_advance', '80', 0.0),

      // intake_air_temp (0F): A−40, −40–215
      const _Case('intake_air_temp', '00', -40.0),
      const _Case('intake_air_temp', 'FF', 215.0),
      const _Case('intake_air_temp', '46', 30.0),

      // maf_rate (10): (256A+B)/100, 0–655,35
      const _Case('maf_rate', '0000', 0.0),
      const _Case('maf_rate', 'FFFF', 655.35),
      const _Case('maf_rate', '03E8', 10.0),

      // throttle_position (11): A×100/255, 0–100
      const _Case('throttle_position', '00', 0.0),
      const _Case('throttle_position', 'FF', 100.0),
      const _Case('throttle_position', 'CC', 80.0),

      // run_time_since_start (1F): 256A+B, 0–65535
      const _Case('run_time_since_start', '0000', 0.0),
      const _Case('run_time_since_start', 'FFFF', 65535.0),
      const _Case('run_time_since_start', '003C', 60.0),

      // distance_with_mil (21): 256A+B, 0–65535
      const _Case('distance_with_mil', '0000', 0.0),
      const _Case('distance_with_mil', 'FFFF', 65535.0),
      const _Case('distance_with_mil', '000A', 10.0),

      // fuel_level (2F): A×100/255, 0–100
      const _Case('fuel_level', '00', 0.0),
      const _Case('fuel_level', 'FF', 100.0),
      const _Case('fuel_level', '80', 50.19607843137255),

      // barometric_pressure (33): A, 0–255
      const _Case('barometric_pressure', '00', 0.0),
      const _Case('barometric_pressure', 'FF', 255.0),
      const _Case('barometric_pressure', '65', 101.0),

      // catalyst_temp_b1s1 (3C): (256A+B)/10−40, −40–6513,5
      const _Case('catalyst_temp_b1s1', '0000', -40.0),
      const _Case('catalyst_temp_b1s1', 'FFFF', 6513.5),
      const _Case('catalyst_temp_b1s1', '0190', 0.0),

      // control_module_voltage (42): (256A+B)/1000, 0–65,535
      const _Case('control_module_voltage', '0000', 0.0),
      const _Case('control_module_voltage', 'FFFF', 65.535),
      const _Case('control_module_voltage', '3200', 12.8),

      // absolute_load (43): (256A+B)×100/255, 0–25700
      const _Case('absolute_load', '0000', 0.0),
      const _Case('absolute_load', 'FFFF', 25700.0),
      const _Case('absolute_load', '00FF', 100.0),

      // commanded_equiv_ratio (44): (256A+B)/32768, 0–2. 0xFFFF fica
      // abaixo de 2 (1,999969...), diferente de fuel_trim e oil_temp: aqui
      // 32768 não divide 65535, então o extremo do byte não estoura a
      // faixa declarada.
      const _Case('commanded_equiv_ratio', '0000', 0.0),
      const _Case('commanded_equiv_ratio', 'FFFF', 1.999969482421875),
      const _Case('commanded_equiv_ratio', 'FF00', 1.9921875),

      // ambient_air_temp (46): A−40, −40–215
      const _Case('ambient_air_temp', '00', -40.0),
      const _Case('ambient_air_temp', 'FF', 215.0),
      const _Case('ambient_air_temp', '5A', 50.0),

      // engine_oil_temp (5C): A−40, −40–210 (não −40–215: faixa do §8 é
      // mais estreita que o alcance bruto da fórmula, ver guarda abaixo)
      const _Case('engine_oil_temp', '00', -40.0),
      const _Case('engine_oil_temp', 'FA', 210.0),

      // fuel_rate (5E): (256A+B)/20, 0–3276,75
      const _Case('fuel_rate', '0000', 0.0),
      const _Case('fuel_rate', 'FFFF', 3276.75),
      const _Case('fuel_rate', '0064', 5.0),
    ];

    for (final c in cases) {
      test('${c.key} 0x${c.hex} -> ${c.expected}', () {
        final def = findPidByKey(c.key)!;
        final result = decodePidValue(def, hexBytes(c.hex));
        expect(result.isOk, isTrue, reason: result.when(ok: (_) => '', err: (e) => '$e'));
        expect(result.valueOrNull, closeTo(c.expected, 1e-6));
      });
    }
  });

  group('decodePidValue — guardas de faixa e de tamanho (§8)', () {
    test('short_fuel_trim_1 no byte extremo (0xFF) excede o máximo do §8 '
        '(99,21875 > 99,2 declarado) e é rejeitado', () {
      final def = findPidByKey('short_fuel_trim_1')!;
      final result = decodePidValue(def, hexBytes('FF'));
      expect(result.isErr, isTrue);
      expect(result.when(ok: (_) => null, err: (e) => e), isA<OutOfRangeError>());
    });

    test('engine_oil_temp acima de 210 °C (A=0xFF -> 215 °C) é rejeitado',
        () {
      final def = findPidByKey('engine_oil_temp')!;
      final result = decodePidValue(def, hexBytes('FF'));
      expect(result.isErr, isTrue);
      expect(result.when(ok: (_) => null, err: (e) => e), isA<OutOfRangeError>());
    });

    test('quantidade de bytes errada é rejeitada antes de decodificar', () {
      final def = findPidByKey('engine_rpm')!; // espera 2 bytes
      final result = decodePidValue(def, hexBytes('00'));
      expect(result.isErr, isTrue);
      expect(
        result.when(ok: (_) => null, err: (e) => e),
        isA<ByteCountMismatchError>(),
      );
    });
  });
}
