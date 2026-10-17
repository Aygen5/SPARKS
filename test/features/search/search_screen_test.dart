import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sparks/app/theme/app_theme.dart';
import 'package:sparks/features/catalog/domain/entities/product.dart';
import 'package:sparks/features/catalog/domain/repositories/product_repository.dart';
import 'package:sparks/features/search/presentation/search_screen.dart';

class FakeSearchProductRepository implements ProductRepository {
  FakeSearchProductRepository({this.products = const []});

  final List<Product> products;

  @override
  Future<List<Product>> getProducts({String? gender, String? category}) async {
    return products.where((p) {
      if (gender != null && gender.isNotEmpty) {
        if (p.gender.toUpperCase() != gender.toUpperCase()) return false;
      }
      return true;
    }).toList();
  }

  @override
  Future<Product?> getProductById(String id) async {
    for (final p in products) {
      if (p.id == id) return p;
    }
    return null;
  }

  @override
  Future<List<Product>> searchProducts(String query, {String? gender}) async {
    final clean = query.trim().toLowerCase();
    if (clean.isEmpty) return const [];
    return products.where((p) {
      if (gender != null && gender.isNotEmpty) {
        if (p.gender.toUpperCase() != gender.toUpperCase()) return false;
      }
      return p.title.toLowerCase().contains(clean) ||
          p.category.toLowerCase().contains(clean) ||
          p.colorAndCode.toLowerCase().contains(clean) ||
          p.description.toLowerCase().contains(clean);
    }).toList();
  }
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  final sampleProducts = [
    Product(
      id: 'sparks-w-001',
      title: 'DİK YAKA ÖRGÜ HIRKA',
      price: 2890.0,
      oldPrice: null,
      discountText: null,
      gender: 'KADIN',
      category: 'KAZAK | HIRKA',
      images: const [
        'https://example.com/w1_1.jpg',
        'https://example.com/w1_2.jpg',
      ],
      description: 'Kalın örgü kadın hırkası.',
      colorAndCode: 'SİYAH | 2753/032',
      materials: '%85 Yün',
      isOutOfStock: false,
      sizes: const ['S', 'M'],
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
      description: 'Vatkalı ceket.',
      colorAndCode: 'KUM BEJİ | 4190/012',
      materials: '%65 Keten',
      isOutOfStock: false,
      sizes: const ['M', 'L'],
    ),
    Product(
      id: 'sparks-m-001',
      title: 'YÜN BLEND MASKÜLEN KABAN',
      price: 6890.0,
      oldPrice: null,
      discountText: null,
      gender: 'ERKEK',
      category: 'KABAN | MONT',
      images: const [
        'https://example.com/m1_1.jpg',
        'https://example.com/m1_2.jpg',
      ],
      description: 'Yapısal yün erkek kabanı.',
      colorAndCode: 'ANTRASİT | 7321/040',
      materials: '%80 Yün',
      isOutOfStock: false,
      sizes: const ['M', 'L'],
    ),
  ];

  Widget buildSearchScreen({
    ProductRepository? repository,
    void Function(Product)? onProductTap,
    String initialGender = 'KADIN',
  }) {
    return MaterialApp(
      theme: AppTheme.darkTheme,
      home: SearchScreen(
        repository:
            repository ?? FakeSearchProductRepository(products: sampleProducts),
        onProductTap: onProductTap,
        initialGender: initialGender,
      ),
    );
  }

  group('Aşama 6 — Gerçek Zamanlı Arama Ekranı (SearchScreen) Testleri', () {
    testWidgets(
      '1. Varsayılan olarak KADIN sekmesi aktiftir ve önerilen ürünler listelenir',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildSearchScreen());
        await tester.pumpAndSettle();

        expect(find.text('KADIN'), findsOneWidget);
        expect(find.text('ERKEK'), findsOneWidget);
        expect(find.text('İLGİNİZİ ÇEKEBİLECEK DİĞER ÜRÜNLER'), findsOneWidget);

        // KADIN önerileri görünmeli
        expect(find.text('DİK YAKA ÖRGÜ HIRKA'), findsOneWidget);
        expect(find.text('VATKALI OVERSİZE CEKET'), findsOneWidget);
        // ERKEK ürünü KADIN önerisinde yer almamalı
        expect(find.text('YÜN BLEND MASKÜLEN KABAN'), findsNothing);
      },
    );

    testWidgets(
      '2. ERKEK sekmesine geçildiğinde önerilen ürünler erkek reyonuyla güncellenir',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildSearchScreen());
        await tester.pumpAndSettle();

        // ERKEK sekmesine dokun
        await tester.tap(find.byKey(const ValueKey('search_tab_ERKEK')));
        await tester.pumpAndSettle();

        // Erkek ürünü görünmeli
        expect(find.text('YÜN BLEND MASKÜLEN KABAN'), findsOneWidget);
        // Kadın ürünleri kaybolmalı
        expect(find.text('DİK YAKA ÖRGÜ HIRKA'), findsNothing);
        expect(find.text('VATKALI OVERSİZE CEKET'), findsNothing);
      },
    );

    testWidgets(
      '3. Arama kutusuna metin yazıldığında gerçek zamanlı arama sonuçları listelenir',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildSearchScreen());
        await tester.pumpAndSettle();

        final inputFinder = find.byKey(const ValueKey('search_input_field'));

        // "ceket" yaz
        await tester.enterText(inputFinder, 'ceket');
        await tester.pumpAndSettle();

        // Sonuçlarda CEKET olmalı, HIRKA olmamalı
        expect(find.text('VATKALI OVERSİZE CEKET'), findsOneWidget);
        expect(find.text('DİK YAKA ÖRGÜ HIRKA'), findsNothing);
        // Öneriler başlığı arama sırasında gizlenmeli
        expect(find.text('İLGİNİZİ ÇEKEBİLECEK DİĞER ÜRÜNLER'), findsNothing);
      },
    );

    testWidgets(
      '4. Renk/kod veya kategori üzerinden de arama başarıyla sonuç döndürür',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildSearchScreen());
        await tester.pumpAndSettle();

        final inputFinder = find.byKey(const ValueKey('search_input_field'));

        // Renk kodu ile ara: "2753/032"
        await tester.enterText(inputFinder, '2753/032');
        await tester.pumpAndSettle();

        expect(find.text('DİK YAKA ÖRGÜ HIRKA'), findsOneWidget);
        expect(find.text('VATKALI OVERSİZE CEKET'), findsNothing);
      },
    );

    testWidgets('5. Metin temizlendiğinde önerilen ürünlere geri dönülür', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildSearchScreen());
      await tester.pumpAndSettle();

      final inputFinder = find.byKey(const ValueKey('search_input_field'));

      await tester.enterText(inputFinder, 'ceket');
      await tester.pumpAndSettle();
      expect(find.text('VATKALI OVERSİZE CEKET'), findsOneWidget);

      // Temizleme ikonuna bas
      await tester.tap(find.byKey(const ValueKey('search_clear_button')));
      await tester.pumpAndSettle();

      // Tekrar öneriler görünmeli
      expect(find.text('İLGİNİZİ ÇEKEBİLECEK DİĞER ÜRÜNLER'), findsOneWidget);
      expect(find.text('DİK YAKA ÖRGÜ HIRKA'), findsOneWidget);
      expect(find.text('VATKALI OVERSİZE CEKET'), findsOneWidget);
    });

    testWidgets('6. Eşleşme olmadığında boş sonuç durumu mesajı gösterilir', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildSearchScreen());
      await tester.pumpAndSettle();

      final inputFinder = find.byKey(const ValueKey('search_input_field'));

      await tester.enterText(inputFinder, 'bulunamayan_parca_123');
      await tester.pumpAndSettle();

      expect(find.text('EŞLEŞEN ÜRÜN BULUNAMADI'), findsOneWidget);
      expect(
        find.text(
          'Farklı bir arama terimi deneyebilir veya kategorilere göz atabilirsiniz.',
        ),
        findsOneWidget,
      );
    });

    testWidgets(
      '7. Arama sonucundaki ürüne tıklandığında onProductTap geri çağrımı tetiklenir',
      (WidgetTester tester) async {
        Product? selectedProduct;

        await tester.pumpWidget(
          buildSearchScreen(
            onProductTap: (product) {
              selectedProduct = product;
            },
          ),
        );
        await tester.pumpAndSettle();

        final inputFinder = find.byKey(const ValueKey('search_input_field'));
        await tester.enterText(inputFinder, 'ceket');
        await tester.pumpAndSettle();

        await tester.tap(
          find.byKey(const ValueKey('search_product_card_sparks-w-004')),
        );
        await tester.pumpAndSettle();

        expect(selectedProduct, isNotNull);
        expect(selectedProduct!.id, 'sparks-w-004');
        expect(selectedProduct!.title, 'VATKALI OVERSİZE CEKET');
      },
    );

    testWidgets(
      '8. Dar ekran boyutlarında (360x640) SearchScreen taşma olmadan render edilir',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(360, 640);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(buildSearchScreen());
        await tester.pumpAndSettle();

        expect(find.byType(SearchScreen), findsOneWidget);
        expect(
          find.byKey(const ValueKey('search_input_field')),
          findsOneWidget,
        );
      },
    );
  });
}
