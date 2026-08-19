import 'package:flutter_test/flutter_test.dart';
import 'package:pulso/data/obd/pids/monitor_status_decoder.dart';

void main() {
  group('decodeMonitorStatus', () {
    test('MIL apagada, 0 DTCs, ignição a centelha, monitores mistos', () {
      // A=0x00 MIL off, 0 DTCs
      // B=0x03 misfire+fuel_system suportados, ambos prontos, ignição=spark
      // C=0x21 catalyst+o2_sensor suportados
      // D=0x01 catalyst NÃO completo, o2_sensor completo
      final status = decodeMonitorStatus([0x00, 0x03, 0x21, 0x01]);

      expect(status.milOn, isFalse);
      expect(status.dtcCount, 0);
      expect(status.ignitionType, IgnitionType.spark);

      expect(status.monitors['misfire']!.supported, isTrue);
      expect(status.monitors['misfire']!.ready, isTrue);
      expect(status.monitors['fuel_system']!.supported, isTrue);
      expect(status.monitors['fuel_system']!.ready, isTrue);
      expect(status.monitors['comprehensive_component']!.supported, isFalse);

      expect(status.monitors['catalyst']!.supported, isTrue);
      expect(status.monitors['catalyst']!.ready, isFalse);
      expect(status.monitors['o2_sensor']!.supported, isTrue);
      expect(status.monitors['o2_sensor']!.ready, isTrue);
      expect(status.monitors['egr_system']!.supported, isFalse);
    });

    test('MIL acesa com 5 DTCs armazenados', () {
      final status = decodeMonitorStatus([0x85, 0x00, 0x00, 0x00]);
      expect(status.milOn, isTrue);
      expect(status.dtcCount, 5);
    });

    test('ignição por compressão usa o conjunto de monitores do diesel', () {
      // B=0x80 -> ignição=compression; C=0x08 -> boost_pressure suportado;
      // D=0x00 -> boost_pressure completo
      final status = decodeMonitorStatus([0x00, 0x80, 0x08, 0x00]);

      expect(status.ignitionType, IgnitionType.compression);
      expect(status.monitors['boost_pressure']!.supported, isTrue);
      expect(status.monitors['boost_pressure']!.ready, isTrue);
      expect(status.monitors.containsKey('catalyst'), isFalse);
      expect(status.monitors.containsKey('nmhc_catalyst'), isTrue);
    });

    test('contagem de DTCs ignora o bit 7 (reservado ao MIL)', () {
      final status = decodeMonitorStatus([0x7F, 0x00, 0x00, 0x00]);
      expect(status.milOn, isFalse);
      expect(status.dtcCount, 127);
    });
  });
}
