import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/session.dart';
import '../providers/live_data_providers.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';
import 'trip_detail_screen.dart';

final _timeFmt = DateFormat.Hm();

/// Nomes de mês em português, escritos à mão em vez de
/// `DateFormat('d de MMMM', 'pt_BR')` — evita depender de
/// `initializeDateFormatting()` ter rodado antes da primeira formatação
/// (frágil em teste de widget, que não passa pelo `main()`).
const _monthNames = [
  'janeiro', 'fevereiro', 'março', 'abril', 'maio', 'junho',
  'julho', 'agosto', 'setembro', 'outubro', 'novembro', 'dezembro',
];

String _formatDate(DateTime date) => '${date.day} de ${_monthNames[date.month - 1]}';

/// "08 · VIAGENS" do mockup (item 13, RF17) — sessões concluídas do
/// veículo, com métricas agregadas por viagem.
class TripsListScreen extends ConsumerWidget {
  const TripsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehicleIdAsync = ref.watch(defaultVehicleIdProvider);

    return vehicleIdAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(strokeWidth: 2, color: PulsoColors.accent),
      ),
      error: (error, stack) => Center(child: Text('$error', style: PulsoTypography.body)),
      data: (vehicleId) {
        if (vehicleId == null) return const _EmptyTrips();
        final sessionsAsync = ref.watch(sessionsForVehicleProvider(vehicleId));
        return sessionsAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(strokeWidth: 2, color: PulsoColors.accent),
          ),
          error: (error, stack) => Center(child: Text('$error', style: PulsoTypography.body)),
          data: (sessions) {
            final finished = sessions.where((s) => !s.emAndamento).toList();
            if (finished.isEmpty) return const _EmptyTrips();
            return _TripsList(sessions: finished);
          },
        );
      },
    );
  }
}

class _TripsList extends StatelessWidget {
  const _TripsList({required this.sessions});

  final List<Session> sessions;

  @override
  Widget build(BuildContext context) {
    final totalKm = sessions.fold<double>(0, (acc, s) => acc + (s.distanciaKm ?? 0));
    final withConsumption = sessions.where((s) => s.consumoMedioKml != null).toList();
    final avgConsumption = withConsumption.isEmpty
        ? null
        : withConsumption.fold<double>(0, (acc, s) => acc + s.consumoMedioKml!) /
            withConsumption.length;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: PulsoSpacing.s4),
      children: [
        const SizedBox(height: PulsoSpacing.s4),
        const Text('Viagens', style: PulsoTypography.titleScreen),
        const SizedBox(height: PulsoSpacing.s1),
        Text(
          '${sessions.length} sessões · ${totalKm.toStringAsFixed(0)} km'
          '${avgConsumption != null ? ' · ${avgConsumption.toStringAsFixed(1)} km/l' : ''}',
          style: PulsoTypography.micro,
        ),
        const SizedBox(height: PulsoSpacing.s5),
        for (final session in sessions) _TripTile(session: session),
        const SizedBox(height: PulsoSpacing.s6),
      ],
    );
  }
}

class _TripTile extends StatelessWidget {
  const _TripTile({required this.session});

  final Session session;

  @override
  Widget build(BuildContext context) {
    final end = session.encerradaEm;
    final durationLabel = session.duracaoS != null
        ? '${(session.duracaoS! / 60).round()} min'
        : (end != null ? '${end.difference(session.iniciadaEm).inMinutes} min' : '—');

    return Padding(
      padding: const EdgeInsets.only(bottom: PulsoSpacing.s3),
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => TripDetailScreen(session: session)),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(PulsoSpacing.s4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '${_formatDate(session.iniciadaEm)} · '
                      '${_timeFmt.format(session.iniciadaEm)}'
                      '${end != null ? ' → ${_timeFmt.format(end)}' : ''}',
                      style: PulsoTypography.label.copyWith(color: PulsoColors.ink),
                    ),
                  ],
                ),
                const SizedBox(height: PulsoSpacing.s1),
                Text(durationLabel, style: PulsoTypography.micro),
                const SizedBox(height: PulsoSpacing.s3),
                Row(
                  children: [
                    _StatChip(
                      label: 'DISTÂNCIA',
                      value: session.distanciaKm != null
                          ? '${session.distanciaKm!.toStringAsFixed(1)} km'
                          : '—',
                    ),
                    const SizedBox(width: PulsoSpacing.s5),
                    _StatChip(
                      label: 'CONSUMO',
                      value: session.consumoMedioKml != null
                          ? '${session.consumoMedioKml!.toStringAsFixed(1)} km/l'
                          : '—',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: PulsoTypography.micro),
        Text(value, style: PulsoTypography.label.copyWith(color: PulsoColors.ink)),
      ],
    );
  }
}

class _EmptyTrips extends StatelessWidget {
  const _EmptyTrips();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(PulsoSpacing.s6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Nenhuma viagem gravada', style: PulsoTypography.titleScreen),
            const SizedBox(height: PulsoSpacing.s3),
            Text(
              'A gravação começa sozinha quando o app está conectado e o '
              'carro passa dos 5 km/h. Termina quando o motor desliga.',
              style: PulsoTypography.body,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
