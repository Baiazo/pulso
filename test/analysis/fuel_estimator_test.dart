import 'package:flutter_test/flutter_test.dart';
import 'package:pulso/domain/analysis/fuel_estimator.dart';
import 'package:pulso/domain/entities/enums.dart';

void main() {
  group('fuelRateFromMaf — os três combustíveis (§12.6, §15)', () {
    test('gasolina comum brasileira (E27): fator 0,364', () {
      final constants = fuelConstants[FuelType.gasolinaComum]!;
      expect(constants.factorLhPerGs, closeTo(0.364, 1e-3));

      final rate = fuelRateFromMaf(mafGs: 10, fuelType: FuelType.gasolinaComum);
      expect(rate, closeTo(3.64, 1e-2));
    });

    test('etanol hidratado (E100): fator 0,530 — não 0,89 do anidro', () {
      final constants = fuelConstants[FuelType.etanol]!;
      expect(constants.factorLhPerGs, closeTo(0.530, 1e-3));

      final rate = fuelRateFromMaf(mafGs: 10, fuelType: FuelType.etanol);
      expect(rate, closeTo(5.30, 1e-2));
    });

    test('flex reaproveita a constante da gasolina comum (sem sensor de '
        'mistura na Fase 1)', () {
      expect(
        fuelConstants[FuelType.flex]!.factorLhPerGs,
        fuelConstants[FuelType.gasolinaComum]!.factorLhPerGs,
      );
    });

    test('gasolina pura (E0, referência internacional): fator 0,329', () {
      const e0 = FuelConstants(afr: 14.7, densityGPerL: 745);
      expect(e0.factorLhPerGs, closeTo(0.329, 1e-3));
    });
  });

  group('fuelEconomyKmL — velocidade zero e ausência de taxa (§12.6, §15)', () {
    test('velocidade zero é indefinido, não zero nem infinito', () {
      final kml = fuelEconomyKmL(speedKmh: 0, fuelRateLh: 2.5);
      expect(kml, isNull);
    });

    test('taxa de consumo zero também é indefinido (evita divisão por zero)',
        () {
      final kml = fuelEconomyKmL(speedKmh: 80, fuelRateLh: 0);
      expect(kml, isNull);
    });

    test('caso normal: km/L = velocidade / L_h', () {
      final kml = fuelEconomyKmL(speedKmh: 90, fuelRateLh: 7.5);
      expect(kml, closeTo(12.0, 1e-9));
    });
  });

  group('estimateMafFromMap — ausência de MAF (§12.6, §15)', () {
    test('estima um MAF plausível a partir de RPM/MAP/IAT quando o '
        'veículo não expõe MAF nem PID 5E', () {
      final maf = estimateMafFromMap(
        rpm: 2000,
        displacementL: 2.0,
        mapKpa: 60,
        iatC: 25,
      );
      // (2000/120) × 2.0 × 0.85 × 60 × 28.97 / (8.314 × 298.15)
      final expected =
          (2000 / 120) * 2.0 * 0.85 * 60 * 28.97 / (8.314 * 298.15);
      expect(maf, closeTo(expected, 1e-6));
      expect(maf, greaterThan(0));
    });

    test('VE customizada muda o resultado proporcionalmente', () {
      final defaultVe = estimateMafFromMap(
        rpm: 2000,
        displacementL: 2.0,
        mapKpa: 60,
        iatC: 25,
      );
      final higherVe = estimateMafFromMap(
        rpm: 2000,
        displacementL: 2.0,
        mapKpa: 60,
        iatC: 25,
        volumetricEfficiency: 0.95,
      );
      expect(higherVe, greaterThan(defaultVe));
    });
  });
}
