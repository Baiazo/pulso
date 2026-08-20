import 'package:flutter/material.dart';

import 'colors.dart';
import 'spacing.dart';
import 'typography.dart';

/// `ThemeData` construído sobre os tokens do mockup — widgets do app
/// devem preferir `PulsoColors`/`PulsoTypography`/`PulsoSpacing`
/// diretamente (o design é específico demais pro Material genérico), mas
/// o `ThemeData` cobre os poucos widgets Material usados (Scaffold,
/// InkWell, etc.) pra não destoar.
ThemeData buildPulsoTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: PulsoColors.accent,
    brightness: Brightness.dark,
    surface: PulsoColors.surface,
    error: PulsoColors.critical,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: PulsoColors.bg,
    colorScheme: colorScheme,
    fontFamily: 'IBM Plex Sans',
    textTheme: const TextTheme(
      displayLarge: PulsoTypography.displayHero,
      displayMedium: PulsoTypography.displayGauge,
      headlineSmall: PulsoTypography.titleScreen,
      titleSmall: PulsoTypography.titleSection,
      bodyLarge: PulsoTypography.body,
      labelLarge: PulsoTypography.label,
      labelSmall: PulsoTypography.micro,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: PulsoColors.bg,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      titleTextStyle: PulsoTypography.titleScreen,
      iconTheme: IconThemeData(color: PulsoColors.ink),
    ),
    cardTheme: CardThemeData(
      color: PulsoColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(PulsoRadius.card),
        side: const BorderSide(color: PulsoColors.hairline),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: PulsoColors.hairline,
      thickness: 1,
      space: 1,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: PulsoColors.accent,
        foregroundColor: PulsoColors.accentInk,
        disabledBackgroundColor: PulsoColors.surfaceRaised,
        disabledForegroundColor: PulsoColors.inkMeta,
        minimumSize: const Size.fromHeight(52),
        textStyle: PulsoTypography.label.copyWith(
          fontWeight: FontWeight.w600,
          color: PulsoColors.accentInk,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PulsoRadius.button),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: PulsoColors.ink,
        minimumSize: const Size.fromHeight(52),
        side: const BorderSide(color: PulsoColors.hairlineStrong),
        textStyle: PulsoTypography.label.copyWith(fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PulsoRadius.button),
        ),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: PulsoColors.surfaceRaised,
      contentTextStyle: PulsoTypography.body.copyWith(color: PulsoColors.ink),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(PulsoRadius.card),
      ),
    ),
  );
}
