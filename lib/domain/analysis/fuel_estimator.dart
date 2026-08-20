import '../entities/enums.dart';

/// Constantes por combustível (§12.6) — atenção ao caso brasileiro: a
/// gasolina comum já vem com ~27% de etanol anidro, o que invalida a
/// constante de 14,7 da literatura internacional (gasolina pura, E0).
class FuelConstants {
  const FuelConstants({required this.afr, required this.densityGPerL});

  /// Razão ar-combustível estequiométrica.
  final double afr;
  final double densityGPerL;

  /// L/h por g/s de MAF — deriva de `afr`/`densidadeGPerL` em vez de vir
  /// hardcoded separadamente, pra não poder divergir da fórmula do §12.6.
  double get factorLhPerGs => 3600 / (afr * densityGPerL);
}

/// `gasolinaAditivada` reaproveita a constante de `gasolinaComum`: aditivo
/// de limpeza não muda AFR nem densidade de forma relevante.
///
/// `flex` reaproveita a mesma constante na ausência de sensor de mistura
/// — o veículo flex roda numa proporção gasolina/etanol que não é
/// diretamente observável via OBD-II; assumir gasolina comum é a
/// simplificação mais conservadora disponível na Fase 1.
const Map<FuelType, FuelConstants> fuelConstants = {
  FuelType.gasolinaComum: FuelConstants(afr: 13.2, densityGPerL: 750),
  FuelType.gasolinaAditivada: FuelConstants(afr: 13.2, densityGPerL: 750),
  FuelType.etanol: FuelConstants(afr: 8.4, densityGPerL: 809),
  FuelType.flex: FuelConstants(afr: 13.2, densityGPerL: 750),
};

/// L/h a partir do MAF (§12.6) — usado só quando o veículo não expõe o
/// PID `5E` diretamente (nesse caso, usa-se o valor reportado e ignora-se
/// este cálculo, por decisão explícita do documento).
double fuelRateFromMaf({required double mafGs, required FuelType fuelType}) {
  final constants = fuelConstants[fuelType]!;
  return mafGs * constants.factorLhPerGs;
}

/// km/L — indefinido com o veículo parado (§12.6), então `null` em vez de
/// dividir por zero ou por uma taxa de consumo também nula.
double? fuelEconomyKmL({required double speedKmh, required double fuelRateLh}) {
  if (speedKmh <= 0 || fuelRateLh <= 0) return null;
  return speedKmh / fuelRateLh;
}

const double defaultVolumetricEfficiency = 0.85;

/// Estimativa de MAF por densidade-velocidade a partir do MAP (§12.6),
/// usada só quando o veículo não expõe nem PID `5E` nem MAF (PID `10`).
/// `VE` é uma suposição (0,85 por padrão) — o valor resultante deve ser
/// marcado como estimado na interface, nunca como medido.
double estimateMafFromMap({
  required double rpm,
  required double displacementL,
  required double mapKpa,
  required double iatC,
  double volumetricEfficiency = defaultVolumetricEfficiency,
}) {
  final iatKelvin = iatC + 273.15;
  return (rpm / 120) *
      displacementL *
      volumetricEfficiency *
      mapKpa *
      28.97 /
      (8.314 * iatKelvin);
}
