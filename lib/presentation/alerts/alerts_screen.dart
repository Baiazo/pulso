import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/obd/pids/pid_decoder.dart';
import '../../domain/analysis/anomaly_resolution.dart';
import '../../domain/entities/enums.dart';
import '../providers/live_data_providers.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';
import '../widgets/severity_colors.dart';

/// Janela de retenção da tela — mesmos "últimos 30 dias" do subtítulo do
/// mockup ("2 abertos · 5 resolvidos nos últimos 30 dias"): qualifica a
/// listagem inteira, não só a contagem de resolvidos.
const _windowDays = 30;

/// Nomes de mês em português, escritos à mão — mesma duplicação
/// deliberada de trips_list_screen.dart (evita depender de
/// `initializeDateFormatting()` ter rodado antes da primeira formatação,
/// frágil em teste de widget).
const _monthNames = [
  'janeiro', 'fevereiro', 'março', 'abril', 'maio', 'junho',
  'julho', 'agosto', 'setembro', 'outubro', 'novembro', 'dezembro',
];

String _formatDayHeader(DateTime day) {
  final now = DateTime.now();
  if (day.year == now.year && day.month == now.month && day.day == now.day) {
    return 'HOJE';
  }
  return '${day.day} DE ${_monthNames[day.month - 1].toUpperCase()}';
}

String _timeLabel(DateTime ts) =>
    '${ts.hour.toString().padLeft(2, '0')}:${ts.minute.toString().padLeft(2, '0')}';

/// Nome curto do contexto operacional (§12.2) pro selo do card — "parado"
/// agrega frio/quente, o motorista não distingue os dois de relance.
String _contextLabel(OperatingContext contexto) => switch (contexto) {
      OperatingContext.urbano => 'URBANO',
      OperatingContext.rodovia => 'RODOVIA',
      OperatingContext.paradoFrio => 'PARADO',
      OperatingContext.paradoQuente => 'PARADO',
    };

/// "07 · ALERTAS E ANOMALIAS" do mockup (item 15, RF14/RF23): histórico de
/// anomalias do veículo inteiro, separando o que segue em aberto do que já
/// foi confirmado como resolvido. É a versão vertical/histórico do que
/// `_AlertBanner` (painel ao vivo) já mostra pontualmente numa sessão só.
class AlertsScreen extends ConsumerWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehicleIdAsync = ref.watch(defaultVehicleIdProvider);

    return vehicleIdAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(strokeWidth: 2, color: PulsoColors.accent),
      ),
      error: (error, stack) => Center(child: Text('$error', style: PulsoTypography.body)),
      data: (vehicleId) {
        if (vehicleId == null) return const _EmptyAlerts();
        final groupsAsync = ref.watch(vehicleAlertGroupsProvider(vehicleId));
        return groupsAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(strokeWidth: 2, color: PulsoColors.accent),
          ),
          error: (error, stack) => Center(child: Text('$error', style: PulsoTypography.body)),
          data: (groups) {
            final cutoff = DateTime.now().subtract(const Duration(days: _windowDays));
            final recent = groups.where((g) => g.latest.ts.isAfter(cutoff)).toList();
            if (recent.isEmpty) return const _EmptyAlerts();
            return _AlertsList(groups: recent);
          },
        );
      },
    );
  }
}

class _AlertsList extends StatelessWidget {
  const _AlertsList({required this.groups});

  final List<AlertGroup> groups;

  @override
  Widget build(BuildContext context) {
    final open = groups.where((g) => g.status == AlertStatus.open).toList();
    final resolved = groups.where((g) => g.status == AlertStatus.resolved).toList();

    // `groups` já vem decrescente por `latest.ts` do provider — mantém
    // essa ordem entre dias, só quebra em cabeçalhos por dia calendário.
    final dayOrder = <DateTime>[];
    final byDay = <DateTime, List<AlertGroup>>{};
    for (final group in open) {
      final ts = group.latest.ts;
      final day = DateTime(ts.year, ts.month, ts.day);
      byDay.putIfAbsent(day, () {
        dayOrder.add(day);
        return [];
      }).add(group);
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: PulsoSpacing.s4),
      children: [
        const SizedBox(height: PulsoSpacing.s4),
        const Text('Alertas', style: PulsoTypography.titleScreen),
        const SizedBox(height: PulsoSpacing.s1),
        Text(
          '${open.length} abertos · ${resolved.length} resolvidos '
          'nos últimos $_windowDays dias',
          style: PulsoTypography.micro,
        ),
        const SizedBox(height: PulsoSpacing.s5),
        for (final day in dayOrder) ...[
          Text(_formatDayHeader(day), style: PulsoTypography.titleSection),
          const SizedBox(height: PulsoSpacing.s3),
          for (final group in byDay[day]!) _OpenAlertCard(group: group),
          const SizedBox(height: PulsoSpacing.s2),
        ],
        if (resolved.isNotEmpty) ...[
          const SizedBox(height: PulsoSpacing.s3),
          Text('RESOLVIDOS', style: PulsoTypography.titleSection),
          const SizedBox(height: PulsoSpacing.s3),
          for (final group in resolved) _ResolvedAlertRow(group: group),
        ],
        const SizedBox(height: PulsoSpacing.s6),
      ],
    );
  }
}

class _OpenAlertCard extends StatelessWidget {
  const _OpenAlertCard({required this.group});

  final AlertGroup group;

  @override
  Widget build(BuildContext context) {
    final anomaly = group.latest;
    final color = severityColor(anomaly.severidade) ?? PulsoColors.ink;
    final label = findPidByKey(anomaly.pidKey)?.label ?? anomaly.pidKey;

    return Padding(
      padding: const EdgeInsets.only(bottom: PulsoSpacing.s3),
      child: Container(
        padding: const EdgeInsets.all(PulsoSpacing.s4),
        decoration: BoxDecoration(
          color: PulsoColors.surface,
          borderRadius: BorderRadius.circular(PulsoRadius.card),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${severityLabel(anomaly.severidade).toUpperCase()} · '
              '${_timeLabel(anomaly.ts)} · ${_contextLabel(anomaly.contexto)}',
              style: PulsoTypography.micro.copyWith(color: color),
            ),
            const SizedBox(height: PulsoSpacing.s2),
            Text(label, style: PulsoTypography.body.copyWith(color: PulsoColors.ink)),
            const SizedBox(height: PulsoSpacing.s3),
            // RF23: o Z-score só aparece aqui, num terço secundário — nunca
            // no título. Os números observado/esperado já são a explicação
            // em linguagem leiga, não uma frase diagnóstica inventada.
            Row(
              children: [
                Expanded(
                  child: _StatColumn(
                    label: 'OBSERVADO',
                    value: anomaly.valor.toStringAsFixed(1),
                  ),
                ),
                Expanded(
                  child: _StatColumn(
                    label: 'ESPERADO',
                    value: '${anomaly.mediaEsperada.toStringAsFixed(1)} '
                        '±${anomaly.desvioPadrao.toStringAsFixed(1)}',
                  ),
                ),
                Expanded(
                  child: _StatColumn(
                    label: 'DESVIO',
                    value: '${anomaly.z.toStringAsFixed(1)} σ',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({required this.label, required this.value});

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

class _ResolvedAlertRow extends StatelessWidget {
  const _ResolvedAlertRow({required this.group});

  final AlertGroup group;

  @override
  Widget build(BuildContext context) {
    final label = findPidByKey(group.pidKey)?.label ?? group.pidKey;

    return Padding(
      padding: const EdgeInsets.only(bottom: PulsoSpacing.s3),
      child: Container(
        padding: const EdgeInsets.all(PulsoSpacing.s3),
        decoration: BoxDecoration(
          color: PulsoColors.surface,
          borderRadius: BorderRadius.circular(PulsoRadius.card),
          border: Border.all(color: PulsoColors.hairline),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: PulsoTypography.body.copyWith(color: PulsoColors.ink)),
            const SizedBox(height: PulsoSpacing.s1),
            Text(
              'RESOLVIDO · ${group.sessionsSinceCount} VIAGENS SEM REPETIR',
              style: PulsoTypography.micro.copyWith(color: PulsoColors.normalInk),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyAlerts extends StatelessWidget {
  const _EmptyAlerts();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(PulsoSpacing.s6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Nenhum alerta registrado ainda.', style: PulsoTypography.titleScreen),
            const SizedBox(height: PulsoSpacing.s3),
            Text(
              'Alertas aparecem aqui quando uma leitura fugir do padrão '
              'aprendido pra este carro em cada contexto de uso.',
              style: PulsoTypography.body,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
