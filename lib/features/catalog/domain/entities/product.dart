/// SPARKS Temel Ürün Varlığı (Domain Entity).
/// İş kurallarının kullandığı saf ürün nesnesidir; harici kütüphanelerden ve JSON bağımlılıklarından arındırılmıştır.
/// Kaynak: docs/architecture.md ve docs/api-and-data.md
class Product {
  const Product({
    required this.id,
    required this.title,
    required this.category,
    required this.gender,
    required this.images,
    required this.price,
    this.oldPrice,
    this.discountText,
    required this.isOutOfStock,
    required this.description,
    required this.colorAndCode,
    required this.materials,
    this.sizes = const [],
  }) : assert(
         images.length == 2,
         'images listesi tam olarak 2 görsel içermelidir',
       );

  /// Benzersiz ürün kimliği (Örn: "sparks-w-001")
  final String id;

  /// Ürün adı / başlığı (Örn: "DİK YAKA ÖRGÜ HIRKA")
  final String title;

  /// Kategori adı (Örn: "CEKET", "KABAN | MONT", "PANTOLON")
  final String category;

  /// Cinsiyet hedefi ("KADIN" veya "ERKEK")
  final String gender;

  /// Tam olarak iki görsel adresi içeren liste [anaGörsel, detayGörsel]
  final List<String> images;

  /// Güncel satış fiyatı (TL cinsinden sayısal değer)
  final double price;

  /// İndirim öncesi eski fiyat (Yalnızca indirimli ürünlerde dolu, aksi halde null)
  final double? oldPrice;

  /// İndirim oranı veya etiketi (Örn: "-%15", indirim yoksa null)
  final String? discountText;

  /// Stok tükenme durumu (true ise ürün satın alınamaz)
  final bool isOutOfStock;

  /// Ürünün detaylı kalıp, kesim ve stil açıklaması
  final String description;

  /// Renk adı ve referans ürün kodu (Örn: "SİYAH | 2753/032")
  final String colorAndCode;

  /// Kumaş ve astar malzeme içeriği (Örn: "%85 Yün, %15 Poliamit")
  final String materials;

  /// Mevcut beden seçenekleri (Örn: ["XS", "S", "M", "L", "XL"])
  final List<String> sizes;

  /// Ürünün indirimde olup olmadığını belirten yardımcı getter
  bool get isDiscounted => oldPrice != null && oldPrice! > price;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Product && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'Product(id: $id, title: $title, price: $price TL, gender: $gender)';
}
