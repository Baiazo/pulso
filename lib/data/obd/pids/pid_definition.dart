/// Frequência de amostragem no rodízio do agendador (§10). O agendador lê
/// esse campo do catálogo — nunca mantém lista própria de PIDs, para nunca
/// existir um PID cadastrado e esquecido no rodízio.
enum SamplingPriority {
  alta,
  media,
  baixa,
  sobDemanda,
}

/// Definição de um PID do Modo 01 (SAE J1979), incluindo como decodificar
/// seus bytes de dado para unidade de engenharia. Fonte única de verdade
/// para catálogo (§8), agendamento (§10) e validação de faixa.
class PidDefinition {
  const PidDefinition({
    required this.mode,
    required this.pid,
    required this.key,
    required this.label,
    required this.unit,
    required this.byteCount,
    required this.decode,
    required this.min,
    required this.max,
    required this.priority,
  });

  final int mode;
  final int pid;
  final String key;
  final String label;
  final String unit;
  final int byteCount;
  final double Function(List<int> bytes) decode;
  final double min;
  final double max;
  final SamplingPriority priority;
}
