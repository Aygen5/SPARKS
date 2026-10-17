import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:sparks/features/catalog/data/models/product_model.dart';

/// SPARKS Yerel Ürün Veri Kaynağı Sözleşmesi (Data Source Contract).
/// JSON dosyasını okuma ve ham veri sağlama sorumluluğunu üstlenir.
abstract class ProductLocalDataSource {
  /// Katalogdaki tüm ürün modellerini asenkron olarak yükler ve çözümler.
  Future<List<ProductModel>> getProducts();
}

/// JSON varlık dosyasından ürün modellerini yükleyen somut veri kaynağı.
/// Testlerde AssetBundle enjeksiyonunu veya özel dosya yolunu destekler.
class ProductLocalDataSourceImpl implements ProductLocalDataSource {
  const ProductLocalDataSourceImpl({
    this.assetPath = 'assets/data/products.json',
    this.bundle,
  });

  /// Yüklenecek JSON dosyasının varlık yolu
  final String assetPath;

  /// İsteğe bağlı AssetBundle (Testlerde sahte/özel bundle geçmek için kullanılır)
  final AssetBundle? bundle;

  @override
  Future<List<ProductModel>> getProducts() async {
    final actualBundle = bundle ?? rootBundle;
    final jsonString = await actualBundle.loadString(assetPath);
    final dynamic decoded = json.decode(jsonString);

    if (decoded is! List) {
      throw const FormatException(
        'Katalog JSON kök verisi bir liste ([...]) olmalıdır.',
      );
    }

    final products = <ProductModel>[];
    for (var i = 0; i < decoded.length; i++) {
      final item = decoded[i];
      if (item is! Map<String, dynamic>) {
        throw FormatException(
          'Katalogdaki ${i + 1}. ürün geçerli bir JSON nesnesi değildir.',
        );
      }
      products.add(ProductModel.fromJson(item));
    }

    return products;
  }
}
