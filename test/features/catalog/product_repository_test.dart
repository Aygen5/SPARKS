import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sparks/features/catalog/data/datasources/product_local_data_source.dart';
import 'package:sparks/features/catalog/data/models/product_model.dart';
import 'package:sparks/features/catalog/data/repositories/product_repository_impl.dart';
import 'package:sparks/features/catalog/domain/entities/product.dart';

/// Testlerde AssetBundle davranışını taklit eden sahte bundle sınıfı.
class FakeAssetBundle extends Fake implements AssetBundle {
  FakeAssetBundle(this._jsonContent);

  final String _jsonContent;

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    return _jsonContent;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ProductRepository & Data Source Birim Testleri', () {
    late ProductRepositoryImpl repository;
    late ProductLocalDataSource localDataSource;

    final sampleCatalogJson = json.encode([
      {
        'id': 'sparks-w-001',
        'title': 'DİK YAKA ÖRGÜ HIRKA',
        'price': 2890.0,
        'oldPrice': 3490.0,
        'discountText': '-%17',
        'gender': 'KADIN',
        'category': 'KAZAK | HIRKA',
        'images': [
          'https://example.com/w1_1.jpg',
          'https://example.com/w1_2.jpg',
        ],
        'description': 'Yüksek dik yakalı kalın örgü hırka.',
        'colorAndCode': 'SİYAH | 2753/032',
        'materials': '%85 Yün, %15 Poliamit',
        'isOutOfStock': false,
        'sizes': ['XS', 'S', 'M', 'L'],
      },
      {
        'id': 'sparks-w-004',
        'title': 'VATKALI OVERSİZE CEKET',
        'price': 4290.0,
        'oldPrice': null,
        'discountText': null,
        'gender': 'KADIN',
        'category': 'CEKET',
        'images': [
          'https://example.com/w4_1.jpg',
          'https://example.com/w4_2.jpg',
        ],
        'description': 'Belirgin vatkalı omuz yapısı maskülen ceket.',
        'colorAndCode': 'KUM BEJİ | 4190/012',
        'materials': '%65 Keten, %35 Pamuk',
        'isOutOfStock': false,
        'sizes': ['S', 'M'],
      },
      {
        'id': 'sparks-m-002',
        'title': 'TERZİ İŞİ DÜZ KESİM CEKET',
        'price': 4590.0,
        'oldPrice': null,
        'discountText': null,
        'gender': 'ERKEK',
        'category': 'CEKET',
        'images': [
          'https://example.com/m2_1.jpg',
          'https://example.com/m2_2.jpg',
        ],
        'description': 'Klasik çentik yaka iki düğmeli takım ceketi.',
        'colorAndCode': 'SİYAH | 2890/011',
        'materials': '%100 Saf Yün',
        'isOutOfStock': true,
        'sizes': ['48', '50'],
      },
    ]);

    setUp(() {
      final fakeBundle = FakeAssetBundle(sampleCatalogJson);
      localDataSource = ProductLocalDataSourceImpl(bundle: fakeBundle);
      repository = ProductRepositoryImpl(localDataSource: localDataSource);
    });

    test('8. Repository ürün listesini asenkron Future<List<Product>> olarak döndürür', () async {
      final products = await repository.getProducts();

      expect(products, isA<List<Product>>());
      expect(products.length, 3);
      expect(products.first.id, 'sparks-w-001');
    });

    test('9. Cinsiyet filtresi (KADIN/ERKEK) doğru çalışır', () async {
      final womenProducts = await repository.getProducts(gender: 'KADIN');
      expect(womenProducts.length, 2);
      expect(womenProducts.every((p) => p.gender == 'KADIN'), isTrue);

      final menProducts = await repository.getProducts(gender: 'ERKEK');
      expect(menProducts.length, 1);
      expect(menProducts.first.id, 'sparks-m-002');
    });

    test('10. Kategori filtresi doğru çalışır', () async {
      final jackets = await repository.getProducts(category: 'CEKET');
      expect(jackets.length, 2);
      expect(jackets.every((p) => p.category == 'CEKET'), isTrue);

      final womenJackets = await repository.getProducts(
        gender: 'KADIN',
        category: 'CEKET',
      );
      expect(womenJackets.length, 1);
      expect(womenJackets.first.id, 'sparks-w-004');
    });

    test(
      '11. getProductById() eşleşen ürünü veya bulunamazsa null döndürür',
      () async {
        final found = await repository.getProductById('sparks-w-004');
        expect(found, isNotNull);
        expect(found!.title, 'VATKALI OVERSİZE CEKET');

        final notFound = await repository.getProductById('olmayan-id');
        expect(notFound, isNull);
      },
    );

    test('12. searchProducts() başlık, kategori, açıklama ve renk/kodda arama yapar', () async {
      // Başlıkta arama
      final byTitle = await repository.searchProducts('hırka');
      expect(byTitle.length, 1);
      expect(byTitle.first.id, 'sparks-w-001');

      // Renk ve kodda arama
      final byColorCode = await repository.searchProducts('2753/032');
      expect(byColorCode.length, 1);
      expect(byColorCode.first.id, 'sparks-w-001');

      // Cinsiyet kısıtlı arama
      final byGenderSearch = await repository.searchProducts(
        'ceket',
        gender: 'ERKEK',
      );
      expect(byGenderSearch.length, 1);
      expect(byGenderSearch.first.id, 'sparks-m-002');

      // Boş arama sorgusu boş liste döner
      final emptyResult = await repository.searchProducts('   ');
      expect(emptyResult, isEmpty);
    });
  });

  group('Katalog JSON Veri Dosyası Bütünlük ve Şema Doğrulama Testleri', () {
    test('13. assets/data/products.json dosyasındaki tüm ürün kimlikleri (id) benzersizdir', () {
      final file = File('assets/data/products.json');
      expect(
        file.existsSync(),
        isTrue,
        reason: 'assets/data/products.json dosyası mevcut olmalıdır.',
      );

      final content = file.readAsStringSync();
      final list = json.decode(content) as List<dynamic>;

      final ids = <String>{};
      for (final item in list) {
        final map = item as Map<String, dynamic>;
        final id = map['id'] as String;
        expect(
          ids.contains(id),
          isFalse,
          reason: 'Tekrarlayan ürün kimliği tespit edildi: $id',
        );
        ids.add(id);
      }

      expect(
        ids.length,
        greaterThanOrEqualTo(10),
        reason: 'Katalogda en az 10 ürün bulunmalıdır.',
      );
    });

    test('14. assets/data/products.json dosyasındaki her ürün eksiksiz ProductModel doğrulamalarından geçer', () {
      final file = File('assets/data/products.json');
      final content = file.readAsStringSync();
      final list = json.decode(content) as List<dynamic>;

      for (var i = 0; i < list.length; i++) {
        final map = list[i] as Map<String, dynamic>;
        final product = ProductModel.fromJson(map);

        expect(product.id, isNotEmpty);
        expect(product.title, isNotEmpty);
        expect(product.category, isNotEmpty);
        expect(product.gender, isIn(['KADIN', 'ERKEK']));
        expect(
          product.images.length,
          2,
          reason: '${product.id} ürününün tam olarak 2 görseli olmalıdır.',
        );
        expect(product.price, greaterThan(0));
        expect(product.description, isNotEmpty);
        expect(product.colorAndCode, isNotEmpty);
        expect(product.materials, isNotEmpty);
      }
    });
  });
}
