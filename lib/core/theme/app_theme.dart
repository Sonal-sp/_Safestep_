import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';

/// SafeStep Global Theme — Light + Dark
/// Accessibility-first: min 48px tap targets, ≥16px text, WCAG contrast.
class AppTheme {
  AppTheme._();

  static const double _radius = 16.0;
  static const double _radiusLg = 24.0;
  static const double _elevation = 0.0;
  static const String _fontFamily = 'Roboto';

  // ─── LIGHT THEME ────────────────────────────────────────────
  static ThemeData get light {
    final colorScheme = const ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: Colors.white,
      primaryContainer: Color(0xFFDBEAFE),
      onPrimaryContainer: Color(0xFF1E40AF),
      secondary: AppColors.secondary,
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFFDCFCE7),
      onSecondaryContainer: Color(0xFF166534),
      tertiary: AppColors.warning,
      onTertiary: Colors.white,
      error: AppColors.error,
      onError: Colors.white,
      errorContainer: AppColors.errorLight,
      onErrorContainer: Color(0xFF991B1B),
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      onSurfaceVariant: AppColors.textSecondary,
      outline: AppColors.border,
      outlineVariant: AppColors.divider,
      shadow: Color(0x1A000000),
    );

    return _buildTheme(colorScheme, Brightness.light);
  }

  // ─── DARK THEME ─────────────────────────────────────────────
  static ThemeData get dark {
    final colorScheme = const ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.primaryLight,
      onPrimary: Color(0xFF1E3A5F),
      primaryContainer: Color(0xFF1E3A8A),
      onPrimaryContainer: Color(0xFFDBEAFE),
      secondary: AppColors.secondaryLight,
      onSecondary: Color(0xFF0A3622),
      secondaryContainer: Color(0xFF14532D),
      onSecondaryContainer: Color(0xFFDCFCE7),
      tertiary: Color(0xFFFBBF24),
      onTertiary: Color(0xFF451A03),
      error: Color(0xFFFCA5A5),
      onError: Color(0xFF7F1D1D),
      errorContainer: Color(0xFF991B1B),
      onErrorContainer: Color(0xFFFECACA),
      surface: AppColors.darkSurface,
      onSurface: AppColors.darkTextPrimary,
      onSurfaceVariant: AppColors.darkTextSecondary,
      outline: AppColors.darkBorder,
      outlineVariant: AppColors.darkDivider,
      shadow: Color(0x40000000),
    );

    return _buildTheme(colorScheme, Brightness.dark);
  }

  // ─── SHARED THEME BUILDER ───────────────────────────────────
  static ThemeData _buildTheme(ColorScheme colorScheme, Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBackground : AppColors.background;
    final cardColor = isDark ? AppColors.darkCard : AppColors.card;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    final textTheme = TextTheme(
      displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: textPrimary, height: 1.2, letterSpacing: -0.5),
      displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: textPrimary, height: 1.25, letterSpacing: -0.3),
      headlineLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: textPrimary, height: 1.3),
      headlineMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: textPrimary, height: 1.3),
      titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: textPrimary, height: 1.3),
      titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: textPrimary, height: 1.4),
      titleSmall: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textPrimary, height: 1.4),
      bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: textPrimary, height: 1.5),
      bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: textSecondary, height: 1.5),
      bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: textSecondary, height: 1.5),
      labelLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textPrimary, letterSpacing: 0.5),
      labelMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textPrimary),
      labelSmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: textSecondary),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: _fontFamily,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: bgColor,
      dividerColor: colorScheme.outlineVariant,
      textTheme: textTheme,

      // ─── APP BAR ──────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: bgColor,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
        systemOverlayStyle: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        titleTextStyle: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        iconTheme: IconThemeData(color: textPrimary, size: 24),
      ),

      // ─── CARDS ────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: _elevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radiusLg),
          side: BorderSide(color: colorScheme.outlineVariant, width: 1),
        ),
        shadowColor: colorScheme.shadow,
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
      ),

      // ─── ELEVATED BUTTONS ────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_radius)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, fontFamily: _fontFamily),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),

      // ─── FILLED BUTTONS ──────────────────────────────────
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_radius)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, fontFamily: _fontFamily),
        ),
      ),

      // ─── OUTLINED BUTTONS ────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_radius)),
          side: BorderSide(color: colorScheme.primary, width: 1.5),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, fontFamily: _fontFamily),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),

      // ─── TEXT BUTTONS ────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, fontFamily: _fontFamily),
          minimumSize: const Size(48, 48),
        ),
      ),

      // ─── INPUT FIELDS ────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? AppColors.darkSurface : AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radius),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radius),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radius),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radius),
          borderSide: BorderSide(color: colorScheme.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radius),
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
        hintStyle: TextStyle(color: textSecondary, fontWeight: FontWeight.w400),
        labelStyle: TextStyle(color: textSecondary, fontWeight: FontWeight.w500),
        floatingLabelStyle: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.w600),
        errorStyle: TextStyle(color: colorScheme.error, fontSize: 12),
        prefixIconColor: colorScheme.primary,
      ),

      // ─── FLOATING ACTION BUTTON ──────────────────────────
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_radius)),
      ),

      // ─── BOTTOM NAV / NAV BAR ────────────────────────────
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: cardColor,
        elevation: 0,
        indicatorColor: colorScheme.primary.withAlpha(25),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: colorScheme.primary, fontFamily: _fontFamily);
          }
          return TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: textSecondary, fontFamily: _fontFamily);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: colorScheme.primary, size: 26);
          }
          return IconThemeData(color: textSecondary, size: 24);
        }),
      ),

      // ─── SWITCH ──────────────────────────────────────────
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return colorScheme.primary;
          return isDark ? AppColors.darkTextTertiary : AppColors.textTertiary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return colorScheme.primary.withAlpha(60);
          return isDark ? AppColors.darkBorder : AppColors.border;
        }),
      ),

      // ─── CHIP ────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.background,
        selectedColor: colorScheme.primaryContainer,
        labelStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),

      // ─── DIALOG ──────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: cardColor,
        surfaceTintColor: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_radiusLg)),
        titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: textPrimary, fontFamily: _fontFamily),
        contentTextStyle: TextStyle(fontSize: 14, color: textSecondary, height: 1.5, fontFamily: _fontFamily),
      ),

      // ─── BOTTOM SHEET ────────────────────────────────────
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: cardColor,
        surfaceTintColor: cardColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        dragHandleColor: textSecondary.withAlpha(80),
        dragHandleSize: const Size(40, 4),
        showDragHandle: true,
      ),

      // ─── SNACKBAR ────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? AppColors.darkCard : AppColors.textPrimary,
        contentTextStyle: TextStyle(
          color: isDark ? AppColors.darkTextPrimary : Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
        elevation: 4,
      ),

      // ─── DIVIDER ─────────────────────────────────────────
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),

      // ─── POPUP MENU ──────────────────────────────────────
      popupMenuTheme: PopupMenuThemeData(
        color: cardColor,
        surfaceTintColor: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
      ),

      // ─── LIST TILE ───────────────────────────────────────
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_radius)),
        iconColor: colorScheme.primary,
        titleTextStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textPrimary, fontFamily: _fontFamily),
        subtitleTextStyle: TextStyle(fontSize: 13, color: textSecondary, fontFamily: _fontFamily),
      ),

      // ─── TAB BAR ─────────────────────────────────────────
      tabBarTheme: TabBarThemeData(
        labelColor: colorScheme.primary,
        unselectedLabelColor: textSecondary,
        indicatorColor: colorScheme.primary,
        labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, fontFamily: _fontFamily),
        unselectedLabelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, fontFamily: _fontFamily),
      ),

      // ─── PROGRESS INDICATOR ──────────────────────────────
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
        linearTrackColor: colorScheme.primary.withAlpha(30),
        circularTrackColor: colorScheme.primary.withAlpha(30),
      ),

      // ─── TOOLTIP ─────────────────────────────────────────
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surface : AppColors.textPrimary,
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: TextStyle(
          color: isDark ? AppColors.textPrimary : Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
