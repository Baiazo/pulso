/// Resultado de uma operação que pode falhar, sem lançar exceção — regra
/// §2.1 do PROJETO-OBD-II.md: a camada OBD nunca lança, sempre retorna.
sealed class Result<T, E> {
  const Result();

  bool get isOk => this is Ok<T, E>;
  bool get isErr => this is Err<T, E>;

  R when<R>({
    required R Function(T value) ok,
    required R Function(E error) err,
  }) {
    final self = this;
    return switch (self) {
      Ok<T, E>() => ok(self.value),
      Err<T, E>() => err(self.error),
    };
  }

  T? get valueOrNull => switch (this) {
        Ok<T, E>(value: final v) => v,
        Err<T, E>() => null,
      };
}

final class Ok<T, E> extends Result<T, E> {
  const Ok(this.value);
  final T value;
}

final class Err<T, E> extends Result<T, E> {
  const Err(this.error);
  final E error;
}
