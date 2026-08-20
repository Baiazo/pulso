import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/obd/pids/pid_catalog.dart';
import '../../domain/entities/session.dart';
import '../../domain/export/session_export_formatter.dart';
import '../providers/app_providers.dart';

/// Unidade dos PIDs derivados pelo motor de análise (§12.7) — não estão em
/// `pidCatalog` porque não vêm direto da ECU, são calculados a partir de
/// outras leituras (ver `analysis_engine.dart`).
const _derivedUnits = {
  'consumo_kml': 'km/l',
  'consumo_lh': 'L/h',
};

String _unitFor(String pidKey) {
  for (final def in pidCatalog) {
    if (def.key == pidKey) return def.unit;
  }
  return _derivedUnits[pidKey] ?? '';
}

/// `:` não é válido em nome de arquivo no Windows/Android — troca por `-`
/// pra poder usar o timestamp ISO direto no nome.
String _fileTimestamp(DateTime dt) => dt.toIso8601String().replaceAll(':', '-');

Future<File> _writeTempFile(String contents, String extension, Session session) async {
  final dir = await getTemporaryDirectory();
  final name = 'pulso_viagem_${session.id}_${_fileTimestamp(session.iniciadaEm)}.$extension';
  return File('${dir.path}/$name').writeAsString(contents);
}

/// Exporta as leituras da sessão em CSV (RF20) e abre o share sheet do
/// Android — artefato de compartilhar-e-descartar, por isso vai pro diretório
/// temporário, não pro de documentos. O toque neste botão é a escolha
/// explícita do usuário de para onde o dado vai; RNF08 proíbe egresso
/// automático/silencioso, não esta exportação sob demanda.
Future<void> exportSessionCsv(WidgetRef ref, Session session) async {
  final readings = await ref.read(readingRepositoryProvider).forSession(session.id!);
  final csv = buildReadingsCsv(readings: readings, unitFor: _unitFor);
  final file = await _writeTempFile(csv, 'csv', session);
  await SharePlus.instance.share(ShareParams(files: [XFile(file.path)]));
}

/// Exporta sessão + baselines do veículo + anomalias da sessão em JSON
/// (RF20). Escopo não toca `Vehicle`/VIN — ver `session_export_formatter.dart`.
Future<void> exportSessionJson(WidgetRef ref, Session session) async {
  final baselines = await ref.read(baselineRepositoryProvider).forVehicle(session.vehicleId);
  final anomalies = await ref.read(anomalyRepositoryProvider).forSession(session.id!);
  final export = buildSessionExportJson(session: session, baselines: baselines, anomalies: anomalies);
  final jsonStr = const JsonEncoder.withIndent('  ').convert(export);
  final file = await _writeTempFile(jsonStr, 'json', session);
  await SharePlus.instance.share(ShareParams(files: [XFile(file.path)]));
}
