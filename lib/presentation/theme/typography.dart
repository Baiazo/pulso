import 'package:flutter/widgets.dart';

import 'colors.dart';

const _sansFamily = 'IBM Plex Sans';
const _monoFamily = 'IBM Plex Mono';
const _tabularNums = [FontFeature.tabularFigures()];

/// Escala tipográfica do mockup — IBM Plex Sans em vez de Inter/Roboto:
/// numerais tabulares de verdade em todo peso, e o 1/7/4 inconfundível de
/// relance importa numa tela de instrumento. Plex Mono só onde o
/// conteúdo é literal de máquina (DTC, VIN, PID, eixo, log).
///
/// `letterSpacing` no mockup vem em `em`; aqui já convertido pra px
/// (`em × fontSize`), que é como `TextStyle.letterSpacing` espera.
/// `height` é multiplicador de fontSize, não px — também já convertido.
class PulsoTypography {
  const PulsoTypography._();

  static const displayDrive = TextStyle(
    fontFamily: _sansFamily,
    fontSize: 96,
    fontWeight: FontWeight.w600,
    height: 0.95,
    letterSpacing: -2.88,
    color: PulsoColors.ink,
    fontFeatures: _tabularNums,
  );

  static const displayHero = TextStyle(
    fontFamily: _sansFamily,
    fontSize: 72,
    fontWeight: FontWeight.w600,
    height: 1.0,
    letterSpacing: -2.16,
    color: PulsoColors.ink,
    fontFeatures: _tabularNums,
  );

  static const displayGauge = TextStyle(
    fontFamily: _sansFamily,
    fontSize: 60,
    fontWeight: FontWeight.w600,
    height: 1.0,
    letterSpacing: -1.8,
    color: PulsoColors.ink,
    fontFeatures: _tabularNums,
  );

  static const valueLg = TextStyle(
    fontFamily: _sansFamily,
    fontSize: 40,
    fontWeight: FontWeight.w600,
    height: 1.0,
    letterSpacing: -0.8,
    color: PulsoColors.ink,
    fontFeatures: _tabularNums,
  );

  static const valueMd = TextStyle(
    fontFamily: _sansFamily,
    fontSize: 28,
    fontWeight: FontWeight.w600,
    height: 32 / 28,
    letterSpacing: -0.28,
    color: PulsoColors.ink,
    fontFeatures: _tabularNums,
  );

  static const titleScreen = TextStyle(
    fontFamily: _sansFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 26 / 20,
    letterSpacing: -0.2,
    color: PulsoColors.ink,
  );

  /// UPPERCASE aplicado pelo widget (`.toUpperCase()`), não pelo estilo.
  static const titleSection = TextStyle(
    fontFamily: _sansFamily,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    height: 16 / 13,
    letterSpacing: 1.3,
    color: PulsoColors.ink2,
  );

  static const body = TextStyle(
    fontFamily: _sansFamily,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 22 / 15,
    letterSpacing: 0,
    color: PulsoColors.ink2,
  );

  static const label = TextStyle(
    fontFamily: _sansFamily,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 18 / 13,
    letterSpacing: 0.13,
    color: PulsoColors.ink2,
  );

  /// UPPERCASE aplicado pelo widget.
  static const micro = TextStyle(
    fontFamily: _sansFamily,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 14 / 11,
    letterSpacing: 0.66,
    color: PulsoColors.inkMeta,
  );

  static const monoCode = TextStyle(
    fontFamily: _monoFamily,
    fontSize: 15,
    fontWeight: FontWeight.w500,
    height: 20 / 15,
    letterSpacing: 0.3,
    color: PulsoColors.ink,
    fontFeatures: _tabularNums,
  );
}
