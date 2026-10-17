/// SPARKS Sepet Repository Sözleşmesi (Domain Repository Interface).
/// Sepet durumunu ürün kimlikleri ve adetleri üzerinden soyutlar.
/// Kaynak: docs/architecture.md
abstract class CartRepository {
  /// Kayıtlı sepet öğelerini (productId -> quantity) döndürür.
  Future<Map<String, int>> getCartItems();

  /// Sepet öğelerini kalıcı olarak kaydeder.
  Future<void> saveCartItems(Map<String, int> items);

  /// Tüm sepeti temizler.
  Future<void> clear();
}
