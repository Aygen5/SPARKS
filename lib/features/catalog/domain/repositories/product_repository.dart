import 'package:sparks/features/catalog/domain/entities/product.dart';

/// SPARKS Ürün Repository Sözleşmesi (Domain Repository Interface).
/// UI katmanı veya Cubit'ler ürün verisini bu soyut sözleşme üzerinden talep eder;
/// verinin yerel JSON'dan mı yoksa gelecekte gerçek bir REST API'den mi geldiğini bilmez.
/// Kaynak: docs/architecture.md
abstract class ProductRepository {
  /// Filtrelere (cinsiyet ve kategori) göre ürün listesini asenkron olarak döndürür.
  /// Parametreler verilmezse katalogdaki tüm ürünleri döndürür.
  Future<List<Product>> getProducts({String? gender, String? category});

  /// Verilen benzersiz kimliğe (id) sahip tek bir ürünü döndürür; bulunamazsa null döner.
  Future<Product?> getProductById(String id);

  /// Başlık, kategori, açıklama veya renk/kod üzerinde metinsel arama yapar.
  /// İsteğe bağlı olarak cinsiyete (KADIN/ERKEK) göre daraltılabilir.
  Future<List<Product>> searchProducts(String query, {String? gender});
}
