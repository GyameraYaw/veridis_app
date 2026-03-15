import 'package:flutter/material.dart';

// ── COLORS ────────────────────────────────────────────────────────────────────

class AppColors {
  AppColors._();

  // Primary brand greens
  static const Color forestGreen = Color(0xFF1A5C38);
  static const Color freshGreen = Color(0xFF2E7D32);
  static const Color midGreen = Color(0xFF388E3C);
  static const Color lightGreen = Color(0xFF43A047);

  // Backgrounds
  static const Color mintGreen = Color(0xFFE8F5E9);
  static const Color paleGreen = Color(0xFFF1F8F4);
  static const Color white = Color(0xFFFFFFFF);
  static const Color scaffoldBg = Color(0xFFF5F7F5);

  // Text
  static const Color textDark = Color(0xFF1A1A2E);
  static const Color textBody = Color(0xFF212121);
  static const Color textSubtle = Color(0xFF757575);
  static const Color textDisabled = Color(0xFFBDBDBD);

  // Functional (all green-family)
  static const Color earningsGreen = Color(0xFF2E7D32);
  static const Color co2DeepGreen = Color(0xFF1B5E20);
  static const Color sessionGreen = Color(0xFF43A047);

  // Kept non-green only for "Pending" badge
  static const Color pendingAmber = Color(0xFFF59E0B);
  static const Color errorRed = Color(0xFFD32F2F);

  // Surfaces
  static const Color divider = Color(0xFFE0E0E0);
  static const Color cardShadow = Color(0x141A5C38); // 8% forestGreen
}

// ── SPACING ───────────────────────────────────────────────────────────────────

class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;

  static const double pagePadding = 16;
}

// ── RADIUS ────────────────────────────────────────────────────────────────────

class AppRadius {
  AppRadius._();

  static const double card = 16;
  static const double button = 14;
  static const double chip = 8;
  static const double hero = 24;
  static const double input = 12;
}

// ── TEXT STYLES ───────────────────────────────────────────────────────────────

class AppTextStyles {
  AppTextStyles._();

  static const TextStyle displayLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    color: AppColors.textDark,
    letterSpacing: -0.5,
  );
  static const TextStyle displayMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.textDark,
  );
  static const TextStyle headlineMedium = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.textDark,
  );
  static const TextStyle titleLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
  );
  static const TextStyle titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textDark,
  );
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textBody,
  );
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSubtle,
  );
  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.textSubtle,
  );

  // Hero variants — white text on dark green backgrounds
  static const TextStyle heroDisplayLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    color: Colors.white,
    letterSpacing: -0.5,
  );
  static const TextStyle heroDisplay = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );
  static const TextStyle heroTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
  static const TextStyle heroLabel = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: Color(0xCCFFFFFF),
  );
  static const TextStyle heroCaption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: Color(0x99FFFFFF),
  );
}

// ── DECORATIONS ───────────────────────────────────────────────────────────────

class AppDecorations {
  AppDecorations._();

  // Hero card: deep forest green gradient
  static const BoxDecoration heroCard = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [AppColors.forestGreen, Color(0xFF2E7D32)],
    ),
    borderRadius: BorderRadius.all(Radius.circular(AppRadius.card)),
  );

  // White content card with green-tinted shadow
  static BoxDecoration get contentCard => BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      );

  // Login hero section (full-width, rounded bottom only)
  static const BoxDecoration loginHero = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [AppColors.forestGreen, Color(0xFF2E7D32)],
    ),
    borderRadius: BorderRadius.only(
      bottomLeft: Radius.circular(AppRadius.hero),
      bottomRight: Radius.circular(AppRadius.hero),
    ),
  );

  // Info box (mint background with green border)
  static BoxDecoration get infoBox => BoxDecoration(
        color: AppColors.mintGreen,
        borderRadius: BorderRadius.circular(AppRadius.chip),
        border: Border.all(color: const Color(0x4D2E7D32)),
      );
}

// ── THEME ─────────────────────────────────────────────────────────────────────

class AppTheme {
  AppTheme._();

  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.forestGreen,
          primary: AppColors.forestGreen,
          secondary: AppColors.freshGreen,
          surface: AppColors.white,
        ),
        scaffoldBackgroundColor: AppColors.scaffoldBg,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.forestGreen,
          foregroundColor: AppColors.white,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: AppColors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
          iconTheme: IconThemeData(color: AppColors.white),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.forestGreen,
            foregroundColor: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.button),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
            elevation: 0,
            textStyle:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.forestGreen,
            side: const BorderSide(color: AppColors.forestGreen, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.button),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.input),
            borderSide: const BorderSide(color: AppColors.divider),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.input),
            borderSide: const BorderSide(color: AppColors.divider),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.input),
            borderSide:
                const BorderSide(color: AppColors.forestGreen, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.input),
            borderSide: const BorderSide(color: AppColors.errorRed),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.input),
            borderSide: const BorderSide(color: AppColors.errorRed, width: 2),
          ),
          labelStyle: const TextStyle(color: AppColors.textSubtle),
          hintStyle: const TextStyle(color: AppColors.textDisabled),
          prefixIconColor: AppColors.freshGreen,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          color: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.card),
          ),
          margin: EdgeInsets.zero,
        ),
        checkboxTheme: CheckboxThemeData(
          fillColor: WidgetStateProperty.resolveWith((states) =>
              states.contains(WidgetState.selected)
                  ? AppColors.forestGreen
                  : null),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.white,
          selectedItemColor: AppColors.forestGreen,
          unselectedItemColor: AppColors.textSubtle,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
        ),
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: AppColors.forestGreen,
          contentTextStyle: TextStyle(color: Colors.white),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.all(Radius.circular(AppRadius.chip)),
          ),
        ),
        dividerTheme: const DividerThemeData(
          color: AppColors.divider,
          thickness: 1,
          space: 1,
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.forestGreen,
          ),
        ),
      );
}
