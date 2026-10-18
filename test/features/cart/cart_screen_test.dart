import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sparks/app/theme/app_theme.dart';
import 'package:sparks/core/utils/currency_formatter.dart';
import 'package:sparks/features/cart/data/datasources/cart_local_data_source.dart';
import 'package:sparks/features/cart/data/repositories/cart_repository_impl.dart';
import 'package:sparks/features/cart/presentation/cart_screen.dart';
import 'package:sparks/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:sparks/features/cart/presentation/cubit/cart_state.dart';
import 'package:sparks/features/catalog/domain/entities/product.dart';
import 'package:sparks/features/catalog/domain/repositories/product_repository.dart';
import 'package:sparks/features/catalog/presentation/catalog_screen.dart';
import 'package:sparks/features/favorites/data/datasources/favorites_local_data_source.dart';
import 'package:sparks/features/favorites/data/repositories/favorites_repository_impl.dart';
import 'package:sparks/features/favorites/presentation/manager/favorites_manager.dart';
import 'package:sparks/features/navigation/presentation/sparks_bottom_nav_bar.dart';
import 'package:sparks/features/product_detail/presentation/product_detail_screen.dart';
import 'package:sparks/features/search/presentation/search_screen.dart';

/// Test amaçlı sahte ProductRepository
class FakeCartTestProductRepository implements ProductRepository {
  FakeCartTestProductRepository(this.products);

  final List<Product> products;

  @override
  Future<List<Product>> getProducts({String? gender, String? category}) async {
    return products;
  }

  @override
  Future<Product?> getProductById(String id) async {
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

  final testProductOutOfStock = Product(
    id: 'sparks-w-999',
    title: 'TÜKENMİŞ İPEK GÖMLEK',
    category: 'GÖMLEK',
    gender: 'KADIN',
    images: const [
      'https://example.com/shirt1.jpg',
      'https://example.com/shirt2.jpg',
    ],
    price: 4500.0,
    oldPrice: null,
    discountText: null,
    isOutOfStock: true,
    description: 'Tükenmiş ürün.',
    colorAndCode: 'BEYAZ | 1000/001',
    materials: '%100 İpek',
    sizes: const ['S'],
  );

  Widget createCartWidget({
    required CartCubit cubit,
    VoidCallback? onNavigateToCatalog,
    void Function(String)? onProductTap,
    VoidCallback? onCheckoutNavigate,
  }) {
    return MaterialApp(
      theme: AppTheme.darkTheme,
      home: BlocProvider<CartCubit>.value(
        value: cubit,
        child: CartScreen(
          cartCubit: cubit,
          onCatalogNavigate: onNavigateToCatalog,
          onProductTap: onProductTap,
          onCheckoutNavigate: onCheckoutNavigate,
        ),
      ),
    );
  }

  group('Aşama 8 — Sepet Yönetimi ve Senkronizasyon Widget Testleri', () {
    late FakeCartTestProductRepository fakeRepo;
    late InMemoryCartLocalDataSource fakeCartDataSource;
    late CartRepositoryImpl fakeCartRepo;
    late CartCubit cartCubit;
    late InMemoryFavoritesLocalDataSource fakeFavDataSource;
    late FavoritesRepositoryImpl fakeFavRepo;
    late FavoritesManager favoritesManager;

    setUp(() {
      fakeRepo = FakeCartTestProductRepository([
        testProduct1,
        testProduct2,
        testProductOutOfStock,
      ]);
      fakeCartDataSource = InMemoryCartLocalDataSource();
      fakeCartRepo = CartRepositoryImpl(localDataSource: fakeCartDataSource);
      cartCubit = CartCubit(
        productRepository: fakeRepo,
        cartRepository: fakeCartRepo,
      );

      fakeFavDataSource = InMemoryFavoritesLocalDataSource();
      fakeFavRepo = FavoritesRepositoryImpl(localDataSource: fakeFavDataSource);
      favoritesManager = FavoritesManager(repository: fakeFavRepo);
    });

    tearDown(() {
      cartCubit.close();
    });

    testWidgets(
      '1. Sepet boşken editoryal boş durum mesajı ve KATALOĞA DÖN butonu gösterilir',
      (tester) async {
        bool navigatedToCatalog = false;

        await tester.pumpWidget(
          createCartWidget(
            cubit: cartCubit,
            onNavigateToCatalog: () => navigatedToCatalog = true,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('SEPETİNİZ BOŞ'), findsOneWidget);
        expect(
          find.textContaining('Henüz sepetinize bir ürün eklemediniz'),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('cart_empty_catalog_button')),
          findsOneWidget,
        );

        await tester.tap(
          find.byKey(const ValueKey('cart_empty_catalog_button')),
        );
        await tester.pumpAndSettle();

        expect(navigatedToCatalog, isTrue);
      },
    );

    testWidgets(
      '2. Sepete ürün eklendiğinde ürün kartı, başlığı, adedi ve fiyatı listelenir',
      (tester) async {
        await cartCubit.addProduct(testProduct1);

        await tester.pumpWidget(createCartWidget(cubit: cartCubit));
        await tester.pumpAndSettle();

        expect(
          find.byKey(ValueKey('cart_item_card_${testProduct1.id}')),
          findsOneWidget,
        );
        expect(find.text('OVERSIZE YÜN KABAN'), findsOneWidget);
        expect(find.text('ANTRASİT | 4021/801'), findsOneWidget);
        expect(
          find.byKey(ValueKey('cart_qty_value_${testProduct1.id}')),
          findsOneWidget,
        );
        expect(find.text('1'), findsOneWidget);
        expect(find.text(CurrencyFormatter.format(8490.0)), findsWidgets);
      },
    );

    testWidgets(
      '3. Adet artırma (+) butonu adedi artırır, toplam tutarı ve state i günceller',
      (tester) async {
        await cartCubit.addProduct(testProduct1);

        await tester.pumpWidget(createCartWidget(cubit: cartCubit));
        await tester.pumpAndSettle();

        expect(cartCubit.state.getQuantity(testProduct1.id), 1);
        expect(find.text('1'), findsOneWidget);

        await tester.tap(
          find.byKey(ValueKey('cart_qty_increase_${testProduct1.id}')),
        );
        await tester.pumpAndSettle();

        expect(cartCubit.state.getQuantity(testProduct1.id), 2);
        expect(find.text('2'), findsOneWidget);
        expect(cartCubit.state.totalItemCount, 2);

        // 8490 * 2 = 16980 TL
        expect(find.text(CurrencyFormatter.format(16980.0)), findsWidgets);
      },
    );

    testWidgets(
      '4. Adet azaltma (-) butonu adedi azaltır fakat 1 in altına düşürmez (ürünü silmez)',
      (tester) async {
        await cartCubit.addProduct(testProduct1);
        await cartCubit.incrementQuantity(testProduct1.id); // Qty = 2

        await tester.pumpWidget(createCartWidget(cubit: cartCubit));
        await tester.pumpAndSettle();

        expect(cartCubit.state.getQuantity(testProduct1.id), 2);

        // 2 -> 1
        await tester.tap(
          find.byKey(ValueKey('cart_qty_decrease_${testProduct1.id}')),
        );
        await tester.pumpAndSettle();

        expect(cartCubit.state.getQuantity(testProduct1.id), 1);
        expect(find.text('1'), findsOneWidget);

        // 1 iken tekrar eksi butonuna basıldığında ürün silinmez, adet 1 de kalır
        await tester.tap(
          find.byKey(ValueKey('cart_qty_decrease_${testProduct1.id}')),
        );
        await tester.pumpAndSettle();

        expect(cartCubit.state.getQuantity(testProduct1.id), 1);
        expect(find.text('1'), findsOneWidget);
        expect(
          find.byKey(ValueKey('cart_item_card_${testProduct1.id}')),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      '5. Çöp kutusu (silme) butonu ürünü sepetten tamamen kaldırır',
      (tester) async {
        await cartCubit.addProduct(testProduct1);
        await cartCubit.addProduct(testProduct2);

        await tester.pumpWidget(createCartWidget(cubit: cartCubit));
        await tester.pumpAndSettle();

        expect(
          find.byKey(ValueKey('cart_item_card_${testProduct1.id}')),
          findsOneWidget,
        );
        expect(
          find.byKey(ValueKey('cart_item_card_${testProduct2.id}')),
          findsOneWidget,
        );
        expect(cartCubit.state.lineItemCount, 2);

        // testProduct1 i sil
        await tester.tap(
          find.byKey(ValueKey('cart_item_delete_${testProduct1.id}')),
        );
        await tester.pumpAndSettle();

        expect(
          find.byKey(ValueKey('cart_item_card_${testProduct1.id}')),
          findsNothing,
        );
        expect(
          find.byKey(ValueKey('cart_item_card_${testProduct2.id}')),
          findsOneWidget,
        );
        expect(cartCubit.state.lineItemCount, 1);
      },
    );

    testWidgets(
      '6. SEPETİ TEMİZLE butonu onay dialogunu açar ve onaylanınca tüm sepeti boşaltır',
      (tester) async {
        await cartCubit.addProduct(testProduct1);
        await cartCubit.addProduct(testProduct2);

        await tester.pumpWidget(createCartWidget(cubit: cartCubit));
        await tester.pumpAndSettle();

        expect(find.byKey(const ValueKey('cart_clear_button')), findsOneWidget);

        await tester.tap(find.byKey(const ValueKey('cart_clear_button')));
        await tester.pumpAndSettle();

        // Onay dialogu açıldı
        expect(
          find.byKey(const ValueKey('cart_clear_confirm_dialog')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('cart_clear_confirm_button')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('cart_clear_cancel_button')),
          findsOneWidget,
        );

        // Onayla
        await tester.tap(
          find.byKey(const ValueKey('cart_clear_confirm_button')),
        );
        await tester.pumpAndSettle();

        expect(cartCubit.state.isEmpty, isTrue);
        expect(find.text('SEPETİNİZ BOŞ'), findsOneWidget);
        expect(find.byKey(const ValueKey('cart_clear_button')), findsNothing);
      },
    );

    testWidgets(
      '6b. SEPETİ TEMİZLE onay dialogunda VAZGEÇ tıklandığında sepet boşaltılmaz',
      (tester) async {
        await cartCubit.addProduct(testProduct1);

        await tester.pumpWidget(createCartWidget(cubit: cartCubit));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const ValueKey('cart_clear_button')));
        await tester.pumpAndSettle();

        expect(
          find.byKey(const ValueKey('cart_clear_confirm_dialog')),
          findsOneWidget,
        );

        // Vazgeç
        await tester.tap(
          find.byKey(const ValueKey('cart_clear_cancel_button')),
        );
        await tester.pumpAndSettle();

        expect(cartCubit.state.isEmpty, isFalse);
        expect(
          find.byKey(const ValueKey('cart_clear_confirm_dialog')),
          findsNothing,
        );
        expect(
          find.byKey(ValueKey('cart_item_card_${testProduct1.id}')),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      '7. Tükenmiş (isOutOfStock == true) ürün sepete eklenemez ve hata durumu oluşturur',
      (tester) async {
        final success = await cartCubit.addProduct(testProductOutOfStock);

        expect(success, isFalse);
        expect(cartCubit.state.errorMessage, 'Tükenen ürün sepete eklenemez.');
        expect(cartCubit.state.isEmpty, isTrue);
      },
    );

    testWidgets(
      '8. Alt navigasyon çubuğu dinamik sepet rozetini [ n ] olarak günceller',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.darkTheme,
            home: Scaffold(
              bottomNavigationBar: BlocBuilder<CartCubit, CartState>(
                bloc: cartCubit,
                builder: (context, state) {
                  return SparksBottomNavBar(
                    currentIndex: 0,
                    onTap: (_) {},
                    cartItemCount: state.totalItemCount,
                  );
                },
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Başlangıçta [ 0 ] rozeti
        expect(find.text('[ 0 ]'), findsOneWidget);

        // 1 ürün ekle
        await cartCubit.addProduct(testProduct1);
        await tester.pumpAndSettle();
        expect(find.text('[ 1 ]'), findsOneWidget);

        // Adedi artır
        await cartCubit.incrementQuantity(testProduct1.id);
        await tester.pumpAndSettle();
        expect(find.text('[ 2 ]'), findsOneWidget);

        // İkinci ürünü ekle
        await cartCubit.addProduct(testProduct2);
        await tester.pumpAndSettle();
        expect(find.text('[ 3 ]'), findsOneWidget);

        // Sepeti temizle
        await cartCubit.clearCart();
        await tester.pumpAndSettle();
        expect(find.text('[ 0 ]'), findsOneWidget);
      },
    );

    testWidgets(
      '9. ProductDetailScreen de SEPETE EKLE butonu CartCubit i tetikler ve SnackBar gösterir',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.darkTheme,
            home: ProductDetailScreen(
              productId: testProduct1.id,
              repository: fakeRepo,
              cartCubit: cartCubit,
              favoritesManager: favoritesManager,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(cartCubit.state.isEmpty, isTrue);

        final addToCartFinder = find.widgetWithText(
          ElevatedButton,
          'SEPETE EKLE',
        );
        expect(addToCartFinder, findsOneWidget);

        await tester.tap(addToCartFinder);
        await tester.pumpAndSettle();

        expect(cartCubit.state.totalItemCount, 1);
        expect(cartCubit.state.getQuantity(testProduct1.id), 1);
        expect(find.text('Ürün sepete eklendi'), findsOneWidget);
      },
    );

    testWidgets(
      '10. Favori ikonları Katalog, Arama ve Detay sayfaları arasında senkronize çalışır',
      (tester) async {
        // 1. Katalog ekranında favoriye ekle
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.darkTheme,
            home: CatalogScreen(
              repository: fakeRepo,
              favoritesManager: favoritesManager,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(favoritesManager.isFavorite(testProduct1.id), isFalse);

        final catalogFavBtn = find.byKey(
          ValueKey('catalog_favorite_${testProduct1.id}'),
        );
        expect(catalogFavBtn, findsOneWidget);

        await tester.tap(catalogFavBtn);
        await tester.pumpAndSettle();

        expect(favoritesManager.isFavorite(testProduct1.id), isTrue);

        // 2. Arama ekranında senkronizasyonu doğrula
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.darkTheme,
            home: SearchScreen(
              repository: fakeRepo,
              favoritesManager: favoritesManager,
            ),
          ),
        );
        await tester.pumpAndSettle();

        final searchFavBtn = find.byKey(
          ValueKey('search_favorite_${testProduct1.id}'),
        );
        expect(searchFavBtn, findsOneWidget);

        // Kalp doludur (Icons.favorite)
        expect(
          find.descendant(
            of: searchFavBtn,
            matching: find.byIcon(Icons.favorite),
          ),
          findsOneWidget,
        );

        // Arama ekranından favoriden çıkar
        await tester.tap(searchFavBtn);
        await tester.pumpAndSettle();

        expect(favoritesManager.isFavorite(testProduct1.id), isFalse);
        expect(
          find.descendant(
            of: searchFavBtn,
            matching: find.byIcon(Icons.favorite_border),
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      '11. Dar ekran boyutlarında (360x640) CartScreen taşma olmadan render edilir',
      (tester) async {
        tester.view.physicalSize = const Size(360, 640);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await cartCubit.addProduct(testProduct1);
        await cartCubit.addProduct(testProduct2);

        await tester.pumpWidget(createCartWidget(cubit: cartCubit));
        await tester.pumpAndSettle();

        expect(
          find.byKey(ValueKey('cart_item_card_${testProduct1.id}')),
          findsOneWidget,
        );
        expect(
          find.byKey(ValueKey('cart_item_card_${testProduct2.id}')),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      '12. DEVAM ET (checkout) butonuna tıklandığında checkout yönlendirmesi tetiklenir',
      (tester) async {
        bool checkoutTriggered = false;
        await cartCubit.addProduct(testProduct1);

        await tester.pumpWidget(
          createCartWidget(
            cubit: cartCubit,
            onCheckoutNavigate: () => checkoutTriggered = true,
          ),
        );
        await tester.pumpAndSettle();

        expect(
          find.byKey(const ValueKey('cart_checkout_button')),
          findsOneWidget,
        );
        await tester.tap(find.byKey(const ValueKey('cart_checkout_button')));
        await tester.pumpAndSettle();

        expect(checkoutTriggered, isTrue);
      },
    );

    testWidgets(
      '13. Ürün kartındaki görsel veya başlığa tıklandığında ürün detayına yönlendirilir',
      (tester) async {
        String? tappedProductId;
        await cartCubit.addProduct(testProduct1);

        await tester.pumpWidget(
          createCartWidget(
            cubit: cartCubit,
            onProductTap: (id) => tappedProductId = id,
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(
          find.byKey(ValueKey('cart_item_image_${testProduct1.id}')),
        );
        await tester.pumpAndSettle();
        expect(tappedProductId, testProduct1.id);

        tappedProductId = null;
        await tester.tap(
          find.byKey(ValueKey('cart_item_title_${testProduct1.id}')),
        );
        await tester.pumpAndSettle();
        expect(tappedProductId, testProduct1.id);
      },
    );

    testWidgets(
      '14. Sepette tükenmiş ürün varsa STOKTA YOK uyarısı gösterilir ve adet artırılamaz',
      (tester) async {
        // Doğrudan initialCart enjekte edilerek tükenmiş ürün sepette simüle edilir
        cartCubit.setInitialCartForTesting({testProductOutOfStock.id: 1});

        await tester.pumpWidget(createCartWidget(cubit: cartCubit));
        await tester.pumpAndSettle();

        expect(
          find.byKey(
            ValueKey('cart_item_out_of_stock_${testProductOutOfStock.id}'),
          ),
          findsOneWidget,
        );
        expect(find.text('STOKTA YOK'), findsOneWidget);

        // Artır butonu tıklandığında adet artmaz
        await tester.tap(
          find.byKey(ValueKey('cart_qty_increase_${testProductOutOfStock.id}')),
        );
        await tester.pumpAndSettle();
        expect(cartCubit.state.getQuantity(testProductOutOfStock.id), 1);
      },
    );
  });
}
