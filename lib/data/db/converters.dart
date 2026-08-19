import 'dart:convert';

import 'package:drift/drift.dart';

/// `pids_suportados` (vehicles) guardado como JSON — lista pequena, não
/// precisa de tabela própria (§11).
class IntListConverter extends TypeConverter<List<int>, String> {
  const IntListConverter();

  @override
  List<int> fromSql(String fromDb) =>
      (jsonDecode(fromDb) as List).map((e) => e as int).toList();

  @override
  String toSql(List<int> value) => jsonEncode(value);
}

/// `freeze_frame` (dtc_events) — snapshot de PID key -> valor (§11).
class DoubleMapConverter extends TypeConverter<Map<String, double>, String> {
  const DoubleMapConverter();

  @override
  Map<String, double> fromSql(String fromDb) => (jsonDecode(fromDb) as Map)
      .map((k, v) => MapEntry(k as String, (v as num).toDouble()));

  @override
  String toSql(Map<String, double> value) => jsonEncode(value);
}
