import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'converters.dart';
import 'tables/tables.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [
    Vehicles,
    Sessions,
    Readings,
    RawFrames,
    DtcEvents,
    Baselines,
    Anomalies,
    TrendWatches,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          // Índice composto (§11) — a consulta do gráfico depende dele.
          await customStatement(
            'CREATE INDEX idx_readings_session_pid_ts '
            'ON readings (session_id, pid_key, ts)',
          );
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  static QueryExecutor _openConnection() {
    return LazyDatabase(() async {
      final dir = await getApplicationDocumentsDirectory();
      final file = File(p.join(dir.path, 'pulso.db'));
      return NativeDatabase.createInBackground(file);
    });
  }
}
