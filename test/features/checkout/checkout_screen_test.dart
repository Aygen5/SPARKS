import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sparks/app/theme/app_theme.dart';
import 'package:sparks/core/utils/currency_formatter.dart';
import 'package:sparks/features/cart/data/datasources/cart_local_data_source.dart';
import 'package:sparks/features/cart/data/repositories/cart_repository_impl.dart';
import 'package:sparks/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:sparks/features/catalog/domain/entities/product.dart';
import 'package:sparks/features/catalog/domain/repositories/product_repository.dart';
import 'package:sparks/features/checkout/presentation/checkout_screen.dart';

class FakeCheckoutProductRepository implements ProductRepository {
  FakeCheckoutProductRepository(this.products);

  final List<Product> products;

  @override
  Future<List<Product>> getProducts({String? gender, String? category}) async {
    return products;
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
    description: 'Düşük omuzlu yün kaban.',
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
    materials: '%70 Viskon',
    sizes: const ['S', 'M'],
  );

  Widget createCheckoutWidget({
    required CartCubit cubit,
    VoidCallback? onBack,
    VoidCallback? onReturnToCart,
    VoidCallback? onReturnToCatalog,
  }) {
    return MaterialApp(
      theme: AppTheme.darkTheme,
      home: BlocProvider<CartCubit>.value(
        value: cubit,
        child: CheckoutScreen(
          cartCubit: cubit,
          onBack: onBack,
          onReturnToCart: onReturnToCart,
          onReturnToCatalog: onReturnToCatalog,
        ),
      ),
    );
  }

  group('Aşama 10 — Checkout / Sipariş Özeti Ekranı Testleri', () {
    late FakeCheckoutProductRepository fakeRepo;
    late InMemoryCartLocalDataSource fakeCartDataSource;
    late CartRepositoryImpl fakeCartRepo;
    late CartCubit cartCubit;

    setUp(() {
      fakeRepo = FakeCheckoutProductRepository([testProduct1, testProduct2]);
      fakeCartDataSource = InMemoryCartLocalDataSource();
      fakeCartRepo = CartRepositoryImpl(localDataSource: fakeCartDataSource);
      cartCubit = CartCubit(
        productRepository: fakeRepo,
        cartRepository: fakeCartRepo,
      );
    });

    tearDown(() {
      cartCubit.close();
    });

    testWidgets(
      '1. Sepet boşken editoryal boş durum mesajı ve SEPETE DÖN butonu gösterilir',
      (tester) async {
        bool returnedToCart = false;

        await tester.pumpWidget(
          createCheckoutWidget(
            cubit: cartCubit,
            onReturnToCart: () => returnedToCart = true,
          ),
        );
        await tester.pumpAndSettle();

        expect(
          find.byKey(const ValueKey('checkout_empty_state')),
          findsOneWidget,
        );
        expect(find.text('SEPETİNİZDE ÜRÜN BULUNMUYOR'), findsOneWidget);
        expect(
          find.byKey(const ValueKey('checkout_return_cart_button')),
          findsOneWidget,
        );

        await tester.tap(
          find.byKey(const ValueKey('checkout_return_cart_button')),
        );
        await tester.pumpAndSettle();

        expect(returnedToCart, isTrue);
      },
    );

    testWidgets(
      '2. Sepette ürünler varken ürün kalemleri, adetler ve satır toplamları listelenir',
      (tester) async {
        await cartCubit.addProduct(testProduct1); // 1 x 8490
        await cartCubit.addProduct(testProduct2); // 1 x 3290
        await cartCubit.incrementQuantity(testProduct2.id); // 2 x 3290 = 6580

        await tester.pumpWidget(createCheckoutWidget(cubit: cartCubit));
        await tester.pumpAndSettle();

        expect(
          find.byKey(ValueKey('checkout_item_tile_${testProduct1.id}')),
          findsOneWidget,
        );
        expect(
          find.byKey(ValueKey('checkout_item_tile_${testProduct2.id}')),
          findsOneWidget,
        );

        // Ürün başlıkları
        expect(find.text('OVERSIZE YÜN KABAN'), findsOneWidget);
        expect(find.text('BÜZGÜLÜ DETAYLI TRİKO'), findsOneWidget);

        // 1 x 8.490,00 TL ve 2 x 3.290,00 TL dökümü
        expect(
          find.text('1 x ${CurrencyFormatter.format(8490.0)}'),
          findsOneWidget,
        );
        expect(
          find.text('2 x ${CurrencyFormatter.format(3290.0)}'),
          findsOneWidget,
        );

        // Satır toplamları
        expect(find.text(CurrencyFormatter.format(8490.0)), findsWidgets);
        expect(find.text(CurrencyFormatter.format(6580.0)), findsWidgets);
      },
    );

    testWidgets(
      '3. Ara toplam, teslimat bedeli ve genel toplam doğru hesaplanır ve görüntülenir',
      (tester) async {
        // 8490 + 3290 = 11780 TL
        await cartCubit.addProduct(testProduct1);
        await cartCubit.addProduct(testProduct2);

        await tester.pumpWidget(createCheckoutWidget(cubit: cartCubit));
        await tester.pumpAndSettle();

        final expectedTotal = CurrencyFormatter.format(11780.0);

        expect(
          find.byKey(const ValueKey('checkout_subtotal_price')),
          findsOneWidget,
        );
        final subtotalWidget = tester.widget<Text>(
          find.byKey(const ValueKey('checkout_subtotal_price')),
        );
        expect(subtotalWidget.data, expectedTotal);

        expect(
          find.byKey(const ValueKey('checkout_shipping_fee')),
          findsOneWidget,
        );
        expect(find.text('ÜCRETSİZ'), findsOneWidget);

        expect(
          find.byKey(const ValueKey('checkout_total_price')),
          findsOneWidget,
        );
        final totalWidget = tester.widget<Text>(
          find.byKey(const ValueKey('checkout_total_price')),
        );
        expect(totalWidget.data, expectedTotal);
      },
    );

    testWidgets(
      '4. Dürüstlük bilgilendirme kutusu ödeme altyapısının henüz aktif olmadığını netçe belirtir',
      (tester) async {
        await cartCubit.addProduct(testProduct1);

        await tester.pumpWidget(createCheckoutWidget(cubit: cartCubit));
        await tester.pumpAndSettle();

        expect(
          find.byKey(const ValueKey('checkout_notice_box')),
          findsOneWidget,
        );
        expect(find.text('ÖNEMLİ BİLGİLENDİRME'), findsOneWidget);
        expect(
          find.textContaining(
            'ödeme ve sipariş altyapısı henüz aktif değildir',
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      '5. SİPARİŞİ TAMAMLA butonuna basıldığında dürüst bilgilendirme mesajı gösterilir',
      (tester) async {
        await cartCubit.addProduct(testProduct1);

        await tester.pumpWidget(createCheckoutWidget(cubit: cartCubit));
        await tester.pumpAndSettle();

        final completeButton = find.byKey(
          const ValueKey('checkout_complete_button'),
        );
        expect(completeButton, findsOneWidget);

        await tester.tap(completeButton);
        await tester.pumpAndSettle();

        expect(
          find.text(
            'Ödeme altyapısı henüz aktif değildir. Gerçek sipariş oluşturulamaz.',
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      '6. Geri butonuna basıldığında onBack geri çağrımı tetiklenir',
      (tester) async {
        bool backed = false;
        await cartCubit.addProduct(testProduct1);

        await tester.pumpWidget(
          createCheckoutWidget(cubit: cartCubit, onBack: () => backed = true),
        );
        await tester.pumpAndSettle();

        final backButton = find.byKey(const ValueKey('checkout_back_button'));
        expect(backButton, findsOneWidget);

        await tester.tap(backButton);
        await tester.pumpAndSettle();

        expect(backed, isTrue);
      },
    );

    testWidgets(
      '7. Sepet temizlendiğinde CheckoutScreen anında boş duruma geçer (Reaktif Senkronizasyon)',
      (tester) async {
        await cartCubit.addProduct(testProduct1);

        await tester.pumpWidget(createCheckoutWidget(cubit: cartCubit));
        await tester.pumpAndSettle();

        expect(
          find.byKey(ValueKey('checkout_item_tile_${testProduct1.id}')),
          findsOneWidget,
        );

        // Sepet dışarıdan temizlenir
        await cartCubit.clearCart();
        await tester.pumpAndSettle();

        expect(
          find.byKey(const ValueKey('checkout_empty_state')),
          findsOneWidget,
        );
        expect(find.text('SEPETİNİZDE ÜRÜN BULUNMUYOR'), findsOneWidget);
      },
    );

    testWidgets(
      '8. Dar ekran boyutlarında (360x640) CheckoutScreen taşma olmadan render edilir',
      (tester) async {
        tester.view.physicalSize = const Size(360, 640);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await cartCubit.addProduct(testProduct1);
        await cartCubit.addProduct(testProduct2);

        await tester.pumpWidget(createCheckoutWidget(cubit: cartCubit));
        await tester.pumpAndSettle();

        expect(
          find.byKey(ValueKey('checkout_item_tile_${testProduct1.id}')),
          findsOneWidget,
        );
        expect(
          find.byKey(ValueKey('checkout_item_tile_${testProduct2.id}')),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      },
    );
  });
}
