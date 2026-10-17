import 'package:sparks/features/menu/domain/entities/menu_item.dart';

/// SPARKS Merkezi Menü Kategori Veri Deposu.
/// KADIN ve ERKEK reyonları için editoryal kategori ve bölüm tanımlarını içerir.
/// Kaynak: Aşama 5 Şartnamesi (Bölüm 5 & 6)
class MenuData {
  const MenuData._();

  /// KADIN reyonuna ait numaralandırılmış ana gruplar ve alt kategoriler
  static const List<MenuSection> womenSections = [
    MenuSection(
      number: '01',
      title: 'YENİ ÜRÜNLER',
      items: [MenuCategoryItem(id: 'the-new', title: 'THE NEW')],
    ),
    MenuSection(
      number: '02',
      title: 'KOLEKSİYON',
      items: [
        MenuCategoryItem(id: 'kaban-mont', title: 'KABAN | MONT'),
        MenuCategoryItem(id: 'ceket', title: 'CEKET'),
        MenuCategoryItem(id: 'pantolon', title: 'PANTOLON'),
        MenuCategoryItem(id: 'jean', title: 'JEAN'),
        MenuCategoryItem(id: 'top-body', title: 'TOP | BODY'),
        MenuCategoryItem(id: 'kazak-hirka', title: 'KAZAK | HIRKA'),
        MenuCategoryItem(id: 'etek', title: 'ETEK'),
      ],
    ),
    MenuSection(
      number: '03',
      title: 'AYAKKABI | AKSESUAR',
      items: [
        MenuCategoryItem(id: 'ayakkabi', title: 'AYAKKABI'),
        MenuCategoryItem(id: 'canta', title: 'ÇANTA'),
      ],
    ),
  ];

  /// ERKEK reyonuna ait numaralandırılmış ana gruplar ve alt kategoriler
  /// (Erkek menüsünde ETEK, TOP | BODY ve ÇANTA yer almaz)
  static const List<MenuSection> menSections = [
    MenuSection(
      number: '01',
      title: 'YENİ ÜRÜNLER',
      items: [MenuCategoryItem(id: 'the-new', title: 'THE NEW')],
    ),
    MenuSection(
      number: '02',
      title: 'KOLEKSİYON',
      items: [
        MenuCategoryItem(id: 'kaban-mont', title: 'KABAN | MONT'),
        MenuCategoryItem(id: 'ceket', title: 'CEKET'),
        MenuCategoryItem(id: 'pantolon', title: 'PANTOLON'),
        MenuCategoryItem(id: 'jean', title: 'JEAN'),
        MenuCategoryItem(id: 'kazak-hirka', title: 'KAZAK | HIRKA'),
      ],
    ),
    MenuSection(
      number: '03',
      title: 'AYAKKABI | AKSESUAR',
      items: [MenuCategoryItem(id: 'ayakkabi', title: 'AYAKKABI')],
    ),
  ];

  /// Seçili cinsiyete ("KADIN" / "ERKEK") göre ilgili bölümleri döndürür.
  static List<MenuSection> getSectionsForGender(String gender) {
    if (gender.trim().toUpperCase() == 'ERKEK') {
      return menSections;
    }
    return womenSections;
  }
}
