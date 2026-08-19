/// Enums compartilhados entre entidades (§11) — cada um vira uma coluna
/// TEXT no banco (guardando `.name`) e uma chave `snake_case` no JSON
/// (§2.1, regra 4), nunca o índice numérico: renumerar o enum no código
/// não pode corromper dado já persistido.
library;

/// Contexto operacional do veículo no momento da leitura (§12.2) — a
/// baseline é segmentada por isso, não por parâmetro sozinho.
enum OperatingContext { paradoFrio, paradoQuente, urbano, rodovia }

enum FuelType { gasolinaComum, gasolinaAditivada, etanol, flex }

enum SessionOrigin { real, simulado }

enum DtcEventType { ativo, pendente, permanente }

enum AnomalyType { pontual, tendencia }

/// §12.4: `3 ≤ |z| < 4` atenção · `4 ≤ |z| < 6` sério · `|z| ≥ 6` crítico.
enum AnomalySeverity { atencao, serio, critico }

extension OperatingContextJson on OperatingContext {
  String get jsonValue => switch (this) {
        OperatingContext.paradoFrio => 'parado_frio',
        OperatingContext.paradoQuente => 'parado_quente',
        OperatingContext.urbano => 'urbano',
        OperatingContext.rodovia => 'rodovia',
      };

  static OperatingContext fromJsonValue(String v) => switch (v) {
        'parado_frio' => OperatingContext.paradoFrio,
        'parado_quente' => OperatingContext.paradoQuente,
        'urbano' => OperatingContext.urbano,
        'rodovia' => OperatingContext.rodovia,
        _ => throw ArgumentError('contexto desconhecido: $v'),
      };
}

extension FuelTypeJson on FuelType {
  String get jsonValue => switch (this) {
        FuelType.gasolinaComum => 'gasolina_comum',
        FuelType.gasolinaAditivada => 'gasolina_aditivada',
        FuelType.etanol => 'etanol',
        FuelType.flex => 'flex',
      };

  static FuelType fromJsonValue(String v) => switch (v) {
        'gasolina_comum' => FuelType.gasolinaComum,
        'gasolina_aditivada' => FuelType.gasolinaAditivada,
        'etanol' => FuelType.etanol,
        'flex' => FuelType.flex,
        _ => throw ArgumentError('tipo_combustivel desconhecido: $v'),
      };
}

extension SessionOriginJson on SessionOrigin {
  String get jsonValue => switch (this) {
        SessionOrigin.real => 'real',
        SessionOrigin.simulado => 'simulado',
      };

  static SessionOrigin fromJsonValue(String v) => switch (v) {
        'real' => SessionOrigin.real,
        'simulado' => SessionOrigin.simulado,
        _ => throw ArgumentError('origem desconhecida: $v'),
      };
}

extension DtcEventTypeJson on DtcEventType {
  String get jsonValue => switch (this) {
        DtcEventType.ativo => 'ativo',
        DtcEventType.pendente => 'pendente',
        DtcEventType.permanente => 'permanente',
      };

  static DtcEventType fromJsonValue(String v) => switch (v) {
        'ativo' => DtcEventType.ativo,
        'pendente' => DtcEventType.pendente,
        'permanente' => DtcEventType.permanente,
        _ => throw ArgumentError('tipo de DTC desconhecido: $v'),
      };
}

extension AnomalyTypeJson on AnomalyType {
  String get jsonValue => switch (this) {
        AnomalyType.pontual => 'pontual',
        AnomalyType.tendencia => 'tendencia',
      };

  static AnomalyType fromJsonValue(String v) => switch (v) {
        'pontual' => AnomalyType.pontual,
        'tendencia' => AnomalyType.tendencia,
        _ => throw ArgumentError('tipo de anomalia desconhecido: $v'),
      };
}

extension AnomalySeverityJson on AnomalySeverity {
  String get jsonValue => switch (this) {
        AnomalySeverity.atencao => 'atencao',
        AnomalySeverity.serio => 'serio',
        AnomalySeverity.critico => 'critico',
      };

  static AnomalySeverity fromJsonValue(String v) => switch (v) {
        'atencao' => AnomalySeverity.atencao,
        'serio' => AnomalySeverity.serio,
        'critico' => AnomalySeverity.critico,
        _ => throw ArgumentError('severidade desconhecida: $v'),
      };
}
