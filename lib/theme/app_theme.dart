import 'package:flutter/material.dart';

/// Palette "carnet de brasseur" : parchemin et cuivre plutôt que le bleu
/// Material par défaut. Les quatre teintes de famille (Ale, Lager,
/// Spontanée, Mixte) restent alignées sur celles de [BeerFamily.color].
class AppColors {
  AppColors._();

  // Neutres.
  static const parchment = Color(0xFFF6EFE1);
  static const parchmentDim = Color(0xFFEFE5CF);
  static const cardLight = Color(0xFFFFFBF2);
  static const ink = Color(0xFF2B211A);
  static const inkSoft = Color(0xFF5B4E3F);
  static const outlineLight = Color(0xFFDCCFB2);

  static const stout = Color(0xFF1B1612);
  static const stoutDim = Color(0xFF241D17);
  static const cardDark = Color(0xFF2A221B);
  static const foam = Color(0xFFF3ECDD);
  static const foamSoft = Color(0xFFC9BCA4);
  static const outlineDark = Color(0xFF453A2E);

  // Accents (mêmes teintes que BeerFamily.color, dupliquées ici pour ne
  // pas faire dépendre le thème du modèle métier).
  static const copper = Color(0xFFC9752B); // Ale
  static const gold = Color(0xFFD9A62E); // Lager
  static const wine = Color(0xFF8B3A3A); // Spontanée
  static const walnut = Color(0xFF6B4226); // Mixte

  static const success = Color(0xFF3F7D4C);
  static const error = Color(0xFFB3432B);

  /// Reflet clair du laiton, utilisé pour le cerclage du globe (voir
  /// `lib/screens/world_globe_screen.dart`) — jamais comme couleur de texte
  /// ou de fond, seulement comme point chaud sur du métal.
  static const brassHighlight = Color(0xFFF0D9A0);
}

class AppTheme {
  AppTheme._();

  static const _displayFont = 'BigShouldersDisplay';
  static const _bodyFont = 'Manrope';

  static TextTheme _textTheme(Color onSurface, Color onSurfaceSoft) {
    return TextTheme(
      displayLarge: TextStyle(
        fontFamily: _displayFont,
        fontWeight: FontWeight.w800,
        fontSize: 40,
        height: 1.05,
        letterSpacing: 0.2,
        color: onSurface,
      ),
      displayMedium: TextStyle(
        fontFamily: _displayFont,
        fontWeight: FontWeight.w800,
        fontSize: 32,
        height: 1.08,
        color: onSurface,
      ),
      headlineSmall: TextStyle(
        fontFamily: _displayFont,
        fontWeight: FontWeight.w700,
        fontSize: 26,
        height: 1.1,
        color: onSurface,
      ),
      titleLarge: TextStyle(
        fontFamily: _displayFont,
        fontWeight: FontWeight.w700,
        fontSize: 21,
        height: 1.15,
        color: onSurface,
      ),
      titleMedium: TextStyle(
        fontFamily: _bodyFont,
        fontWeight: FontWeight.w700,
        fontSize: 16,
        color: onSurface,
      ),
      titleSmall: TextStyle(
        fontFamily: _displayFont,
        fontWeight: FontWeight.w700,
        fontSize: 15,
        letterSpacing: 0.6,
        color: onSurfaceSoft,
      ),
      bodyLarge: TextStyle(
        fontFamily: _bodyFont,
        fontWeight: FontWeight.w500,
        fontSize: 16,
        height: 1.4,
        color: onSurface,
      ),
      bodyMedium: TextStyle(
        fontFamily: _bodyFont,
        fontWeight: FontWeight.w500,
        fontSize: 14,
        height: 1.4,
        color: onSurface,
      ),
      bodySmall: TextStyle(
        fontFamily: _bodyFont,
        fontWeight: FontWeight.w500,
        fontSize: 12,
        color: onSurfaceSoft,
      ),
      labelLarge: TextStyle(
        fontFamily: _bodyFont,
        fontWeight: FontWeight.w700,
        fontSize: 14,
        color: onSurface,
      ),
      labelMedium: TextStyle(
        fontFamily: _bodyFont,
        fontWeight: FontWeight.w700,
        fontSize: 12,
        letterSpacing: 0.4,
        color: onSurfaceSoft,
      ),
      labelSmall: TextStyle(
        fontFamily: _bodyFont,
        fontWeight: FontWeight.w600,
        fontSize: 11,
        color: onSurfaceSoft,
      ),
    );
  }

  static ThemeData light = _build(
    brightness: Brightness.light,
    background: AppColors.parchment,
    surface: AppColors.cardLight,
    surfaceDim: AppColors.parchmentDim,
    onSurface: AppColors.ink,
    onSurfaceSoft: AppColors.inkSoft,
    outline: AppColors.outlineLight,
  );

  static ThemeData dark = _build(
    brightness: Brightness.dark,
    background: AppColors.stout,
    surface: AppColors.cardDark,
    surfaceDim: AppColors.stoutDim,
    onSurface: AppColors.foam,
    onSurfaceSoft: AppColors.foamSoft,
    outline: AppColors.outlineDark,
  );

  static ThemeData _build({
    required Brightness brightness,
    required Color background,
    required Color surface,
    required Color surfaceDim,
    required Color onSurface,
    required Color onSurfaceSoft,
    required Color outline,
  }) {
    final scheme = ColorScheme(
      brightness: brightness,
      primary: AppColors.copper,
      onPrimary: Colors.white,
      primaryContainer: AppColors.copper.withValues(alpha: 0.16),
      onPrimaryContainer: onSurface,
      secondary: AppColors.gold,
      onSecondary: AppColors.ink,
      secondaryContainer: AppColors.gold.withValues(alpha: 0.18),
      onSecondaryContainer: onSurface,
      tertiary: AppColors.wine,
      onTertiary: Colors.white,
      error: AppColors.error,
      onError: Colors.white,
      surface: surface,
      onSurface: onSurface,
      surfaceContainerHighest: surfaceDim,
      onSurfaceVariant: onSurfaceSoft,
      outline: outline,
      outlineVariant: outline.withValues(alpha: 0.6),
      inverseSurface: onSurface,
      onInverseSurface: background,
    );

    final textTheme = _textTheme(onSurface, onSurfaceSoft);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      fontFamily: _bodyFont,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: onSurface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.headlineSmall,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: outline.withValues(alpha: 0.5)),
        ),
        margin: EdgeInsets.zero,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceDim,
        labelStyle: textTheme.labelLarge,
        side: BorderSide(color: outline.withValues(alpha: 0.6)),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      dividerTheme: DividerThemeData(color: outline.withValues(alpha: 0.6)),
      listTileTheme: ListTileThemeData(
        iconColor: AppColors.copper,
        textColor: onSurface,
        titleTextStyle: textTheme.titleMedium,
        subtitleTextStyle: textTheme.bodySmall,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.copper,
          foregroundColor: Colors.white,
          textStyle: textTheme.labelLarge,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: const StadiumBorder(),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.copper,
          side: const BorderSide(color: AppColors.copper),
          textStyle: textTheme.labelLarge,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: const StadiumBorder(),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.copper,
          textStyle: textTheme.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceDim,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.copper, width: 2),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.copper,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.copper
              : outline,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.copper.withValues(alpha: 0.4)
              : surfaceDim,
        ),
      ),
    );
  }
}
