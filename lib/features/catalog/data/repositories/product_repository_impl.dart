import 'package:sparks/features/catalog/data/datasources/product_local_data_source.dart';
import 'package:sparks/features/catalog/domain/entities/product.dart';
import 'package:sparks/features/catalog/domain/repositories/product_repository.dart';

/// SPARKS ProductRepository somut uygulaması.
/// ProductLocalDataSource üzerinden ürünleri çeker; filtreleme, tekil arama ve sorgulama
/// iş kurallarını uygulayarak domain katmanına Product varlıkları sunar.
class ProductRepositoryImpl implements ProductRepository {
  const ProductRepositoryImpl({required this.localDataSource});

  /// Veri çekme sorumluluğunu üstlenen yerel veri kaynağı
  final ProductLocalDataSource localDataSource;

  @override
  Future<List<Product>> getProducts({String? gender, String? category}) async {
    final models = await localDataSource.getProducts();

    return models.where((product) {
      // Cinsiyet filtresi (Büyük/küçük harf duyarsız kontrol)
      if (gender != null && gender.trim().isNotEmpty) {
        if (product.gender.toUpperCase() != gender.trim().toUpperCase()) {
          return false;
        }
      }

      // Kategori filtresi (Büyük/küçük harf duyarsız kontrol)
      if (category != null && category.trim().isNotEmpty) {
        if (product.category.toUpperCase() != category.trim().toUpperCase()) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  @override
  Future<Product?> getProductById(String id) async {
    final models = await localDataSource.getProducts();
    for (final product in models) {
      if (product.id == id) {
        return product;
      }
    }
    return null;
  }

  @override
  Future<List<Product>> searchProducts(String query, {String? gender}) async {
    final cleanQuery = query.trim().toLowerCase();
    if (cleanQuery.isEmpty) return const [];

    final models = await localDataSource.getProducts();

    return models.where((product) {
      // Cinsiyet kısıtı varsa uygula
      if (gender != null && gender.trim().isNotEmpty) {
        if (product.gender.toUpperCase() != gender.trim().toUpperCase()) {
          return false;
        }
      }

      // Başlık, kategori, açıklama veya renk/kod üzerinde arama
      final inTitle = product.title.toLowerCase().contains(cleanQuery);
      final inCategory = product.category.toLowerCase().contains(cleanQuery);
      final inDesc = product.description.toLowerCase().contains(cleanQuery);
      final inColorCode = product.colorAndCode.toLowerCase().contains(
        cleanQuery,
      );

      return inTitle || inCategory || inDesc || inColorCode;
    }).toList();
  }
}
