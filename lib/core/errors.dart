/// Erros da camada OBD (transporte, ELM327, decodificação). Nunca é lançado
/// como exceção — sempre carregado num [Err] (ver core/result.dart).
sealed class ObdError {
  const ObdError();
}

/// O ELM327 respondeu `NO DATA` — não é falha, ver §7.4. O parâmetro não é
/// suportado pelo veículo, ou o motor está desligado, ou o sensor ainda não
/// tem leitura válida.
final class NoDataError extends ObdError {
  const NoDataError();
}

/// Nenhuma resposta dentro do timeout do comando.
final class TimeoutError extends ObdError {
  const TimeoutError(this.command);
  final String command;
}

/// O adaptador devolveu uma das strings de erro do §7.4
/// (`UNABLE TO CONNECT`, `BUS INIT: ERROR`, `BUS BUSY`, etc.).
final class AdapterError extends ObdError {
  const AdapterError(this.raw);
  final String raw;
}

/// A resposta não pôde ser interpretada pelo parser (formato inesperado,
/// truncada, lixo).
final class ParseError extends ObdError {
  const ParseError(this.raw);
  final String raw;
}

/// Valor decodificado caiu fora da faixa física do PID (§8). Descartado
/// antes de persistir — se entrar na baseline, contamina média e desvio
/// padrão de forma permanente (§8).
final class OutOfRangeError extends ObdError {
  const OutOfRangeError({
    required this.pidKey,
    required this.value,
    required this.min,
    required this.max,
  });

  final String pidKey;
  final double value;
  final double min;
  final double max;
}

/// A quantidade de bytes de dado não bate com o `byteCount` esperado pelo
/// [PidDefinition] (ver pids/pid_definition.dart).
final class ByteCountMismatchError extends ObdError {
  const ByteCountMismatchError({
    required this.pidKey,
    required this.expected,
    required this.actual,
  });

  final String pidKey;
  final int expected;
  final int actual;
}

/// O PID consultado não existe no catálogo (§8).
final class UnknownPidError extends ObdError {
  const UnknownPidError({required this.mode, required this.pid});
  final int mode;
  final int pid;
}
