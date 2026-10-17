import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sparks/app/theme/app_colors.dart';

/// SPARKS merkezi tipografi sistemi.
/// Editoryal Serif (Playfair Display) ve Modern Sans-Serif (Inter) hiyerarşisini yönetir.
/// İnternet bağlantısı olmasa dahi sistem fontlarına (Georgia / Helvetica) güvenle düşer.
/// Kaynak: docs/design-system.md
class AppTextStyles {
  const AppTextStyles._();

  // Sistem fontu geri dönüşleri (Fallback)
  static const List<String> _serifFallback = [
    'Georgia',
    'Times New Roman',
    'serif',
  ];
  static const List<String> _sansFallback = [
    'Helvetica Neue',
    'Arial',
    'sans-serif',
  ];

  // ===========================================================================
  // 1. ZARİF EDİTORYAL SERİF STİLLERİ (Playfair Display)
  // ===========================================================================

  /// Açılış ve ana sayfa için devasa SPARKS marka logosu
  static TextStyle brandLogoLarge = GoogleFonts.playfairDisplay(
    fontSize: 42,
    fontWeight: FontWeight.w400,
    letterSpacing: 6.0,
    color: AppColors.primaryText,
    textStyle: const TextStyle(fontFamilyFallback: _serifFallback),
  );

  /// Üst bar veya orta boy marka logosu
  static TextStyle brandLogoMedium = GoogleFonts.playfairDisplay(
    fontSize: 26,
    fontWeight: FontWeight.w400,
    letterSpacing: 4.0,
    color: AppColors.primaryText,
    textStyle: const TextStyle(fontFamilyFallback: _serifFallback),
  );

  /// Büyük bölüm başlıkları (KADIN, ERKEK, FAVORİLER vb.)
  static TextStyle sectionHeading = GoogleFonts.playfairDisplay(
    fontSize: 24,
    fontWeight: FontWeight.w400,
    letterSpacing: 2.0,
    color: AppColors.primaryText,
    textStyle: const TextStyle(fontFamilyFallback: _serifFallback),
  );

  /// Tarih ve editoryal vurgu metinleri (Örn: "28 EYL", "EDITION 01")
  static TextStyle editorialAccent = GoogleFonts.playfairDisplay(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.5,
    color: AppColors.primaryText,
    textStyle: const TextStyle(fontFamilyFallback: _serifFallback),
  );

  // ===========================================================================
  // 2. MODERN SANS-SERİF STİLLERİ (Inter)
  // ===========================================================================

  /// Menü ana grup başlıkları (Örn: "| 01 | YENİ ÜRÜNLER")
  static TextStyle menuGroup = GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    letterSpacing: 1.5,
    color: AppColors.secondaryText,
    textStyle: const TextStyle(fontFamilyFallback: _sansFallback),
  );

  /// Menü alt kategori isimleri (Örn: "THE NEW", "CEKET", "PANTOLON")
  static TextStyle menuItem = GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    letterSpacing: 1.2,
    color: AppColors.primaryText,
    textStyle: const TextStyle(fontFamilyFallback: _sansFallback),
  );

  /// Ürün listesi ve detayındaki ürün başlıkları
  static TextStyle productTitle = GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.8,
    color: AppColors.primaryText,
    textStyle: const TextStyle(fontFamilyFallback: _sansFallback),
  );

  /// Güncel ürün fiyatı
  static TextStyle productPrice = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
    color: AppColors.primaryText,
    textStyle: const TextStyle(fontFamilyFallback: _sansFallback),
  );

  /// İndirim öncesi eski ürün fiyatı (Üstü çizili)
  static TextStyle productOldPrice = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    decoration: TextDecoration.lineThrough,
    color: AppColors.secondaryText,
    textStyle: const TextStyle(fontFamilyFallback: _sansFallback),
  );

  /// İndirim oranı etiketi (Örn: "-%15")
  static TextStyle discountTag = GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    color: AppColors.primaryText,
    textStyle: const TextStyle(fontFamilyFallback: _sansFallback),
  );

  /// Keskin beyaz buton üzerindeki siyah metin
  static TextStyle buttonText = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 2.0,
    color: AppColors.shoppingBackground,
    textStyle: const TextStyle(fontFamilyFallback: _sansFallback),
  );

  /// Çerçeveli (Outlined) buton üzerindeki beyaz metin
  static TextStyle buttonTextOutlined = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 2.0,
    color: AppColors.primaryText,
    textStyle: const TextStyle(fontFamilyFallback: _sansFallback),
  );

  /// Arama alanı yer tutucusu ("NE ARIYORSUNUZ?")
  static TextStyle searchPlaceholder = GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    letterSpacing: 1.5,
    color: AppColors.secondaryText,
    textStyle: const TextStyle(fontFamilyFallback: _sansFallback),
  );

  /// Ürün detay açıklamaları ve genel gövde metni
  static TextStyle body = GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w300,
    height: 1.5,
    color: AppColors.primaryText,
    textStyle: const TextStyle(fontFamilyFallback: _sansFallback),
  );

  /// Küçük bilgilendirme ve alt notlar
  static TextStyle caption = GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    color: AppColors.secondaryText,
    textStyle: const TextStyle(fontFamilyFallback: _sansFallback),
  );
}
