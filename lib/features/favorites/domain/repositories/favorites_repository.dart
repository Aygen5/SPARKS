/// SPARKS Favoriler Repository Sözleşmesi (Domain Repository Interface).
/// Favori durumunu ürün kimlikleri (ID) üzerinden soyutlar.
/// Kaynak: docs/architecture.md
abstract class FavoritesRepository {
  /// Tüm favori ürün kimliklerini küme (Set) olarak döndürür.
  Future<Set<String>> getFavoriteIds();

  /// Belirtilen ürünün favorilerde olup olmadığını kontrol eder.
  Future<bool> isFavorite(String productId);

  /// Ürünü favorilere ekler (Duplikasyonu engeller).
  Future<void> addFavorite(String productId);

  /// Ürünü favorilerden çıkarır.
  Future<void> removeFavorite(String productId);

  /// Ürünün favori durumunu tersine çevirir ve güncel durumu döndürür.
  Future<bool> toggleFavorite(String productId);

  /// Tüm favorileri sıfırlar.
  Future<void> clear();
}
