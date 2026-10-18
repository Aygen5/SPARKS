import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sparks/features/cart/data/datasources/cart_local_data_source.dart';
import 'package:sparks/features/cart/data/repositories/cart_repository_impl.dart';
import 'package:sparks/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:sparks/features/catalog/domain/entities/product.dart';
import 'package:sparks/features/catalog/domain/repositories/product_repository.dart';

class FakeCartProductRepository implements ProductRepository {
  FakeCartProductRepository(this.products);

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
    return [];
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final inStockProduct1 = Product(
    id: 'sparks-w-001',
    title: 'DİK YAKA ÖRGÜ HIRKA',
    price: 2890.0,
    gender: 'KADIN',
    category: 'KAZAK | HIRKA',
    images: const ['https://example.com/1.jpg', 'https://example.com/2.jpg'],
    description: 'Açıklama 1',
    colorAndCode: 'SİYAH | 111',
    materials: '%100 Yün',
    isOutOfStock: false,
  );

  final inStockProduct2 = Product(
    id: 'sparks-w-002',
    title: 'BÜZGÜLÜ DETAYLI KEMERLİ TRİKO',
    price: 3290.0,
    gender: 'KADIN',
    category: 'TOP | BODY',
    images: const ['https://example.com/3.jpg', 'https://example.com/4.jpg'],
    description: 'Açıklama 2',
    colorAndCode: 'SİYAH | 222',
    materials: '%70 Viskon',
    isOutOfStock: false,
  );

  final outOfStockProduct = Product(
    id: 'sparks-w-003',
    title: 'TÜKENEN KABAN',
    price: 6580.0,
    gender: 'KADIN',
    category: 'KABAN',
    images: const ['https://example.com/5.jpg', 'https://example.com/6.jpg'],
    description: 'Açıklama 3',
    colorAndCode: 'BORDO | 333',
    materials: '%100 Yün',
    isOutOfStock: true,
  );

  group('Aşama 8 — CartLocalDataSource Birim Testleri', () {
    test(
      'InMemoryCartLocalDataSource verileri doğru depolar ve siler',
      () async {
        final dataSource = InMemoryCartLocalDataSource({'sparks-w-001': 2});

        final initial = await dataSource.getCartItems();
        expect(initial['sparks-w-001'], 2);

        await dataSource.saveCartItems({'sparks-w-001': 3, 'sparks-w-002': 1});
        final updated = await dataSource.getCartItems();
        expect(updated.length, 2);
        expect(updated['sparks-w-001'], 3);
        expect(updated['sparks-w-002'], 1);

        await dataSource.clear();
        final cleared = await dataSource.getCartItems();
        expect(cleared, isEmpty);
      },
    );

    test('CartLocalDataSourceImpl SharedPreferences üzerinden JSON serileştirme yapar', () async {
      SharedPreferences.setMockInitialValues({
        'sparks_cart_items': '{"sparks-w-001": 2}',
      });

      const dataSource = CartLocalDataSourceImpl();
      final loaded = await dataSource.getCartItems();
      expect(loaded['sparks-w-001'], 2);

      await dataSource.saveCartItems({'sparks-w-001': 4, 'sparks-w-002': 1});
      final afterSave = await dataSource.getCartItems();
      expect(afterSave['sparks-w-001'], 4);
      expect(afterSave['sparks-w-002'], 1);

      await dataSource.clear();
      final afterClear = await dataSource.getCartItems();
      expect(afterClear, isEmpty);
    });
  });

  group('Aşama 8 — CartCubit Sepet Mantığı Birim Testleri', () {
    late InMemoryCartLocalDataSource fakeDataSource;
    late CartRepositoryImpl fakeCartRepository;
    late FakeCartProductRepository fakeProductRepository;
    late CartCubit cartCubit;

    setUp(() {
      fakeDataSource = InMemoryCartLocalDataSource();
      fakeCartRepository = CartRepositoryImpl(localDataSource: fakeDataSource);
      fakeProductRepository = FakeCartProductRepository([
        inStockProduct1,
        inStockProduct2,
        outOfStockProduct,
      ]);
      cartCubit = CartCubit(
        cartRepository: fakeCartRepository,
        productRepository: fakeProductRepository,
      );
    });

    tearDown(() {
      cartCubit.close();
    });

    test('1. Bir ürün sepete ilk kez eklendiğinde adedi 1 olur', () async {
      expect(cartCubit.state.isEmpty, isTrue);

      final result = await cartCubit.addProduct(inStockProduct1);
      expect(result, isTrue);
      expect(cartCubit.state.totalItemCount, 1);
      expect(cartCubit.state.lineItemCount, 1);
      expect(cartCubit.state.getQuantity('sparks-w-001'), 1);
    });

    test('2. Aynı ürün yeniden eklendiğinde mevcut satırın adedi artar (quantity++)', () async {
      await cartCubit.addProduct(inStockProduct1);
      expect(cartCubit.state.getQuantity('sparks-w-001'), 1);

      await cartCubit.addProduct(inStockProduct1);
      expect(cartCubit.state.getQuantity('sparks-w-001'), 2);
      expect(cartCubit.state.lineItemCount, 1);
      expect(cartCubit.state.totalItemCount, 2);
    });

    test(
      '3. Farklı ürünler ayrı satırlarda tutulur ve yinelenen kayıt oluşmaz',
      () async {
        await cartCubit.addProduct(inStockProduct1);
        await cartCubit.addProduct(inStockProduct2);

        expect(cartCubit.state.lineItemCount, 2);
        expect(cartCubit.state.totalItemCount, 2);
        expect(cartCubit.state.getQuantity('sparks-w-001'), 1);
        expect(cartCubit.state.getQuantity('sparks-w-002'), 1);
      },
    );

    test(
      '4. incrementQuantity ve decrementQuantity ürün adedini değiştirir',
      () async {
        await cartCubit.addProduct(inStockProduct1);

        await cartCubit.incrementQuantity('sparks-w-001');
        expect(cartCubit.state.getQuantity('sparks-w-001'), 2);

        await cartCubit.decrementQuantity('sparks-w-001');
        expect(cartCubit.state.getQuantity('sparks-w-001'), 1);
      },
    );

    test('5. Adet 1 iken azaltma işlemi ürünü silmez ve sıfıra düşürmez (minimum adet 1)', () async {
      await cartCubit.addProduct(inStockProduct1);
      expect(cartCubit.state.getQuantity('sparks-w-001'), 1);

      await cartCubit.decrementQuantity('sparks-w-001');
      expect(
        cartCubit.state.getQuantity('sparks-w-001'),
        1,
        reason: 'Adet 1 iken azaltma işlemi ürünü otomatik silmemeli, minimum 1 kalmalı',
      );
      expect(cartCubit.state.containsProduct('sparks-w-001'), isTrue);
    });

    test('6. removeProduct ürünü sepetten tamamen kaldırır', () async {
      await cartCubit.addProduct(inStockProduct1);
      await cartCubit.addProduct(inStockProduct2);

      await cartCubit.removeProduct('sparks-w-001');

      expect(cartCubit.state.containsProduct('sparks-w-001'), isFalse);
      expect(cartCubit.state.containsProduct('sparks-w-002'), isTrue);
      expect(cartCubit.state.lineItemCount, 1);
      expect(cartCubit.state.totalItemCount, 1);
    });

    test('7. clearCart tüm sepeti boşaltır', () async {
      await cartCubit.addProduct(inStockProduct1);
      await cartCubit.addProduct(inStockProduct2);

      await cartCubit.clearCart();

      expect(cartCubit.state.isEmpty, isTrue);
      expect(cartCubit.state.totalItemCount, 0);
      expect(cartCubit.state.lineItemCount, 0);
    });

    test(
      '8. Stokta olmayan ürün sepete eklenemez ve hata durumu döner',
      () async {
        final success = await cartCubit.addProduct(outOfStockProduct);

        expect(success, isFalse);
        expect(cartCubit.state.isEmpty, isTrue);
        expect(cartCubit.state.errorMessage, 'Tükenen ürün sepete eklenemez.');
      },
    );

    test('9. Toplam adet ve toplam tutar doğru hesaplanır', () async {
      // Product 1: 2890 TL x 2 = 5780 TL
      // Product 2: 3290 TL x 1 = 3290 TL
      // Toplam: 5780 + 3290 = 9070 TL
      await cartCubit.addProduct(inStockProduct1);
      await cartCubit.addProduct(inStockProduct1);
      await cartCubit.addProduct(inStockProduct2);

      expect(cartCubit.state.totalItemCount, 3);

      final totalPrice = await cartCubit.calculateTotalPrice();
      expect(totalPrice, 9070.0);
    });

    test('10. Repository üzerinden bulunamayan ürün kontrollü şekilde atlanır ve çökme olmaz', () async {
      // Sepette bilinmeyen ID var
      cartCubit.setInitialCartForTesting({
        'unknown-id-123': 2,
        'sparks-w-001': 1,
      });

      final views = await cartCubit.getCartItemViews();
      expect(views.length, 1);
      expect(views.first.product.id, 'sparks-w-001');
      expect(views.first.quantity, 1);

      final totalPrice = await cartCubit.calculateTotalPrice();
      expect(totalPrice, 2890.0);
    });

    test(
      '11. loadCart yerel depolamadaki kayıtları geri yükler (Kalıcılık)',
      () async {
        await fakeDataSource.saveCartItems({
          'sparks-w-001': 2,
          'sparks-w-002': 3,
        });

        await cartCubit.loadCart();

        expect(cartCubit.state.totalItemCount, 5);
        expect(cartCubit.state.getQuantity('sparks-w-001'), 2);
        expect(cartCubit.state.getQuantity('sparks-w-002'), 3);
      },
    );

    test(
      '12. addProductById geçerli kimlikle ürünü bulur ve sepete ekler',
      () async {
        final success = await cartCubit.addProductById('sparks-w-002');

        expect(success, isTrue);
        expect(cartCubit.state.getQuantity('sparks-w-002'), 1);

        final fail = await cartCubit.addProductById('non-existent-id');
        expect(fail, isFalse);
      },
    );

    test(
      '13. incrementQuantity tükenen ürünün adedini artırmaz ve hata bildirir',
      () async {
        cartCubit.setInitialCartForTesting({'sparks-w-003': 1});

        await cartCubit.incrementQuantity('sparks-w-003');

        expect(cartCubit.state.getQuantity('sparks-w-003'), 1);
        expect(
          cartCubit.state.errorMessage,
          'Tükenen ürünün adedi artırılamaz.',
        );
      },
    );
  });
}
