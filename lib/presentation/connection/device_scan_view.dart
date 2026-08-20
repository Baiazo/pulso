import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/obd/transport/device_scanner.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';
import 'connection_controller.dart';

/// Tela "02 · CONEXÃO — BUSCA" do mockup.
class DeviceScanView extends ConsumerWidget {
  const DeviceScanView({super.key, required this.devices});

  final List<DiscoveredDevice> devices;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(connectionControllerProvider.notifier);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(PulsoSpacing.s4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: controller.reset,
                  icon: const Icon(Icons.arrow_back, color: PulsoColors.ink),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                ),
                const SizedBox(width: PulsoSpacing.s2),
                const Text('Conectar', style: PulsoTypography.titleScreen),
              ],
            ),
            const SizedBox(height: PulsoSpacing.s2),
            Row(
              children: [
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: PulsoColors.accent),
                ),
                const SizedBox(width: PulsoSpacing.s2),
                Text('Procurando adaptador', style: PulsoTypography.body),
              ],
            ),
            const SizedBox(height: PulsoSpacing.s6),
            if (devices.isNotEmpty) ...[
              Text('ENCONTRADOS'.toUpperCase(), style: PulsoTypography.titleSection),
              const SizedBox(height: PulsoSpacing.s3),
              Expanded(
                child: ListView.separated(
                  itemCount: devices.length,
                  separatorBuilder: (_, _) => const SizedBox(height: PulsoSpacing.s2),
                  itemBuilder: (context, i) => _DeviceTile(
                    device: devices[i],
                    onTap: () => controller.connectToDevice(devices[i]),
                  ),
                ),
              ),
            ] else
              const Expanded(child: SizedBox.shrink()),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(PulsoSpacing.s4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Não aparece nenhum?', style: PulsoTypography.label.copyWith(color: PulsoColors.ink)),
                    const SizedBox(height: PulsoSpacing.s2),
                    Text(
                      'O adaptador só liga quando a ignição está na posição II. '
                      'Confira também se ele está firme na porta, embaixo do volante.',
                      style: PulsoTypography.body,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: PulsoSpacing.s3),
            OutlinedButton(
              onPressed: controller.startScan,
              child: const Text('PROCURAR DE NOVO'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeviceTile extends StatelessWidget {
  const _DeviceTile({required this.device, required this.onTap});

  final DiscoveredDevice device;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(PulsoSpacing.s4),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(device.name, style: PulsoTypography.label.copyWith(color: PulsoColors.ink)),
                    const SizedBox(height: PulsoSpacing.s1),
                    Text(
                      device.paired
                          ? '${device.address} · pareado'
                          : device.looksLikeObd
                              ? device.address
                              : '${device.address} · não parece OBD',
                      style: PulsoTypography.micro,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: PulsoColors.inkMeta),
            ],
          ),
        ),
      ),
    );
  }
}
