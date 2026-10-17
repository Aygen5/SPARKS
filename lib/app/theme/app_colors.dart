import 'package:flutter/material.dart';

/// SPARKS merkezi renk sistemi.
/// İki farklı görsel dünyayı (Editoryal Sıcak Tonlar & Alışveriş Siyah Kontrast Modu) yönetir.
/// Kaynak: docs/design-system.md
class AppColors {
  const AppColors._();

  // 1. Editoryal Görsel Alanları (Giriş & Lookbook)
  static const Color editorialCream = Color(0xFFFDFBF7);
  static const Color editorialBeige = Color(0xFFE8E1D5);
  static const Color editorialStone = Color(0xFFD9D2C7);
  static const Color editorialBrown = Color(0xFF5A3E2B);
  static const Color editorialAnthracite = Color(0xFF222222);

  // 2. Alışveriş Arayüzü (Menü, Arama, Katalog, Detay, Sepet, Hesap)
  static const Color shoppingBackground = Color(0xFF000000);
  static const Color black = shoppingBackground;
  static const Color primaryText = Color(0xFFFFFFFF);
  static const Color white = primaryText;
  static const Color secondaryText = Color(0xFF8E8E8E);
  static const Color productSurface = Color(0xFFFFFFFF);
  static const Color productSurfaceAlt = Color(0xFFF5F5F5);
  static const Color divider = Color(0xFF1F1F1F);
  static const Color dividerLight = Color(0xFF2A2A2A);

  // Aktif Sekme İndikatörü ve Yardımcı Renkler
  static const Color activeIndicator = Color(0xFFFFFFFF);
  static const Color error = Color(0xFFDC2626);
  static const Color success = Color(0xFF16A34A);
}
