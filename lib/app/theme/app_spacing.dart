/// SPARKS tasarım sistemi tutarlı boşluk, aralık ve ölçü sabitleri.
/// Keskin köşe ilkesi (0 radius) ve 1px ince çizgi standartlarını yönetir.
/// Kaynak: docs/design-system.md
class AppSpacing {
  const AppSpacing._();

  // 1. Temel Aralık ve Boşluk Adımları
  static const double xxs = 2.0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double xxxl = 64.0;

  // 2. Ekran Kenar ve Bölüm Boşlukları
  static const double screenHorizontal = 24.0;
  static const double screenVertical = 32.0;
  static const double sectionGap = 40.0;
  static const double itemGap = 16.0;

  // 3. Keskin Köşe İlkeleri (Zero Radius - Editoryal Kimlik)
  static const double buttonRadius = 0.0;
  static const double cardRadius = 0.0;
  static const double dialogRadius = 0.0;

  // 4. İnce Çizgi ve Ayırıcı Standartları
  static const double borderWidth = 1.0;
  static const double dividerThickness = 1.0;

  // 5. Ortak Bileşen Yükseklikleri
  static const double buttonHeight = 52.0;
  static const double bottomBarHeight = 64.0;
  static const double appBarHeight = 56.0;
  static const double activeIndicatorSize = 4.0;
}
