import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sparks/app/theme/app_theme.dart';
import 'package:sparks/features/catalog/domain/entities/product.dart';
import 'package:sparks/features/catalog/domain/repositories/product_repository.dart';
import 'package:sparks/features/favorites/data/datasources/favorites_local_data_source.dart';
import 'package:sparks/features/favorites/data/repositories/favorites_repository_impl.dart';
import 'package:sparks/features/favorites/presentation/manager/favorites_manager.dart';
import 'package:sparks/features/product_detail/presentation/product_detail_screen.dart';

/// Test amaçlı sahte ProductRepository
class FakeDetailProductRepository implements ProductRepository {
  FakeDetailProductRepository({this.productToReturn, this.shouldThrow = false});

  Product? productToReturn;
  bool shouldThrow;
  int getProductByIdCallCount = 0;

  @override
  Future<List<Product>> getProducts({String? gender, String? category}) async {
    return productToReturn != null ? [productToReturn!] : [];
  }

  @override
  Future<Product?> getProductById(String id) async {
    getProductByIdCallCount++;
    if (shouldThrow) throw Exception('Ürün detayı getirme hatası');
    if (productToReturn?.id == id) {
      return productToReturn;
    }
    return null;
  }

  @override
  Future<List<Product>> searchProducts(String query, {String? gender}) async {
    return [];
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  final testProductInStockDiscounted = Product(
    id: 'sparks-w-002',
    title: 'BÜZGÜLÜ DETAYLI KEMERLİ TRİKO',
    category: 'TOP | BODY',
    gender: 'KADIN',
    images: const [
      'https://example.com/img1.jpg',
      'https://example.com/img2.jpg',
    ],
    price: 3290.0,
    oldPrice: 3890.0,
    discountText: '-%15',
    isOutOfStock: false,
    description: 'Kayık yaka, balon formlu geniş kollu triko.',
    colorAndCode: 'SİYAH | 3412/104',
    materials: '%70 Viskon, %30 İpek',
    sizes: const ['S', 'M', 'L'],
  );

  final testProductOutOfStockRegular = Product(
    id: 'sparks-w-999',
    title: 'DİK YAKA ÖRGÜ HIRKA',
    category: 'KAZAK | HIRKA',
    gender: 'KADIN',
    images: const [
      'https://example.com/imgA.jpg',
      'https://example.com/imgB.jpg',
    ],
    price: 2890.0,
    oldPrice: null,
    discountText: null,
    isOutOfStock: true,
    description: 'Kalın örgü fermuarlı hırka.',
    colorAndCode: 'GRİ | 1111/222',
    materials: '%85 Yün, %15 Poliamit',
    sizes: const ['XS', 'S'],
  );

  Widget buildTestableWidget({
    required String productId,
    required ProductRepository repository,
    FavoritesManager? favoritesManager,
  }) {
    return MaterialApp(
      theme: AppTheme.darkTheme,
      home: ProductDetailScreen(
        productId: productId,
        repository: repository,
        favoritesManager: favoritesManager,
      ),
    );
  }

  group(
    'Aşama 7 — Ürün Detay Sayfası (ProductDetailScreen) Widget Testleri',
    () {
      late FakeDetailProductRepository fakeRepository;
      late InMemoryFavoritesLocalDataSource fakeFavDataSource;
      late FavoritesRepositoryImpl fakeFavRepo;
      late FavoritesManager testFavManager;

      setUp(() {
        fakeRepository = FakeDetailProductRepository(
          productToReturn: testProductInStockDiscounted,
        );
        fakeFavDataSource = InMemoryFavoritesLocalDataSource();
        fakeFavRepo = FavoritesRepositoryImpl(
          localDataSource: fakeFavDataSource,
        );
        testFavManager = FavoritesManager(repository: fakeFavRepo);
      });

      testWidgets(
        '1. Ürün bilgileri yüklenirken editoryal spinner gösterilir',
        (WidgetTester tester) async {
          await tester.pumpWidget(
            buildTestableWidget(
              productId: 'sparks-w-002',
              repository: fakeRepository,
              favoritesManager: testFavManager,
            ),
          );

          // İlk pump esnasında Future tamamlanmamışken spinner aranır
          expect(
            find.byKey(const ValueKey('product_detail_loading')),
            findsOneWidget,
          );

          await tester.pumpAndSettle();
          expect(
            find.byKey(const ValueKey('product_detail_loading')),
            findsNothing,
          );
        },
      );

      testWidgets(
        '2. İndirimli üründe başlık, reyon, güncel fiyat, eski fiyat ve indirim rozeti gösterilir',
        (WidgetTester tester) async {
          tester.view.physicalSize = const Size(400, 900);
          tester.view.devicePixelRatio = 1.0;
          addTearDown(() {
            tester.view.resetPhysicalSize();
            tester.view.resetDevicePixelRatio();
          });

          await tester.pumpWidget(
            buildTestableWidget(
              productId: 'sparks-w-002',
              repository: fakeRepository,
              favoritesManager: testFavManager,
            ),
          );
          await tester.pumpAndSettle();

          expect(find.text('BÜZGÜLÜ DETAYLI KEMERLİ TRİKO'), findsOneWidget);
          expect(find.text('KADIN · TOP | BODY'), findsOneWidget);
          expect(
            find.byKey(const ValueKey('product_detail_price')),
            findsOneWidget,
          );
          expect(
            find.byKey(const ValueKey('product_detail_old_price')),
            findsOneWidget,
          );
          expect(
            find.byKey(const ValueKey('product_detail_discount_badge')),
            findsOneWidget,
          );
          expect(find.text('-%15'), findsOneWidget);
        },
      );

      testWidgets(
        '3. İndirimsiz üründe eski fiyat ve indirim etiketi gösterilmez',
        (WidgetTester tester) async {
          tester.view.physicalSize = const Size(400, 900);
          tester.view.devicePixelRatio = 1.0;
          addTearDown(() {
            tester.view.resetPhysicalSize();
            tester.view.resetDevicePixelRatio();
          });

          fakeRepository.productToReturn = testProductOutOfStockRegular;

          await tester.pumpWidget(
            buildTestableWidget(
              productId: 'sparks-w-999',
              repository: fakeRepository,
              favoritesManager: testFavManager,
            ),
          );
          await tester.pumpAndSettle();

          expect(find.text('DİK YAKA ÖRGÜ HIRKA'), findsOneWidget);
          expect(
            find.byKey(const ValueKey('product_detail_price')),
            findsOneWidget,
          );
          expect(
            find.byKey(const ValueKey('product_detail_old_price')),
            findsNothing,
          );
          expect(
            find.byKey(const ValueKey('product_detail_discount_badge')),
            findsNothing,
          );
        },
      );

      testWidgets(
        '4. İki editoryal görsel ve 1/2 sayfa indikatörü başarıyla gösterilir',
        (WidgetTester tester) async {
          tester.view.physicalSize = const Size(400, 900);
          tester.view.devicePixelRatio = 1.0;
          addTearDown(() {
            tester.view.resetPhysicalSize();
            tester.view.resetDevicePixelRatio();
          });

          await tester.pumpWidget(
            buildTestableWidget(
              productId: 'sparks-w-002',
              repository: fakeRepository,
              favoritesManager: testFavManager,
            ),
          );
          await tester.pumpAndSettle();

          expect(
            find.byKey(const ValueKey('product_image_indicator')),
            findsOneWidget,
          );
          expect(find.text('1/2'), findsOneWidget);

          // İkinci görsele kaydır
          await tester.drag(find.byType(PageView), const Offset(-300, 0));
          await tester.pumpAndSettle();

          expect(find.text('2/2'), findsOneWidget);
        },
      );

      testWidgets(
        '5. AÇIKLAMA ve MALZEMELER sekmeleri arasında geçiş çalışır',
        (WidgetTester tester) async {
          tester.view.physicalSize = const Size(400, 900);
          tester.view.devicePixelRatio = 1.0;
          addTearDown(() {
            tester.view.resetPhysicalSize();
            tester.view.resetDevicePixelRatio();
          });

          await tester.pumpWidget(
            buildTestableWidget(
              productId: 'sparks-w-002',
              repository: fakeRepository,
              favoritesManager: testFavManager,
            ),
          );
          await tester.pumpAndSettle();

          // Sekmeler alanına kaydır
          await tester.ensureVisible(
            find.byKey(const ValueKey('tab_description')),
          );
          await tester.pumpAndSettle();

          // Varsayılan olarak AÇIKLAMA sekmesi aktiftir
          expect(
            find.byKey(const ValueKey('tab_content_description')),
            findsOneWidget,
          );
          expect(
            find.text('Kayık yaka, balon formlu geniş kollu triko.'),
            findsOneWidget,
          );
          expect(
            find.byKey(const ValueKey('tab_content_materials')),
            findsNothing,
          );

          // MALZEMELER sekmesine tıkla
          await tester.ensureVisible(
            find.byKey(const ValueKey('tab_materials')),
          );
          await tester.tap(find.byKey(const ValueKey('tab_materials')));
          await tester.pumpAndSettle();

          expect(
            find.byKey(const ValueKey('tab_content_materials')),
            findsOneWidget,
          );
          expect(find.text('%70 Viskon, %30 İpek'), findsOneWidget);
          expect(
            find.byKey(const ValueKey('tab_content_description')),
            findsNothing,
          );

          // Tekrar AÇIKLAMA sekmesine dön
          await tester.tap(find.byKey(const ValueKey('tab_description')));
          await tester.pumpAndSettle();

          expect(
            find.byKey(const ValueKey('tab_content_description')),
            findsOneWidget,
          );
        },
      );

      testWidgets(
        '6. Renk ve ürün kodu panoya kopyalanır ve SnackBar gösterilir',
        (WidgetTester tester) async {
          String? mockClipboardText;
          tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
            SystemChannels.platform,
            (MethodCall methodCall) async {
              if (methodCall.method == 'Clipboard.setData') {
                mockClipboardText =
                    (methodCall.arguments as Map)['text'] as String?;
                return null;
              } else if (methodCall.method == 'Clipboard.getData') {
                return {'text': mockClipboardText};
              }
              return null;
            },
          );
          addTearDown(() {
            tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
              SystemChannels.platform,
              null,
            );
          });

          tester.view.physicalSize = const Size(400, 900);
          tester.view.devicePixelRatio = 1.0;
          addTearDown(() {
            tester.view.resetPhysicalSize();
            tester.view.resetDevicePixelRatio();
          });

          await tester.pumpWidget(
            buildTestableWidget(
              productId: 'sparks-w-002',
              repository: fakeRepository,
              favoritesManager: testFavManager,
            ),
          );
          await tester.pumpAndSettle();

          // Kopyalama butonunu alt barın üzerinden yukarı kaydır ve dokun
          await tester.drag(
            find.byType(SingleChildScrollView),
            const Offset(0, -400),
          );
          await tester.pumpAndSettle();

          await tester.tap(find.byKey(const ValueKey('copy_code_button')));
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 300));

          expect(find.text('Renk ve ürün kodu kopyalandı'), findsOneWidget);
          expect(mockClipboardText, 'SİYAH | 3412/104');
        },
      );

      testWidgets(
        '7. Kalp ikonuna dokunulduğunda favori durumu merkezi yöneticide güncellenir ve ikon değişir',
        (WidgetTester tester) async {
          await tester.pumpWidget(
            buildTestableWidget(
              productId: 'sparks-w-002',
              repository: fakeRepository,
              favoritesManager: testFavManager,
            ),
          );
          await tester.pumpAndSettle();

          // Başlangıçta boş kalp
          expect(testFavManager.isFavorite('sparks-w-002'), isFalse);
          expect(find.byIcon(Icons.favorite_border), findsOneWidget);
          expect(find.byIcon(Icons.favorite), findsNothing);

          // Kalbe dokun -> Favoriye ekle
          await tester.tap(
            find.byKey(const ValueKey('product_favorite_button')),
          );
          await tester.pumpAndSettle();

          expect(testFavManager.isFavorite('sparks-w-002'), isTrue);
          expect(find.byIcon(Icons.favorite), findsOneWidget);
          expect(find.byIcon(Icons.favorite_border), findsNothing);

          // Kalbe tekrar dokun -> Favoriden çıkar
          await tester.tap(
            find.byKey(const ValueKey('product_favorite_button')),
          );
          await tester.pumpAndSettle();

          expect(testFavManager.isFavorite('sparks-w-002'), isFalse);
          expect(find.byIcon(Icons.favorite_border), findsOneWidget);
        },
      );

      testWidgets(
        '8. Stokta olan üründe SEPETE EKLE butonu görünür ve Aşama 8 SnackBar bildirimi verir',
        (WidgetTester tester) async {
          await tester.pumpWidget(
            buildTestableWidget(
              productId: 'sparks-w-002',
              repository: fakeRepository,
              favoritesManager: testFavManager,
            ),
          );
          await tester.pumpAndSettle();

          expect(find.text('SEPETE EKLE'), findsOneWidget);

          await tester.tap(find.byKey(const ValueKey('product_action_button')));
          await tester.pump();

          expect(
            find.text("Sepet özelliği Aşama 8'de eklenecektir."),
            findsOneWidget,
          );
        },
      );

      testWidgets(
        '9. Tükenen üründe buton TÜKENDİ olarak görünür ve basılamaz',
        (WidgetTester tester) async {
          fakeRepository.productToReturn = testProductOutOfStockRegular;

          await tester.pumpWidget(
            buildTestableWidget(
              productId: 'sparks-w-999',
              repository: fakeRepository,
              favoritesManager: testFavManager,
            ),
          );
          await tester.pumpAndSettle();

          expect(find.text('TÜKENDİ'), findsOneWidget);
          expect(find.text('SEPETE EKLE'), findsNothing);
        },
      );

      testWidgets(
        '10. Ürün bulunamadığında veya hata oluştuğunda ÜRÜN BULUNAMADI ve TEKRAR DENE butonu görünür',
        (WidgetTester tester) async {
          fakeRepository.productToReturn = null;

          await tester.pumpWidget(
            buildTestableWidget(
              productId: 'non-existing-id',
              repository: fakeRepository,
              favoritesManager: testFavManager,
            ),
          );
          await tester.pumpAndSettle();

          expect(find.text('ÜRÜN BULUNAMADI'), findsOneWidget);
          expect(
            find.byKey(const ValueKey('product_detail_retry_button')),
            findsOneWidget,
          );

          // TEKRAR DENE butonuna tıklandığında repository yeniden çağrılır
          final initialCallCount = fakeRepository.getProductByIdCallCount;
          await tester.tap(
            find.byKey(const ValueKey('product_detail_retry_button')),
          );
          await tester.pumpAndSettle();

          expect(fakeRepository.getProductByIdCallCount, initialCallCount + 1);
        },
      );

      testWidgets(
        '11. Dar ekran boyutlarında (360x640) taşma olmadan render edilir',
        (WidgetTester tester) async {
          tester.view.physicalSize = const Size(360, 640);
          tester.view.devicePixelRatio = 1.0;
          addTearDown(() {
            tester.view.resetPhysicalSize();
            tester.view.resetDevicePixelRatio();
          });

          await tester.pumpWidget(
            buildTestableWidget(
              productId: 'sparks-w-002',
              repository: fakeRepository,
              favoritesManager: testFavManager,
            ),
          );
          await tester.pumpAndSettle();

          expect(find.byType(ProductDetailScreen), findsOneWidget);
          expect(find.text('BÜZGÜLÜ DETAYLI KEMERLİ TRİKO'), findsOneWidget);
        },
      );
    },
  );
}
