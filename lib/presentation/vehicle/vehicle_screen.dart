import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/obd/pids/pid_catalog.dart';
import '../../data/obd/pids/pid_definition.dart';
import '../../domain/entities/baseline.dart' as domain;
import '../../domain/entities/enums.dart';
import '../../domain/entities/session.dart';
import '../../domain/entities/vehicle.dart';
import '../providers/app_providers.dart';
import '../providers/live_data_providers.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';
import '../widgets/calibration_bar.dart';

const _monthAbbrev = [
  'jan', 'fev', 'mar', 'abr', 'mai', 'jun',
  'jul', 'ago', 'set', 'out', 'nov', 'dez',
];

String _formatShortDate(DateTime date) => '${date.day} ${_monthAbbrev[date.month - 1]}';

/// Intervalo do rodízio (§10) — `engine_rpm` é prioridade `alta`, então é
/// amostrado a cada ciclo sem exceção (`SamplingScheduler._duePidsForCycle`);
/// é essa taxa que converte "faltam N amostras" em tempo de condução.
const _samplingCycleInterval = Duration(milliseconds: 200);

String _fuelLabel(FuelType tipo) => switch (tipo) {
      FuelType.gasolinaComum => 'Gasolina comum',
      FuelType.gasolinaAditivada => 'Gasolina aditivada',
      FuelType.etanol => 'Etanol',
      FuelType.flex => 'Flex',
    };

/// "40 min" ou "2 h 10 min" — usado tanto no rótulo de calibração quanto,
/// futuramente, em qualquer outra estimativa de tempo restante (§10).
String _formatRemaining(Duration remaining) {
  final totalMinutes = (remaining.inMilliseconds / 60000).round();
  if (totalMinutes < 60) return '~$totalMinutes min';
  final hours = totalMinutes ~/ 60;
  final minutes = totalMinutes % 60;
  return '~$hours h $minutes min';
}

/// Percentual e amostras restantes de uma baseline rumo aos 100 usados
/// como "calibrado" (não há um `n` alvo formal no schema — §12.3 só
/// acumula Welford indefinidamente — 100 é a meta de exibição da tela).
({int percent, int remainingSamples}) _calibrationStats(domain.Baseline? baseline) {
  final n = baseline?.n ?? 0;
  final percent = n > 100 ? 100 : n;
  final remaining = 100 - n;
  return (percent: percent, remainingSamples: remaining < 0 ? 0 : remaining);
}

/// "09 · VEÍCULO" do mockup: dados somente-leitura do veículo (Fase 1 não
/// tem tela de edição — §19) e o progresso de calibração de baseline por
/// contexto (§12.3), pra o motorista entender por que o painel ainda não
/// mostra desvio em algum parâmetro.
class VehicleScreen extends ConsumerWidget {
  const VehicleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehicleAsync = ref.watch(defaultVehicleProvider);

    // Sem Scaffold/AppBar próprio — as outras abas (Painel, Viagens,
    // Falhas, Alertas) também não têm; o AppShell já dá o Scaffold e o
    // ConnectionChip fixo únicos pra todas, e o título entra como texto
    // normal no topo da lista (mesmo padrão de trips_list_screen.dart).
    return vehicleAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(strokeWidth: 2, color: PulsoColors.accent),
      ),
      error: (error, stack) => Center(child: Text('$error', style: PulsoTypography.body)),
      data: (vehicle) {
        if (vehicle == null) return const _EmptyVehicle();
        return _VehicleBody(vehicle: vehicle);
      },
    );
  }
}

class _EmptyVehicle extends StatelessWidget {
  const _EmptyVehicle();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Nenhum veículo configurado ainda.', style: PulsoTypography.titleScreen),
    );
  }
}

class _VehicleData {
  const _VehicleData({
    required this.sessions,
    required this.urbano,
    required this.rodovia,
    required this.paradoQuente,
  });

  final List<Session> sessions;
  final domain.Baseline? urbano;
  final domain.Baseline? rodovia;
  final domain.Baseline? paradoQuente;
}

class _VehicleBody extends ConsumerWidget {
  const _VehicleBody({required this.vehicle});

  final Vehicle vehicle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<_VehicleData>(
      future: _loadVehicleData(ref, vehicle.id!),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(strokeWidth: 2, color: PulsoColors.accent),
          );
        }
        return _VehicleContent(vehicle: vehicle, data: snapshot.data!);
      },
    );
  }

  Future<_VehicleData> _loadVehicleData(WidgetRef ref, int vehicleId) async {
    final sessionRepo = ref.read(sessionRepositoryProvider);
    final baselineRepo = ref.read(baselineRepositoryProvider);
    final results = await Future.wait([
      sessionRepo.forVehicle(vehicleId),
      baselineRepo.find(
        vehicleId: vehicleId,
        pidKey: 'engine_rpm',
        contexto: OperatingContext.urbano,
      ),
      baselineRepo.find(
        vehicleId: vehicleId,
        pidKey: 'engine_rpm',
        contexto: OperatingContext.rodovia,
      ),
      // "Parado" usa o contexto quente (mesma escolha de
      // `parameter_detail_screen._baselineContextoFor`): é o que melhor
      // representa "carro ligado parado" pro motorista.
      baselineRepo.find(
        vehicleId: vehicleId,
        pidKey: 'engine_rpm',
        contexto: OperatingContext.paradoQuente,
      ),
    ]);
    return _VehicleData(
      sessions: results[0] as List<Session>,
      urbano: results[1] as domain.Baseline?,
      rodovia: results[2] as domain.Baseline?,
      paradoQuente: results[3] as domain.Baseline?,
    );
  }
}

class _VehicleContent extends StatelessWidget {
  const _VehicleContent({required this.vehicle, required this.data});

  final Vehicle vehicle;
  final _VehicleData data;

  @override
  Widget build(BuildContext context) {
    // `forVehicle` ordena por `iniciadaEm` decrescente (ver
    // `LocalSessionRepository.forVehicle`) — o primeiro é o mais recente,
    // o último é o mais antigo.
    final mostRecentSession = data.sessions.isEmpty ? null : data.sessions.first;
    final earliestSession = data.sessions.isEmpty ? null : data.sessions.last;

    final supportedPids = [
      for (final def in pidCatalog)
        if (vehicle.pidsSuportados.contains(def.pid)) def,
    ];

    return ListView(
      padding: const EdgeInsets.all(PulsoSpacing.s4),
      children: [
        const Text('Veículo', style: PulsoTypography.titleScreen),
        const SizedBox(height: PulsoSpacing.s5),
        _InfoCard(
          vehicle: vehicle,
          protocolo: mostRecentSession?.protocolo,
        ),
        const SizedBox(height: PulsoSpacing.s6),
        Text('PARÂMETROS EXPOSTOS', style: PulsoTypography.titleSection),
        const SizedBox(height: PulsoSpacing.s1),
        Text(
          '${supportedPids.length} de ${pidCatalog.length}',
          style: PulsoTypography.micro,
        ),
        const SizedBox(height: PulsoSpacing.s3),
        for (final def in supportedPids) _PidRow(def: def),
        const SizedBox(height: PulsoSpacing.s7),
        Text('PERFIL', style: PulsoTypography.titleSection),
        const SizedBox(height: PulsoSpacing.s4),
        _UrbanoBar(baseline: data.urbano),
        const SizedBox(height: PulsoSpacing.s5),
        _RodoviaBar(baseline: data.rodovia),
        const SizedBox(height: PulsoSpacing.s5),
        _ParadoBar(baseline: data.paradoQuente, earliestSession: earliestSession),
        const SizedBox(height: PulsoSpacing.s6),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.vehicle, required this.protocolo});

  final Vehicle vehicle;
  final String? protocolo;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(PulsoSpacing.s4),
      decoration: BoxDecoration(
        color: PulsoColors.surface,
        borderRadius: BorderRadius.circular(PulsoRadius.card),
        border: Border.all(color: PulsoColors.hairline),
      ),
      child: Column(
        children: [
          _InfoRow(label: 'Modelo', value: Text(vehicle.modelo, style: _valueStyle)),
          const _InfoDivider(),
          _InfoRow(label: 'VIN', value: Text(vehicle.vin, style: PulsoTypography.monoCode)),
          const _InfoDivider(),
          _InfoRow(
            label: 'Combustível em uso',
            value: Text(_fuelLabel(vehicle.tipoCombustivel), style: _valueStyle),
          ),
          const _InfoDivider(),
          _InfoRow(
            label: 'Protocolo',
            value: Text(protocolo ?? '—', style: PulsoTypography.monoCode),
          ),
        ],
      ),
    );
  }

  static final _valueStyle =
      PulsoTypography.body.copyWith(color: PulsoColors.ink, fontWeight: FontWeight.w600);
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final Widget value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(label, style: PulsoTypography.label),
        value,
      ],
    );
  }
}

class _InfoDivider extends StatelessWidget {
  const _InfoDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: PulsoSpacing.s3),
      child: SizedBox(height: 1, child: ColoredBox(color: PulsoColors.hairline)),
    );
  }
}

class _PidRow extends StatelessWidget {
  const _PidRow({required this.def});

  final PidDefinition def;

  @override
  Widget build(BuildContext context) {
    final hex = def.pid.toRadixString(16).toUpperCase().padLeft(2, '0');
    return Container(
      padding: const EdgeInsets.symmetric(vertical: PulsoSpacing.s3),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: PulsoColors.hairline)),
      ),
      child: Row(
        children: [
          SizedBox(width: 40, child: Text(hex, style: PulsoTypography.monoCode)),
          const SizedBox(width: PulsoSpacing.s3),
          Expanded(child: Text(def.label, style: PulsoTypography.body)),
        ],
      ),
    );
  }
}

class _UrbanoBar extends StatelessWidget {
  const _UrbanoBar({required this.baseline});

  final domain.Baseline? baseline;

  @override
  Widget build(BuildContext context) {
    final stats = _calibrationStats(baseline);
    final remaining = Duration(milliseconds: stats.remainingSamples * _samplingCycleInterval.inMilliseconds);
    return CalibrationBar(
      label: 'Perfil urbano',
      percent: stats.percent,
      caption: 'FALTAM ${_formatRemaining(remaining)} DE CONDUÇÃO'.toUpperCase(),
    );
  }
}

class _RodoviaBar extends StatelessWidget {
  const _RodoviaBar({required this.baseline});

  final domain.Baseline? baseline;

  @override
  Widget build(BuildContext context) {
    final stats = _calibrationStats(baseline);
    final remaining = Duration(milliseconds: stats.remainingSamples * _samplingCycleInterval.inMilliseconds);
    return CalibrationBar(
      label: 'Perfil rodovia',
      percent: stats.percent,
      caption: 'FALTAM ${_formatRemaining(remaining)} ACIMA DE 80 KM/H'.toUpperCase(),
    );
  }
}

class _ParadoBar extends StatelessWidget {
  const _ParadoBar({required this.baseline, required this.earliestSession});

  final domain.Baseline? baseline;
  final Session? earliestSession;

  @override
  Widget build(BuildContext context) {
    final stats = _calibrationStats(baseline);
    final n = baseline?.n ?? 0;

    if (n < 100) {
      final remaining = Duration(milliseconds: stats.remainingSamples * _samplingCycleInterval.inMilliseconds);
      return CalibrationBar(
        label: 'Perfil parado',
        percent: stats.percent,
        caption: 'FALTAM ${_formatRemaining(remaining)} PARADO COM O MOTOR LIGADO'.toUpperCase(),
      );
    }

    final since = earliestSession != null ? ' · DESDE ${_formatShortDate(earliestSession!.iniciadaEm)}' : '';
    return CalibrationBar(
      label: 'Perfil parado',
      percent: stats.percent,
      caption: '$n AMOSTRAS$since'.toUpperCase(),
    );
  }
}
