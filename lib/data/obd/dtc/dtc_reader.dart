import '../../../core/errors.dart';
import '../../../core/result.dart';
import '../elm327/elm327_client.dart';
import '../pids/pid_catalog.dart';
import '../pids/pid_definition.dart';
import 'dtc_decoder.dart';

/// Os três modos de serviço "sob demanda" (§10) que formam a tela de
/// diagnóstico (mockup "06 · DIAGNÓSTICO"): armazenados/ativos, pendentes
/// e permanentes.
class AllDtcs {
  const AllDtcs({
    required this.ativos,
    required this.pendentes,
    required this.permanentes,
  });

  final List<DtcCode> ativos;
  final List<DtcCode> pendentes;
  final List<DtcCode> permanentes;

  bool get isEmpty =>
      ativos.isEmpty && pendentes.isEmpty && permanentes.isEmpty;
}

/// Lê os Modos 03, 07 e 0A em sequência (§9) — a fila serial do client
/// (§7.2) garante que as três consultas não se misturam.
Future<Result<AllDtcs, ObdError>> readAllDtcs(Elm327Client client) async {
  final ativos = await client.readDtcs(0x03);
  if (ativos case Err(:final error)) return Err(error);
  final pendentes = await client.readDtcs(0x07);
  if (pendentes case Err(:final error)) return Err(error);
  final permanentes = await client.readDtcs(0x0A);
  if (permanentes case Err(:final error)) return Err(error);

  return Ok(
    AllDtcs(
      ativos: _unwrap(ativos),
      pendentes: _unwrap(pendentes),
      permanentes: _unwrap(permanentes),
    ),
  );
}

List<DtcCode> _unwrap(Result<List<DtcCode>, ObdError> result) => switch (result) {
      Ok(:final value) => value,
      Err() => const [],
    };

/// Parâmetros do freeze frame mostrados em "06B · DTC — DETALHE": rotação,
/// velocidade, temperatura do motor e carga — os quatro números de "O
/// carro no instante da falha" do mockup.
const freezeFrameKeys = ['engine_rpm', 'vehicle_speed', 'coolant_temp', 'engine_load'];

/// Lê o freeze frame (Modo 02) inteiro para exibição — um buffer só por
/// ECU básica J1979 (§10: sob demanda). Ignora, sem falhar, qualquer PID
/// que a central não devolva (RF23: nunca inventar valor) — a ausência diz
/// respeito àquele parâmetro específico, não ao freeze frame inteiro.
Future<Map<String, double>> readFreezeFrameSnapshot(Elm327Client client) async {
  final snapshot = <String, double>{};
  for (final key in freezeFrameKeys) {
    PidDefinition? def;
    for (final d in pidCatalog) {
      if (d.key == key) {
        def = d;
        break;
      }
    }
    if (def == null) continue;
    final result = await client.readFreezeFrame(def);
    if (result case Ok(:final value)) snapshot[key] = value;
  }
  return snapshot;
}
