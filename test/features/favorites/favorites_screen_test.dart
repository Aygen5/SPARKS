import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sparks/app/theme/app_theme.dart';
import 'package:sparks/core/utils/currency_formatter.dart';
import 'package:sparks/features/catalog/domain/entities/product.dart';
import 'package:sparks/features/catalog/domain/repositories/product_repository.dart';
import 'package:sparks/features/favorites/data/datasources/favorites_local_data_source.dart';
import 'package:sparks/features/favorites/data/repositories/favorites_repository_impl.dart';
import 'package:sparks/features/favorites/presentation/favorites_screen.dart';
import 'package:sparks/features/favorites/presentation/manager/favorites_manager.dart';

/// Test amaçlı sahte ProductRepository
class FakeFavoritesProductRepository implements ProductRepository {
  FakeFavoritesProductRepository(this.products, {this.shouldThrow = false});

  final List<Product> products;
  bool shouldThrow;
  int getProductByIdCallCount = 0;

  @override
  Future<List<Product>> getProducts({String? gender, String? category}) async {
    if (shouldThrow) throw Exception('Ürün listesi hatası');
    return products;
  }

  @override
  Future<Product?> getProductById(String id) async {
    getProductByIdCallCount++;
    if (shouldThrow) throw Exception('Ürün detayı getirme hatası');
    try {
      return products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Product>> searchProducts(String query, {String? gender}) async {
    return products;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  final testProduct1 = Product(
    id: 'sparks-w-001',
    title: 'OVERSIZE YÜN KABAN',
    category: 'KABAN | MONT',
    gender: 'KADIN',
    images: const [
      'https://example.com/coat1.jpg',
      'https://example.com/coat2.jpg',
    ],
    price: 8490.0,
    oldPrice: 9990.0,
    discountText: '-%15',
    isOutOfStock: false,
    description: 'Düşük omuzlu, geniş kesim kruvaze yün kaban.',
    colorAndCode: 'ANTRASİT | 4021/801',
    materials: '%80 Yün, %20 Kaşmir',
    sizes: const ['S', 'M', 'L'],
  );

  final testProduct2 = Product(
    id: 'sparks-w-002',
    title: 'BÜZGÜLÜ DETAYLI TRİKO',
    category: 'TOP | BODY',
    gender: 'KADIN',
    images: const [
      'https://example.com/knit1.jpg',
      'https://example.com/knit2.jpg',
    ],
    price: 3290.0,
    oldPrice: null,
    discountText: null,
    isOutOfStock: false,
    description: 'Balon kollu şık triko.',
    colorAndCode: 'SİYAH | 3412/104',
    materials: '%70 Viskon, %30 İpek',
    sizes: const ['XS', 'S', 'M'],
  );

  Widget createFavoritesWidget({
    required FavoritesManager favoritesManager,
    required ProductRepository repository,
    void Function(Product product)? onProductTap,
    VoidCallback? onCatalogNavigate,
  }) {
    return MaterialApp(
      theme: AppTheme.darkTheme,
      home: FavoritesScreen(
        favoritesManager: favoritesManager,
        productRepository: repository,
        onProductTap: onProductTap,
        onCatalogNavigate: onCatalogNavigate,
      ),
    );
  }

  group('Aşama 9 — Gerçek Favoriler Ekranı (FavoritesScreen) Testleri', () {
    late FakeFavoritesProductRepository fakeRepo;
    late InMemoryFavoritesLocalDataSource fakeLocalDataSource;
    late FavoritesRepositoryImpl fakeFavRepo;
    late FavoritesManager favoritesManager;

    setUp(() {
      fakeRepo = FakeFavoritesProductRepository([testProduct1, testProduct2]);
      fakeLocalDataSource = InMemoryFavoritesLocalDataSource();
      fakeFavRepo = FavoritesRepositoryImpl(localDataSource: fakeLocalDataSource);
      favoritesManager = FavoritesManager(repository: fakeFavRepo);
    });

    testWidgets('1. Favori listesi boşken editoryal boş durum ve KATALOĞA DÖN butonu gösterilir', (tester) async {
      bool catalogNavigated = false;

      await tester.pumpWidget(
        createFavoritesWidget(
          favoritesManager: favoritesManager,
          repository: fakeRepo,
          onCatalogNavigate: () => catalogNavigated = true,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('FAVORİ LİSTENİZ BOŞ'), findsOneWidget);
      expect(
        find.textContaining('Henüz favorilerinize bir ürün eklemediniz'),
        findsOneWidget,
      );
      expect(find.byKey(const ValueKey('favorites_empty_catalog_button')), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('favorites_empty_catalog_button')));
      await tester.pumpAndSettle();

      expect(catalogNavigated, isTrue);
    });

    testWidgets('2. Kayıtlı favoriler doğru başlık, fiyat, renk kodu ve kalp ikonu ile listelenir', (tester) async {
      await favoritesManager.addFavorite(testProduct1.id);
      await favoritesManager.addFavorite(testProduct2.id);

      await tester.pumpWidget(
        createFavoritesWidget(
          favoritesManager: favoritesManager,
          repository: fakeRepo,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('favorites_grid')), findsOneWidget);
      expect(find.byKey(ValueKey('favorite_product_card_${testProduct1.id}')), findsOneWidget);
      expect(find.byKey(ValueKey('favorite_product_card_${testProduct2.id}')), findsOneWidget);

      expect(find.text('OVERSIZE YÜN KABAN'), findsOneWidget);
      expect(find.text('ANTRASİT | 4021/801'), findsOneWidget);
      expect(find.text(CurrencyFormatter.format(8490.0)), findsOneWidget);
      expect(find.text('-%15'), findsOneWidget);

      expect(find.text('BÜZGÜLÜ DETAYLI TRİKO'), findsOneWidget);
      expect(find.text('SİYAH | 3412/104'), findsOneWidget);
      expect(find.text(CurrencyFormatter.format(3290.0)), findsOneWidget);

      // Üst bar sayaç rozeti
      expect(find.text('2 ÜRÜN'), findsOneWidget);

      // Kalp ikonları mevcuttur
      expect(find.byKey(ValueKey('favorites_remove_${testProduct1.id}')), findsOneWidget);
      expect(find.byKey(ValueKey('favorites_remove_${testProduct2.id}')), findsOneWidget);
    });

    testWidgets('3. Kalp ikonuna dokunulduğunda ürün listeden anında çıkarılır ve sayaç güncellenir', (tester) async {
      await favoritesManager.addFavorite(testProduct1.id);
      await favoritesManager.addFavorite(testProduct2.id);

      await tester.pumpWidget(
        createFavoritesWidget(
          favoritesManager: favoritesManager,
          repository: fakeRepo,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(ValueKey('favorite_product_card_${testProduct1.id}')), findsOneWidget);
      expect(find.text('2 ÜRÜN'), findsOneWidget);

      // testProduct1 in kalp ikonuna dokun
      await tester.tap(find.byKey(ValueKey('favorites_remove_${testProduct1.id}')));
      await tester.pumpAndSettle();

      expect(favoritesManager.isFavorite(testProduct1.id), isFalse);
      expect(find.byKey(ValueKey('favorite_product_card_${testProduct1.id}')), findsNothing);
      expect(find.byKey(ValueKey('favorite_product_card_${testProduct2.id}')), findsOneWidget);
      expect(find.text('1 ÜRÜN'), findsOneWidget);

      // Son ürünü de çıkar
      await tester.tap(find.byKey(ValueKey('favorites_remove_${testProduct2.id}')));
      await tester.pumpAndSettle();

      expect(find.text('FAVORİ LİSTENİZ BOŞ'), findsOneWidget);
    });

    testWidgets('4. Harici bir ekrandan veya yöneticiden favori eklendiğinde ekrana anında yansır', (tester) async {
      await tester.pumpWidget(
        createFavoritesWidget(
          favoritesManager: favoritesManager,
          repository: fakeRepo,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('FAVORİ LİSTENİZ BOŞ'), findsOneWidget);

      // Dışarıdan favoriye ekle
      await favoritesManager.addFavorite(testProduct1.id);
      await tester.pumpAndSettle();

      expect(find.byKey(ValueKey('favorite_product_card_${testProduct1.id}')), findsOneWidget);
      expect(find.text('OVERSIZE YÜN KABAN'), findsOneWidget);
      expect(find.text('1 ÜRÜN'), findsOneWidget);
    });

    testWidgets('5. Favori ürün kartına dokunulduğunda onProductTap tetiklenir', (tester) async {
      Product? tappedProduct;
      await favoritesManager.addFavorite(testProduct1.id);

      await tester.pumpWidget(
        createFavoritesWidget(
          favoritesManager: favoritesManager,
          repository: fakeRepo,
          onProductTap: (product) => tappedProduct = product,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(ValueKey('favorite_product_card_${testProduct1.id}')));
      await tester.pumpAndSettle();

      expect(tappedProduct, isNotNull);
      expect(tappedProduct!.id, testProduct1.id);
    });

    testWidgets('6. Hata durumunda kontrollü mesaj ve TEKRAR DENE butonu çalışır', (tester) async {
      fakeRepo.shouldThrow = true;
      await favoritesManager.addFavorite(testProduct1.id);

      await tester.pumpWidget(
        createFavoritesWidget(
          favoritesManager: favoritesManager,
          repository: fakeRepo,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Favoriler yüklenirken bir sorun oluştu'), findsOneWidget);
      expect(find.byKey(const ValueKey('favorites_retry_button')), findsOneWidget);

      // Hatayı düzelt ve tekrar dene
      fakeRepo.shouldThrow = false;
      await tester.tap(find.byKey(const ValueKey('favorites_retry_button')));
      await tester.pumpAndSettle();

      expect(find.byKey(ValueKey('favorite_product_card_${testProduct1.id}')), findsOneWidget);
      expect(find.text('OVERSIZE YÜN KABAN'), findsOneWidget);
    });

    testWidgets('7. Dar ekran boyutlarında (360x640) FavoritesScreen taşma olmadan render edilir', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await favoritesManager.addFavorite(testProduct1.id);
      await favoritesManager.addFavorite(testProduct2.id);

      await tester.pumpWidget(
        createFavoritesWidget(
          favoritesManager: favoritesManager,
          repository: fakeRepo,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(ValueKey('favorite_product_card_${testProduct1.id}')), findsOneWidget);
      expect(find.byKey(ValueKey('favorite_product_card_${testProduct2.id}')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
