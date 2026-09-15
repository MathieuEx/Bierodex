import 'package:flutter/material.dart';

/// Palette alignée sur le logo (assets/logo.png) : bleu nuit profond,
/// orange ambré et or de la bière, crème de la mousse, liseré bleu ciel.
/// Les quatre teintes de famille (Ale, Lager, Spontanée, Mixte) restent
/// alignées sur celles de [BeerFamily.color].
class AppColors {
  AppColors._();

  // Neutres clairs : blanc bleuté + encre bleu nuit.
  static const mist = Color(0xFFF1F4F9);
  static const mistDim = Color(0xFFE3E9F2);
  static const cardLight = Color(0xFFFFFFFF);
  static const ink = Color(0xFF0A1F3C);
  static const inkSoft = Color(0xFF4B5D78);
  static const outlineLight = Color(0xFFCAD4E2);

  // Neutres sombres : le bleu nuit du logo + la crème de la mousse.
  static const night = Color(0xFF041833);
  static const nightDim = Color(0xFF0A2444);
  static const cardDark = Color(0xFF0E2A4D);
  static const cardDarkHigh = Color(0xFF14365E);
  static const foam = Color(0xFFF8ECD4);
  static const foamSoft = Color(0xFFA8B7CC);
  static const outlineDark = Color(0xFF1F3F66);

  // Accents (mêmes teintes que BeerFamily.color, dupliquées ici pour ne
  // pas faire dépendre le thème du modèle métier).
  static const amber = Color(0xFFF28A17); // Ale — orange du lettrage
  static const gold = Color(0xFFFDB602); // Lager — or de la bière
  static const wine = Color(0xFF8B3A3A); // Spontanée
  static const walnut = Color(0xFF6B4226); // Mixte

  /// Liseré bleu ciel du lettrage et de la loupe.
  static const sky = Color(0xFF5FB4E8);

  static const success = Color(0xFF5BA33F); // vert du houblon
  static const error = Color(0xFFD9483B);
}

/// Dégradés tirés du logo : le lettrage passe de l'or (haut) à l'orange
/// (bas), le cadre de l'icône fait de même en diagonale.
class AppGradients {
  AppGradients._();

  static const amber = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFC93C), AppColors.amber],
  );

  static const frame = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.gold, AppColors.amber, Color(0xFFD86A0C)],
  );

  static const cardDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.cardDarkHigh, AppColors.cardDark],
  );

  /// Fond « ciel de nuit » des écrans d'accueil (âge légal, connexion).
  static const nightGlow = RadialGradient(
    center: Alignment(0, -0.45),
    radius: 1.1,
    colors: [Color(0xFF123A66), AppColors.nightDim, AppColors.night],
    stops: [0, 0.45, 1],
  );
}

class AppTheme {
  AppTheme._();

  /// Titres : géométrique, épaisse et penchée comme le lettrage du logo.
  static const displayFont = 'Exo2';
  static const bodyFont = 'Manrope';

  static const radiusCard = 20.0;
  static const radiusControl = 14.0;

  /// Style de titre de la marque, réutilisable hors [TextTheme] (cartes de
  /// partage, repères de carte).
  static TextStyle display(
    double size,
    FontWeight weight,
    Color color, {
    double height = 1.1,
    double letterSpacing = 0,
    bool italic = true,
  }) {
    return TextStyle(
      fontFamily: displayFont,
      fontStyle: italic ? FontStyle.italic : FontStyle.normal,
      fontWeight: weight,
      fontVariations: [FontVariation.weight(weight.value.toDouble())],
      fontSize: size,
      height: height,
      letterSpacing: letterSpacing,
      color: color,
    );
  }

  static TextStyle _body(
    double size,
    FontWeight weight,
    Color color, {
    double? height,
    double letterSpacing = 0,
  }) {
    return TextStyle(
      fontFamily: bodyFont,
      fontWeight: weight,
      fontVariations: [FontVariation.weight(weight.value.toDouble())],
      fontSize: size,
      height: height,
      letterSpacing: letterSpacing,
      color: color,
    );
  }

  static TextTheme _textTheme(Color onSurface, Color onSurfaceSoft) {
    return TextTheme(
      displayLarge: display(40, FontWeight.w900, onSurface, height: 1.05),
      displayMedium: display(32, FontWeight.w900, onSurface, height: 1.08),
      displaySmall: display(28, FontWeight.w800, onSurface),
      headlineMedium: display(28, FontWeight.w800, onSurface),
      headlineSmall: display(24, FontWeight.w800, onSurface),
      titleLarge: display(20, FontWeight.w800, onSurface, height: 1.15),
      titleMedium: _body(16, FontWeight.w700, onSurface),
      titleSmall: display(
        14,
        FontWeight.w700,
        onSurfaceSoft,
        letterSpacing: 1.2,
      ),
      bodyLarge: _body(16, FontWeight.w500, onSurface, height: 1.4),
      bodyMedium: _body(14, FontWeight.w500, onSurface, height: 1.4),
      bodySmall: _body(12, FontWeight.w500, onSurfaceSoft),
      labelLarge: _body(14, FontWeight.w800, onSurface, letterSpacing: 0.3),
      labelMedium: _body(
        12,
        FontWeight.w700,
        onSurfaceSoft,
        letterSpacing: 0.4,
      ),
      labelSmall: _body(11, FontWeight.w600, onSurfaceSoft),
    );
  }

  static ThemeData light = _build(
    brightness: Brightness.light,
    background: AppColors.mist,
    surface: AppColors.cardLight,
    surfaceDim: AppColors.mistDim,
    onSurface: AppColors.ink,
    onSurfaceSoft: AppColors.inkSoft,
    outline: AppColors.outlineLight,
  );

  static ThemeData dark = _build(
    brightness: Brightness.dark,
    background: AppColors.night,
    surface: AppColors.cardDark,
    surfaceDim: AppColors.nightDim,
    onSurface: AppColors.foam,
    onSurfaceSoft: AppColors.foamSoft,
    outline: AppColors.outlineDark,
  );

  /// Fond en dégradé or → orange pour les boutons pleins, comme le
  /// lettrage du logo ; grisé quand le bouton est désactivé.
  static Widget _amberButtonBackground(
    BuildContext context,
    Set<WidgetState> states,
    Widget? child,
  ) {
    final disabled = states.contains(WidgetState.disabled);
    final pressed = states.contains(WidgetState.pressed);
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: disabled ? null : AppGradients.amber,
        color: disabled
            ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.12)
            : null,
        borderRadius: BorderRadius.circular(radiusControl),
        border: disabled
            ? null
            : Border.all(
                color: AppColors.gold.withValues(alpha: pressed ? 1 : 0.7),
              ),
        boxShadow: disabled
            ? null
            : [
                BoxShadow(
                  color: AppColors.amber.withValues(
                    alpha: pressed ? 0.2 : 0.35,
                  ),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: child,
    );
  }

  static ThemeData _build({
    required Brightness brightness,
    required Color background,
    required Color surface,
    required Color surfaceDim,
    required Color onSurface,
    required Color onSurfaceSoft,
    required Color outline,
  }) {
    final isDark = brightness == Brightness.dark;
    // En sombre, le liseré bleu ciel du logo souligne cartes et champs.
    final edge = isDark ? AppColors.sky.withValues(alpha: 0.22) : outline;
    final accentText = isDark ? AppColors.gold : AppColors.amber;

    final scheme = ColorScheme(
      brightness: brightness,
      primary: AppColors.amber,
      onPrimary: AppColors.night,
      primaryContainer: AppColors.amber.withValues(alpha: 0.18),
      onPrimaryContainer: onSurface,
      secondary: AppColors.gold,
      onSecondary: AppColors.night,
      secondaryContainer: AppColors.gold.withValues(alpha: 0.18),
      onSecondaryContainer: onSurface,
      tertiary: AppColors.sky,
      onTertiary: AppColors.night,
      error: AppColors.error,
      onError: Colors.white,
      surface: surface,
      onSurface: onSurface,
      surfaceContainerLowest: background,
      surfaceContainerLow: surfaceDim,
      surfaceContainer: surfaceDim,
      surfaceContainerHigh: surface,
      surfaceContainerHighest: isDark ? AppColors.cardDarkHigh : surfaceDim,
      onSurfaceVariant: onSurfaceSoft,
      outline: outline,
      outlineVariant: edge,
      inverseSurface: onSurface,
      onInverseSurface: background,
      inversePrimary: AppColors.amber,
      shadow: Colors.black,
      scrim: Colors.black,
      surfaceTint: Colors.transparent,
    );

    final textTheme = _textTheme(onSurface, onSurfaceSoft);
    final controlShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusControl),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      canvasColor: background,
      fontFamily: bodyFont,
      textTheme: textTheme,
      iconTheme: IconThemeData(color: onSurface),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        foregroundColor: onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.headlineSmall,
        actionsIconTheme: IconThemeData(color: accentText),
      ),
      cardTheme: CardThemeData(
        color: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusCard),
          side: BorderSide(color: edge),
        ),
        margin: EdgeInsets.zero,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: isDark ? AppColors.nightDim : surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 72,
        indicatorColor: isDark
            ? AppColors.cardDarkHigh
            : AppColors.amber.withValues(alpha: 0.18),
        indicatorShape: controlShape,
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? accentText
                : onSurfaceSoft,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? textTheme.labelMedium!.copyWith(color: accentText)
              : textTheme.labelMedium!,
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: accentText,
        unselectedLabelColor: onSurfaceSoft,
        labelStyle: display(15, FontWeight.w800, accentText),
        unselectedLabelStyle: display(15, FontWeight.w700, onSurfaceSoft),
        indicatorSize: TabBarIndicatorSize.label,
        indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(color: AppColors.amber, width: 3),
          borderRadius: BorderRadius.vertical(top: Radius.circular(3)),
        ),
        dividerColor: edge,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceDim,
        selectedColor: AppColors.amber.withValues(alpha: 0.22),
        checkmarkColor: accentText,
        labelStyle: textTheme.labelLarge,
        side: BorderSide(color: edge),
        shape: controlShape,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      ),
      dividerTheme: DividerThemeData(color: edge),
      listTileTheme: ListTileThemeData(
        iconColor: AppColors.amber,
        textColor: onSurface,
        titleTextStyle: textTheme.titleMedium,
        subtitleTextStyle: textTheme.bodySmall,
        shape: controlShape,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.night,
          disabledBackgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          textStyle: display(16, FontWeight.w900, AppColors.night),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
          shape: controlShape,
        ).copyWith(backgroundBuilder: _amberButtonBackground),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: surface,
          foregroundColor: accentText,
          textStyle: textTheme.labelLarge,
          shape: controlShape,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: accentText,
          side: BorderSide(
            color: accentText.withValues(alpha: 0.7),
            width: 1.5,
          ),
          textStyle: textTheme.labelLarge,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: controlShape,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: isDark ? AppColors.sky : AppColors.amber,
          textStyle: textTheme.labelLarge,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.amber,
        foregroundColor: AppColors.night,
        elevation: 2,
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          selectedBackgroundColor: AppColors.amber.withValues(alpha: 0.22),
          selectedForegroundColor: accentText,
          side: BorderSide(color: edge),
          shape: controlShape,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceDim,
        labelStyle: textTheme.bodyMedium?.copyWith(color: onSurfaceSoft),
        floatingLabelStyle: textTheme.bodyMedium?.copyWith(color: accentText),
        prefixIconColor: onSurfaceSoft,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusControl),
          borderSide: BorderSide(color: edge),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusControl),
          borderSide: BorderSide(color: edge),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusControl),
          borderSide: const BorderSide(color: AppColors.amber, width: 2),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: textTheme.headlineSmall,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusCard),
          side: BorderSide(color: edge),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: isDark ? AppColors.nightDim : surface,
        surfaceTintColor: Colors.transparent,
        dragHandleColor: onSurfaceSoft,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(radiusCard)),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusControl),
          side: BorderSide(color: edge),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark ? AppColors.cardDarkHigh : AppColors.ink,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: AppColors.foam),
        actionTextColor: AppColors.gold,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusControl),
          side: BorderSide(color: AppColors.sky.withValues(alpha: 0.3)),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: AppColors.amber,
        linearTrackColor: edge,
        circularTrackColor: Colors.transparent,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.amber,
        thumbColor: AppColors.gold,
        inactiveTrackColor: edge,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.amber
              : Colors.transparent,
        ),
        checkColor: const WidgetStatePropertyAll(AppColors.night),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      ),
      radioTheme: const RadioThemeData(
        fillColor: WidgetStatePropertyAll(AppColors.amber),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.gold
              : onSurfaceSoft,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.amber.withValues(alpha: 0.5)
              : surfaceDim,
        ),
        trackOutlineColor: WidgetStatePropertyAll(edge),
      ),
    );
  }
}
