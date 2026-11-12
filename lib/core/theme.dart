import 'package:flutter/material.dart';

/// Colors of the sign-in screens (login hero and sheet).
class AppColors {
  static const primary = Color(0xFF3A7862);
  static const hero = Color(0xFF23806A);
  static const primaryLight = Color(0xFF4F8C76);
  static const mint = Color(0xFFDDF5EE);
  static const sheet = Color(0xFFF7F9F7);
  static const textDark = Color(0xFF1B2420);
  static const textMuted = Color(0xFF5E6B66);
  static const border = Color(0xFFD9DFDC);
}

/// Monospaced text of the sign-in screens: the brand's data font, with the system ones as fallback.
class AppFonts {
  static const mono = GuardianFonts.data;
  static const monoFallback = ['Menlo', 'Courier', 'monospace'];
}

/// Guardian+ palette (report, section 3.1.1.1 B).
abstract final class GuardianColors {
  static const primary = Color(0xFF167A62);
  static const primaryForeground = Color(0xFFFFFFFF);
  static const secondaryPastel = Color(0xFFD3F8F0);
  static const secondaryForeground = Color(0xFF169084);
  static const accentMint = Color(0xFFD9F0E7);
  static const accentForeground = Color(0xFF123128);
  static const neutralBackground = Color(0xFFF8FBF9);
  static const neutralForeground = Color(0xFF123128);
  static const neutralMuted = Color(0xFFEEF4F1);
  static const mutedForeground = Color(0xFF587168);
  static const border = Color(0xFFCFE0D8);
  static const surfaceCard = Color(0xFFFFFFFF);
  static const destructive = Color(0xFFC53B3B);
  static const destructiveForeground = Color(0xFFFFFFFF);
  static const destructivePastel = Color(0xFFFBE4E4);
  static const pastelOrange = Color(0xFFFFE6CC);
  static const pastelOrangeText = Color(0xFFB25900);
  static const pastelOrangeDeep = Color(0xFF7A3E00);
  // Yellow of "En observación" and of what is coming next
  static const noticeContainer = Color(0xFFFFF4CC);
  static const onNoticeContainer = Color(0xFF806600);
}

/// Radius tokens (report, section 3.1.1.1 D): subtle 6, default 12, large 20.
abstract final class GuardianRadius {
  static const subtle = 6.0;
  static const medium = 12.0;
  static const large = 20.0;
}

/// Brand typefaces: Plus Jakarta Sans for headings, Inter for UI text, JetBrains Mono for data.
abstract final class GuardianFonts {
  static const heading = 'PlusJakartaSans';
  static const body = 'Inter';
  static const data = 'JetBrainsMono';
}

/// Timestamps, counters and phone numbers. Material 3 has no monospaced slot, so it lives apart.
const dataLabelStyle = TextStyle(
  fontFamily: GuardianFonts.data,
  fontWeight: FontWeight.w500,
  fontSize: 13,
  height: 18 / 13,
);

/// Readings of the vital signs ("78 lpm", "36.6 °C"); the larger ones copy it with their own size.
const dataMetricStyle = TextStyle(
  fontFamily: GuardianFonts.data,
  fontWeight: FontWeight.w500,
  fontSize: 24,
  height: 26 / 24,
);

/// The report defines a single light palette ("a calm home, not a hospital"), so there is no dark theme yet.
abstract final class GuardianTheme {
  static ThemeData light() {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: GuardianColors.primary,
      onPrimary: GuardianColors.primaryForeground,
      primaryContainer: GuardianColors.secondaryPastel,
      onPrimaryContainer: GuardianColors.secondaryForeground,
      secondary: GuardianColors.secondaryForeground,
      onSecondary: GuardianColors.primaryForeground,
      secondaryContainer: GuardianColors.accentMint,
      onSecondaryContainer: GuardianColors.accentForeground,
      tertiary: GuardianColors.pastelOrangeText,
      onTertiary: GuardianColors.primaryForeground,
      tertiaryContainer: GuardianColors.pastelOrange,
      onTertiaryContainer: GuardianColors.pastelOrangeDeep,
      error: GuardianColors.destructive,
      onError: GuardianColors.destructiveForeground,
      errorContainer: GuardianColors.destructivePastel,
      onErrorContainer: GuardianColors.destructive,
      surface: GuardianColors.surfaceCard,
      onSurface: GuardianColors.neutralForeground,
      surfaceContainerHighest: GuardianColors.neutralMuted,
      surfaceContainerHigh: GuardianColors.neutralMuted,
      surfaceContainer: GuardianColors.neutralMuted,
      onSurfaceVariant: GuardianColors.mutedForeground,
      outline: GuardianColors.border,
      outlineVariant: GuardianColors.border,
    );

    final mediumShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(GuardianRadius.medium));

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: GuardianColors.neutralBackground,
      fontFamily: GuardianFonts.body,
      textTheme: _textTheme,
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52), shape: mediumShape),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(style: OutlinedButton.styleFrom(shape: mediumShape)),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(GuardianRadius.medium)),
      ),
      dividerTheme: const DividerThemeData(color: GuardianColors.border, space: 1, thickness: 1),
      snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: GuardianColors.surfaceCard,
        showDragHandle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(GuardianRadius.large)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: GuardianColors.surfaceCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(GuardianRadius.large)),
      ),
    );
  }

  // Mobile type scale (report, section 3.1.1.1 C)
  static const _textTheme = TextTheme(
    headlineMedium: TextStyle(fontFamily: GuardianFonts.heading, fontWeight: FontWeight.w700, fontSize: 28, height: 34 / 28),
    headlineSmall: TextStyle(fontFamily: GuardianFonts.heading, fontWeight: FontWeight.w600, fontSize: 22, height: 28 / 22),
    titleLarge: TextStyle(fontFamily: GuardianFonts.heading, fontWeight: FontWeight.w700, fontSize: 20, height: 26 / 20),
    titleMedium: TextStyle(fontFamily: GuardianFonts.heading, fontWeight: FontWeight.w600, fontSize: 16, height: 22 / 16),
    titleSmall: TextStyle(fontFamily: GuardianFonts.body, fontWeight: FontWeight.w600, fontSize: 14, height: 20 / 14),
    bodyLarge: TextStyle(fontFamily: GuardianFonts.body, fontWeight: FontWeight.w400, fontSize: 16, height: 24 / 16),
    bodyMedium: TextStyle(fontFamily: GuardianFonts.body, fontWeight: FontWeight.w400, fontSize: 14, height: 21 / 14),
    bodySmall: TextStyle(fontFamily: GuardianFonts.body, fontWeight: FontWeight.w400, fontSize: 12, height: 17 / 12),
    labelLarge: TextStyle(fontFamily: GuardianFonts.body, fontWeight: FontWeight.w600, fontSize: 15, height: 20 / 15),
    labelMedium: TextStyle(fontFamily: GuardianFonts.body, fontWeight: FontWeight.w500, fontSize: 12, height: 17 / 12),
    labelSmall: TextStyle(
      fontFamily: GuardianFonts.body,
      fontWeight: FontWeight.w700,
      fontSize: 11,
      height: 14 / 11,
      letterSpacing: 0.4,
    ),
  );
}
