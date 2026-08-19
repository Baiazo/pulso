import '../../../core/errors.dart';
import '../../../core/result.dart';
import 'pid_catalog.dart';
import 'pid_definition.dart';

/// Encontra a definição de um PID do Modo 01 pela chave (`engine_rpm`, etc).
PidDefinition? findPidByKey(String key) {
  for (final pid in pidCatalog) {
    if (pid.key == key) return pid;
  }
  return null;
}

/// Encontra a definição de um PID do Modo 01 pelo par (mode, pid) — o par
/// existe para não confundir modos de serviço com PIDs de mesmo número
/// (§10, nota de notação).
PidDefinition? findPidByCode({required int mode, required int pid}) {
  for (final def in pidCatalog) {
    if (def.mode == mode && def.pid == pid) return def;
  }
  return null;
}

/// Decodifica os bytes de dado de um PID e valida contra a faixa física
/// (§8): valor fora da faixa é erro de comunicação, não persiste — se
/// entrar na baseline, contamina média e desvio padrão permanentemente.
Result<double, ObdError> decodePidValue(
  PidDefinition definition,
  List<int> dataBytes,
) {
  if (dataBytes.length != definition.byteCount) {
    return Err(
      ByteCountMismatchError(
        pidKey: definition.key,
        expected: definition.byteCount,
        actual: dataBytes.length,
      ),
    );
  }

  final value = definition.decode(dataBytes);

  if (value < definition.min || value > definition.max) {
    return Err(
      OutOfRangeError(
        pidKey: definition.key,
        value: value,
        min: definition.min,
        max: definition.max,
      ),
    );
  }

  return Ok(value);
}
