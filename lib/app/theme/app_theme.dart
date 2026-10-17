import 'package:flutter/material.dart';
import 'package:sparks/app/theme/app_colors.dart';
import 'package:sparks/app/theme/app_spacing.dart';
import 'package:sparks/app/theme/app_text_styles.dart';

/// SPARKS Material 3 Temel Tema Yapılandırması.
/// Alışveriş arayüzünün simsiyah zeminini, editoryal tipografisini ve keskin köşeli hatlarını yönetir.
/// Kaynak: docs/design-system.md
class AppTheme {
  const AppTheme._();

  /// Alışveriş arayüzü temel koyu teması (Pure Black Editorial Contrast)
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.shoppingBackground,
      canvasColor: AppColors.shoppingBackground,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryText,
        onPrimary: AppColors.shoppingBackground,
        surface: AppColors.shoppingBackground,
        onSurface: AppColors.primaryText,
        error: AppColors.error,
        onError: AppColors.primaryText,
      ),

      // Minimalist Üst Bar Teması (Gölgesiz, siyah zemin)
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.shoppingBackground,
        foregroundColor: AppColors.primaryText,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
      ),

      // 1 Piksel İnce Ayırıcı Çizgi Teması
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: AppSpacing.dividerThickness,
        space: AppSpacing.dividerThickness,
      ),

      // Keskin Köşeli Kart Teması
      cardTheme: const CardThemeData(
        color: AppColors.shoppingBackground,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(
            color: AppColors.divider,
            width: AppSpacing.borderWidth,
          ),
        ),
      ),

      // Keskin Köşeli Beyaz Zeminli Ana Aksiyon Butonu
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryText,
          foregroundColor: AppColors.shoppingBackground,
          elevation: 0,
          shadowColor: Colors.transparent,
          minimumSize: const Size(double.infinity, AppSpacing.buttonHeight),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          textStyle: AppTextStyles.buttonText,
        ),
      ),

      // İnce Çerçeveli Keskin Buton
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryText,
          elevation: 0,
          minimumSize: const Size(double.infinity, AppSpacing.buttonHeight),
          side: const BorderSide(
            color: AppColors.primaryText,
            width: AppSpacing.borderWidth,
          ),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          textStyle: AppTextStyles.buttonTextOutlined,
        ),
      ),

      // Şeffaf Metin Butonu
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryText,
          textStyle: AppTextStyles.caption.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: 1.0,
          ),
        ),
      ),

      // Minimalist Alt Çizgili Arama ve Form Giriş Teması
      inputDecorationTheme: const InputDecorationTheme(
        filled: false,
        border: UnderlineInputBorder(
          borderSide: BorderSide(
            color: AppColors.dividerLight,
            width: AppSpacing.borderWidth,
          ),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: AppColors.dividerLight,
            width: AppSpacing.borderWidth,
          ),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: AppColors.primaryText,
            width: AppSpacing.borderWidth,
          ),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: AppSpacing.md),
      ),

      // Metin Teması Hiyerarşisi
      textTheme: TextTheme(
        displayLarge: AppTextStyles.brandLogoLarge,
        headlineMedium: AppTextStyles.sectionHeading,
        titleMedium: AppTextStyles.productTitle,
        bodyLarge: AppTextStyles.body,
        bodyMedium: AppTextStyles.caption,
        labelLarge: AppTextStyles.buttonText,
      ),
    );
  }
}
