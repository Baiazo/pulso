import 'package:drift/drift.dart';

import '../converters.dart';

/// Toda tabela tem `id` autoincremento, `uuid` (UUID v4 gerado no
/// dispositivo) e `synced_at` anulável — regra §2.1: sincronizar na Fase 2
/// vira trivial, e retrofitar isso num banco com dado real coletado é
/// doloroso.
mixin _AuditColumns on Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uuid => text()();
  DateTimeColumn get syncedAt => dateTime().nullable()();
}

class Vehicles extends Table with _AuditColumns {
  TextColumn get vin => text()();
  TextColumn get apelido => text()();
  TextColumn get modelo => text()();
  IntColumn get ano => integer()();
  RealColumn get cilindradaL => real()();

  /// `.name` de [FuelType] — nunca o índice numérico (comentário do §11).
  TextColumn get tipoCombustivel => text()();
  TextColumn get pidsSuportados =>
      text().map(const IntListConverter()).withDefault(const Constant('[]'))();
}

class Sessions extends Table with _AuditColumns {
  IntColumn get vehicleId => integer().references(Vehicles, #id)();
  DateTimeColumn get iniciadaEm => dateTime()();
  DateTimeColumn get encerradaEm => dateTime().nullable()();
  TextColumn get protocolo => text()();
  TextColumn get adaptador => text()();
  TextColumn get origem => text()();
  RealColumn get distanciaKm => real().nullable()();
  IntColumn get duracaoS => integer().nullable()();
  RealColumn get consumoMedioKml => real().nullable()();
}

/// A tabela que mais cresce — o índice composto `(session_id, pid_key,
/// ts)`, criado em `database.dart`, sustenta a consulta do gráfico (§11).
class Readings extends Table with _AuditColumns {
  IntColumn get sessionId => integer().references(Sessions, #id)();
  DateTimeColumn get ts => dateTime()();
  TextColumn get pidKey => text()();
  RealColumn get valor => real()();
  TextColumn get contexto => text()();
}

/// Gravada só com o modo de validação ligado (RF22) — evidência bruta para
/// a seção 5.7 do TCC.
class RawFrames extends Table with _AuditColumns {
  IntColumn get sessionId => integer().references(Sessions, #id)();
  DateTimeColumn get ts => dateTime()();
  TextColumn get comando => text()();
  TextColumn get respostaBruta => text()();
}

class DtcEvents extends Table with _AuditColumns {
  IntColumn get sessionId => integer().references(Sessions, #id)();
  DateTimeColumn get ts => dateTime()();
  TextColumn get codigo => text()();
  TextColumn get tipo => text()();
  TextColumn get descricao => text()();
  TextColumn get freezeFrame =>
      text().map(const DoubleMapConverter()).withDefault(const Constant('{}'))();
}

/// Guarda o estado do algoritmo de Welford (§12.3), não a lista de
/// amostras.
class Baselines extends Table with _AuditColumns {
  IntColumn get vehicleId => integer().references(Vehicles, #id)();
  TextColumn get pidKey => text()();
  TextColumn get contexto => text()();
  IntColumn get n => integer()();
  RealColumn get media => real()();
  RealColumn get m2 => real()();
  DateTimeColumn get atualizadoEm => dateTime()();
}

/// Extensão sobre o schema do §11 — ver domain/entities/trend_watch.dart
/// para o porquê.
///
/// `@DataClassName` força o singular correto: a singularização automática
/// do Drift stripa só o "s" final e gera "TrendWatche".
@DataClassName('TrendWatch')
class TrendWatches extends Table with _AuditColumns {
  IntColumn get vehicleId => integer().references(Vehicles, #id)();
  TextColumn get pidKey => text()();
  TextColumn get contexto => text()();
  IntColumn get consecutiveDeviatedSessions => integer().withDefault(const Constant(0))();
  IntColumn get lastSessionId => integer().nullable()();
}

class Anomalies extends Table with _AuditColumns {
  IntColumn get sessionId => integer().references(Sessions, #id)();
  DateTimeColumn get ts => dateTime()();
  TextColumn get pidKey => text()();
  TextColumn get contexto => text()();
  RealColumn get valor => real()();
  RealColumn get mediaEsperada => real()();
  RealColumn get desvioPadrao => real()();
  RealColumn get z => real()();
  TextColumn get severidade => text()();
  TextColumn get tipo => text()();
}
