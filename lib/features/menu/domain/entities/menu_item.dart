/// SPARKS Menü Alt Kategori Öğesi (Domain Entity).
/// Tek bir alt kategorinin kimliğini ve ekranda görünen başlığını temsil eder.
class MenuCategoryItem {
  const MenuCategoryItem({required this.id, required this.title});

  /// Kararlı kategori kimliği (Örn: "kaban-mont", "ceket")
  final String id;

  /// Ekranda görünen resmi editoryal başlık (Örn: "KABAN | MONT", "CEKET")
  final String title;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MenuCategoryItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'MenuCategoryItem(id: $id, title: $title)';
}

/// SPARKS Menü Ana Bölüm / Grubu (Domain Entity).
/// Sol sütunda numaralandırılmış başlığı ve sağ sütundaki alt kategori listesini temsil eder.
class MenuSection {
  const MenuSection({
    required this.number,
    required this.title,
    required this.items,
  });

  /// Numaralandırma hanesi (Örn: "01", "02", "03")
  final String number;

  /// Bölüm başlığı (Örn: "YENİ ÜRÜNLER", "KOLEKSİYON", "AYAKKABI | AKSESUAR")
  final String title;

  /// Sağ sütunda listelenecek alt kategoriler
  final List<MenuCategoryItem> items;

  /// Sol sütunda gösterilecek biçimlendirilmiş editoryal başlık
  /// Örn: "|01| YENİ ÜRÜNLER"
  String get headerDisplay => '|$number| $title';

  @override
  String toString() =>
      'MenuSection(header: $headerDisplay, itemsCount: ${items.length})';
}
