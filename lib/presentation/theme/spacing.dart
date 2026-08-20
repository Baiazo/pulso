/// Espaçamento e raio — escala base 4 dp (docs/design). Nada acima de
/// 20 dp em container: canto muito arredondado rouba largura útil de
/// número tabular e amolece o tom de instrumento.
class PulsoSpacing {
  const PulsoSpacing._();

  static const s1 = 4.0; // valor ↔ unidade
  static const s2 = 8.0; // rótulo ↔ valor
  static const s3 = 12.0; // gap entre tiles
  static const s4 = 16.0; // padding de card · margem da tela
  static const s5 = 20.0; // entre blocos irmãos
  static const s6 = 24.0; // antes de título de seção
  static const s7 = 32.0; // separação de grupo
  static const s8 = 48.0; // respiro de estado vazio · alvo mínimo de toque
}

class PulsoRadius {
  const PulsoRadius._();

  static const chip = 4.0;
  static const button = 8.0;
  static const card = 12.0;
  static const sheet = 16.0;
  static const modal = 20.0;
  static const pill = 999.0; // chip de conexão
}
