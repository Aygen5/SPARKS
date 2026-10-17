import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sparks/app/router/app_router.dart';
import 'package:sparks/app/theme/app_theme.dart';
import 'package:sparks/features/catalog/domain/entities/product.dart';
import 'package:sparks/features/catalog/domain/repositories/product_repository.dart';
import 'package:sparks/features/catalog/presentation/catalog_screen.dart';
import 'package:sparks/features/product_detail/presentation/product_detail_screen.dart';

class FakeProductRepository implements ProductRepository {
  FakeProductRepository({this.products = const [], this.shouldFail = false});

  final List<Product> products;
  final bool shouldFail;

  @override
  Future<List<Product>> getProducts({String? gender, String? category}) async {
    if (shouldFail) throw Exception('Katalog yükleme hatası');
    return products.where((p) {
      if (gender != null && gender.isNotEmpty) {
        if (p.gender.toUpperCase() != gender.toUpperCase()) return false;
      }
      if (category != null && category.isNotEmpty && category != 'TÜMÜNÜ GÖR') {
        if (p.category.toUpperCase() != category.toUpperCase()) return false;
      }
      return true;
    }).toList();
  }

  @override
  Future<Product?> getProductById(String id) async {
    if (shouldFail) throw Exception('Ürün detayı hatası');
    for (final p in products) {
      if (p.id == id) return p;
    }
    return null;
  }

  @override
  Future<List<Product>> searchProducts(String query, {String? gender}) async {
    if (shouldFail) throw Exception('Arama hatası');
    final q = query.toLowerCase();
    return products.where((p) {
      if (gender != null && gender.isNotEmpty) {
        if (p.gender.toUpperCase() != gender.toUpperCase()) return false;
      }
      return p.title.toLowerCase().contains(q) ||
          p.category.toLowerCase().contains(q) ||
          p.colorAndCode.toLowerCase().contains(q);
    }).toList();
  }
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  final testProducts = [
    Product(
      id: 'sparks-w-001',
      title: 'DİK YAKA ÖRGÜ HIRKA',
      price: 2890.0,
      oldPrice: 3490.0,
      discountText: '-%17',
      gender: 'KADIN',
      category: 'KAZAK | HIRKA',
      images: const [
        'https://example.com/w1_1.jpg',
        'https://example.com/w1_2.jpg',
      ],
      description: 'Yüksek dik yakalı kalın örgü hırka.',
      colorAndCode: 'SİYAH | 2753/032',
      materials: '%85 Yün, %15 Poliamit',
      isOutOfStock: false,
      sizes: const ['XS', 'S', 'M', 'L', 'XL'],
    ),
    Product(
      id: 'sparks-w-004',
      title: 'VATKALI OVERSİZE CEKET',
      price: 4290.0,
      oldPrice: null,
      discountText: null,
      gender: 'KADIN',
      category: 'CEKET',
      images: const [
        'https://example.com/w4_1.jpg',
        'https://example.com/w4_2.jpg',
      ],
      description: 'Vatkalı sivri yaka editoryal ceket.',
      colorAndCode: 'KUM BEJİ | 4190/012',
      materials: '%65 Keten, %35 Pamuk',
      isOutOfStock: false,
      sizes: const ['S', 'M', 'L'],
    ),
  ];

  Widget buildTestableWidget({
    String gender = 'KADIN',
    String category = '',
    ProductRepository? repository,
    void Function(Product)? onProductTap,
    int initialViewMode = 2,
  }) {
    return MaterialApp(
      theme: AppTheme.darkTheme,
      home: CatalogScreen(
        gender: gender,
        category: category,
        repository: repository ?? FakeProductRepository(products: testProducts),
        onProductTap: onProductTap,
        initialViewMode: initialViewMode,
      ),
    );
  }

  group('Aşama 6 — Katalog Ekranı ve Üçlü Görünüm Sistemi Testleri', () {
    testWidgets(
      '1. CatalogScreen ürünleri başarıyla yükler ve 2 sütunlu modda gösterir',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildTestableWidget());
        await tester.pumpAndSettle();

        expect(
          find.byKey(const ValueKey('catalog_list_mode_2')),
          findsOneWidget,
        );
        expect(find.text('DİK YAKA ÖRGÜ HIRKA'), findsOneWidget);
        expect(find.text('VATKALI OVERSİZE CEKET'), findsOneWidget);
        expect(find.text('GÖRÜNÜM 2'), findsOneWidget);
      },
    );

    testWidgets('2. GÖRÜNÜM butonu 2 -> 3 -> 1 -> 2 döngüsünü uygular', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestableWidget(initialViewMode: 2));
      await tester.pumpAndSettle();

      final viewModeButton = find.byKey(
        const ValueKey('catalog_view_mode_button'),
      );

      // Başlangıç: Görünüm 2
      expect(find.text('GÖRÜNÜM 2'), findsOneWidget);
      expect(find.byKey(const ValueKey('catalog_list_mode_2')), findsOneWidget);

      // Dokun -> Görünüm 3
      await tester.tap(viewModeButton);
      await tester.pumpAndSettle();
      expect(find.text('GÖRÜNÜM 3'), findsOneWidget);
      expect(find.byKey(const ValueKey('catalog_list_mode_3')), findsOneWidget);

      // Dokun -> Görünüm 1
      await tester.tap(viewModeButton);
      await tester.pumpAndSettle();
      expect(find.text('GÖRÜNÜM 1'), findsOneWidget);
      expect(find.byKey(const ValueKey('catalog_list_mode_1')), findsOneWidget);

      // Dokun -> Tekrar Görünüm 2
      await tester.tap(viewModeButton);
      await tester.pumpAndSettle();
      expect(find.text('GÖRÜNÜM 2'), findsOneWidget);
    });

    testWidgets(
      '3. Görünüm 3 modunda ürün başlıkları gizlenir ve sadece görseller gösterilir',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildTestableWidget(initialViewMode: 3));
        await tester.pumpAndSettle();

        expect(
          find.byKey(const ValueKey('catalog_list_mode_3')),
          findsOneWidget,
        );
        // Görünüm 3'te ürün başlıkları listede yer almaz
        expect(find.text('DİK YAKA ÖRGÜ HIRKA'), findsNothing);
        expect(find.text('VATKALI OVERSİZE CEKET'), findsNothing);
      },
    );

    testWidgets(
      '4. Kategori parametresi geldiğinde ürünler kategoriye göre filtrelenir',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildTestableWidget(category: 'CEKET'));
        await tester.pumpAndSettle();

        // Sadece CEKET ürünü görünmeli
        expect(find.text('VATKALI OVERSİZE CEKET'), findsOneWidget);
        expect(find.text('DİK YAKA ÖRGÜ HIRKA'), findsNothing);
      },
    );

    testWidgets(
      '5. Yatay kategori şeridinde TÜMÜNÜ GÖR seçildiğinde tüm ürünler geri gelir',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildTestableWidget(category: 'CEKET'));
        await tester.pumpAndSettle();

        expect(find.text('VATKALI OVERSİZE CEKET'), findsOneWidget);
        expect(find.text('DİK YAKA ÖRGÜ HIRKA'), findsNothing);

        // TÜMÜNÜ GÖR sekmesine dokun
        await tester.tap(
          find.byKey(const ValueKey('category_pill_TÜMÜNÜ GÖR')),
        );
        await tester.pumpAndSettle();

        expect(find.text('VATKALI OVERSİZE CEKET'), findsOneWidget);
        expect(find.text('DİK YAKA ÖRGÜ HIRKA'), findsOneWidget);
      },
    );

    testWidgets(
      '6. Beden filtresi XS seçildiğinde yalnızca XS bedene sahip ürünler listelenir',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildTestableWidget());
        await tester.pumpAndSettle();

        // Filtreler panelini aç
        await tester.tap(find.byKey(const ValueKey('catalog_filter_button')));
        await tester.pumpAndSettle();

        expect(find.text('BEDEN:'), findsOneWidget);

        // XS bedenini seç (Sadece hırka XS bedenine sahiptir)
        await tester.tap(find.byKey(const ValueKey('size_pill_XS')));
        await tester.pumpAndSettle();

        expect(find.text('DİK YAKA ÖRGÜ HIRKA'), findsOneWidget);
        expect(find.text('VATKALI OVERSİZE CEKET'), findsNothing);

        // XS bedenine tekrar dokunarak seçimi kaldır
        await tester.tap(find.byKey(const ValueKey('size_pill_XS')));
        await tester.pumpAndSettle();

        expect(find.text('DİK YAKA ÖRGÜ HIRKA'), findsOneWidget);
        expect(find.text('VATKALI OVERSİZE CEKET'), findsOneWidget);
      },
    );

    testWidgets(
      '7. Eşleşmeyen filtrede boş sonuç durumu ve FİLTRELERİ TEMİZLE butonu gösterilir',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildTestableWidget(category: 'SUNİ KÜRK'));
        await tester.pumpAndSettle();

        expect(find.text('BU KATEGORİDE ÜRÜN BULUNAMADI'), findsOneWidget);
        expect(
          find.byKey(const ValueKey('catalog_clear_filters_button')),
          findsOneWidget,
        );

        // Temizle butonuna bas
        await tester.tap(
          find.byKey(const ValueKey('catalog_clear_filters_button')),
        );
        await tester.pumpAndSettle();

        expect(find.text('DİK YAKA ÖRGÜ HIRKA'), findsOneWidget);
        expect(find.text('VATKALI OVERSİZE CEKET'), findsOneWidget);
      },
    );

    testWidgets(
      '8. Repository hatasında anlaşılır hata ve TEKRAR DENE butonu gösterilir',
      (WidgetTester tester) async {
        final failingRepo = FakeProductRepository(shouldFail: true);
        await tester.pumpWidget(buildTestableWidget(repository: failingRepo));
        await tester.pumpAndSettle();

        expect(
          find.text(
            'Katalog yüklenirken bir sorun oluştu. Lütfen tekrar deneyin.',
          ),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('catalog_retry_button')),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      '9. Ürün kartına tıklandığında onProductTap geri çağrımı ürün nesnesiyle tetiklenir',
      (WidgetTester tester) async {
        Product? tappedProduct;

        await tester.pumpWidget(
          buildTestableWidget(
            onProductTap: (product) {
              tappedProduct = product;
            },
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(
          find.byKey(const ValueKey('product_card_sparks-w-001')),
        );
        await tester.pumpAndSettle();

        expect(tappedProduct, isNotNull);
        expect(tappedProduct!.id, 'sparks-w-001');
        expect(tappedProduct!.title, 'DİK YAKA ÖRGÜ HIRKA');
      },
    );

    testWidgets(
      '10. Dar ekran boyutlarında (360x640) taşma olmadan render edilir',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(360, 640);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(buildTestableWidget());
        await tester.pumpAndSettle();

        expect(find.byType(CatalogScreen), findsOneWidget);
        expect(
          find.byKey(const ValueKey('catalog_list_mode_2')),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      '11. GoRouter /product/:id rotası ProductDetailScreen açar ve ürün detayını yükler',
      (WidgetTester tester) async {
        AppRouter.reset(initialLocation: '/product/sparks-w-001');

        await tester.pumpWidget(
          MaterialApp.router(
            theme: AppTheme.darkTheme,
            routerConfig: AppRouter.router,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(ProductDetailScreen), findsOneWidget);
        expect(find.text('DİK YAKA ÖRGÜ HIRKA'), findsOneWidget);
      },
    );
  });
}
