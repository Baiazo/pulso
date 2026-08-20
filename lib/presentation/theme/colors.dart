import 'package:flutter/widgets.dart';

/// Paleta do sistema visual (docs/design/pulso-telas-referencia.html,
/// seção "PRONTO PARA O TEMA FLUTTER"). Tema escuro único — o mockup não
/// especifica um claro, e o instrumento automotivo de referência (§ nota
/// 01 do mockup: "o arco normal é neutro, não verde") é pensado pra uso
/// noturno tanto quanto diurno.
class PulsoColors {
  const PulsoColors._();

  // Superfícies — degrau de claridade carrega a hierarquia, não sombra
  // (nota "ELEVAÇÃO — LUZ, NÃO SOMBRA" do mockup).
  static const bg = Color(0xFF0A0C10);
  static const surface = Color(0xFF12161C);
  static const surfaceRaised = Color(0xFF1A1F27);
  static const hairline = Color(0xFF232A33);
  static const hairlineStrong = Color(0xFF2E3742);

  // Tinta
  static const ink = Color(0xFFFFFFFF); // 17.8:1 — só texto, nunca área grande
  static const ink2 = Color(0xFFA8B3C1); // 8.4:1 — rótulo, texto de apoio
  static const inkMeta = Color(0xFF7D8896); // 4.9:1 — metadado (data, contexto)
  static const inkSoft = Color(0xFF6B7684); // 3.9:1 — reprova em texto; só grade/escala

  // Marca — teal frio, deliberadamente distante dos 4 estados de
  // severidade pra nunca ser lido como alerta.
  static const accent = Color(0xFF31B7AE);
  static const accentDim = Color(0xFF1B5F5B);
  static const accentInk = Color(0xFF04211F);

  // Estado — reservado, nunca decorativo. `normal` só aparece no selo de
  // estado (ícone + palavra), nunca pinta o arco (nota 01 do mockup).
  static const normal = Color(0xFF0CA30C);
  static const normalInk = Color(0xFF3FBF3F);
  static const attention = Color(0xFFFAB219);
  static const attentionInk = Color(0xFFFAB219);
  static const serious = Color(0xFFEC835A);
  static const seriousInk = Color(0xFFEC835A);
  static const critical = Color(0xFFD03B3B); // arco/preenchimento (≥3:1)
  static const criticalInk = Color(0xFFEF6A63); // texto/ícone (6.1:1 — #D03B3B reprova em texto)

  /// Série de gráfico multi-linha — ordem fixa, nunca reordenar (filtrar
  /// uma série não recolore as demais). Máximo 4 séries por gráfico.
  static const series = [
    Color(0xFF3987E5),
    Color(0xFFD95926),
    Color(0xFF199E70),
    Color(0xFFC98500),
    Color(0xFFD55181),
    Color(0xFF9085E9),
    Color(0xFFE66767),
    Color(0xFF008300),
  ];
}
