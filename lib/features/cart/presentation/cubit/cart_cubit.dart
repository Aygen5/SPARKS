import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sparks/features/cart/data/datasources/cart_local_data_source.dart';
import 'package:sparks/features/cart/data/repositories/cart_repository_impl.dart';
import 'package:sparks/features/cart/domain/entities/cart_item_view.dart';
import 'package:sparks/features/cart/domain/repositories/cart_repository.dart';
import 'package:sparks/features/cart/presentation/cubit/cart_state.dart';
import 'package:sparks/features/catalog/data/datasources/product_local_data_source.dart';
import 'package:sparks/features/catalog/data/repositories/product_repository_impl.dart';
import 'package:sparks/features/catalog/domain/entities/product.dart';
import 'package:sparks/features/catalog/domain/repositories/product_repository.dart';

/// SPARKS Merkezi Sepet Yöneticisi (CartCubit).
///
/// Bütün ekranlarda sepet ekleme, adet artırma/azaltma ve silme işlemlerini
/// tek bir güvenilir durumdan (Single Source of Truth) yönetir.
/// Veriyi `SharedPreferences` üzerinden kalıcı saklar ve ürün bilgilerini
/// `ProductRepository` ile dinamik olarak çözümler.
class CartCubit extends Cubit<CartState> {
  CartCubit({
    CartRepository? cartRepository,
    ProductRepository? productRepository,
    Map<String, int>? initialItems,
  }) : _cartRepository =
           cartRepository ??
           CartRepositoryImpl(localDataSource: const CartLocalDataSourceImpl()),
       _productRepository =
           productRepository ??
           ProductRepositoryImpl(
             localDataSource: const ProductLocalDataSourceImpl(),
           ),
       super(
         CartState(
           items: initialItems != null
               ? Map<String, int>.from(initialItems)
               : const <String, int>{},
         ),
       );

  /// Singleton / küresel erişim örneği
  static CartCubit instance = CartCubit();

  /// Testler için yöneticinin durumunu sıfırlar veya yeni bir örnek enjekte eder
  static void resetForTesting([CartCubit? newInstance]) {
    instance = newInstance ?? CartCubit();
  }

  final CartRepository _cartRepository;
  final ProductRepository _productRepository;

  /// Yerel depolamadaki kayıtlı sepeti belleğe asenkron olarak yükler
  Future<void> loadCart() async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final savedItems = await _cartRepository.getCartItems();
      emit(state.copyWith(items: savedItems, isLoading: false));
    } catch (_) {
      emit(state.copyWith(isLoading: false));
    }
  }

  /// Ürünü sepete ekler (Stokta yoksa reddeder, varsa adedini 1 artırır)
  Future<bool> addProduct(Product product) async {
    // 1. Kural: Stokta olmayan ürün sepete eklenemez
    if (product.isOutOfStock) {
      emit(state.copyWith(errorMessage: 'Tükenen ürün sepete eklenemez.'));
      return false;
    }

    final updated = Map<String, int>.from(state.items);
    final currentQty = updated[product.id] ?? 0;

    // 2. Kural: İlk kez ekleniyorsa 1, mevcutsa 1 artır
    updated[product.id] = currentQty + 1;

    emit(state.copyWith(items: updated, errorMessage: null));

    try {
      await _cartRepository.saveCartItems(updated);
    } catch (_) {}

    return true;
  }

  /// Ürün kimliği üzerinden ürünü bularak sepete ekler
  Future<bool> addProductById(String productId) async {
    try {
      final product = await _productRepository.getProductById(productId);
      if (product == null) {
        emit(state.copyWith(errorMessage: 'Ürün bulunamadı.'));
        return false;
      }
      return await addProduct(product);
    } catch (_) {
      emit(state.copyWith(errorMessage: 'Ürün sepete eklenirken hata oluştu.'));
      return false;
    }
  }

  /// Ürün adedini 1 artırır
  Future<void> incrementQuantity(String productId) async {
    if (!state.items.containsKey(productId)) return;

    final updated = Map<String, int>.from(state.items);
    updated[productId] = (updated[productId] ?? 1) + 1;

    emit(state.copyWith(items: updated, errorMessage: null));

    try {
      await _cartRepository.saveCartItems(updated);
    } catch (_) {}
  }

  /// Ürün adedini 1 azaltır.
  /// Kural: Adet 1 iken azaltma işlemi ürünü silmez; minimum adet 1'dir.
  Future<void> decrementQuantity(String productId) async {
    if (!state.items.containsKey(productId)) return;

    final currentQty = state.items[productId] ?? 1;
    if (currentQty <= 1) {
      // 1 iken azaltılamaz, kaldırma işlemi açık bir aksiyon olmalıdır
      return;
    }

    final updated = Map<String, int>.from(state.items);
    updated[productId] = currentQty - 1;

    emit(state.copyWith(items: updated, errorMessage: null));

    try {
      await _cartRepository.saveCartItems(updated);
    } catch (_) {}
  }

  /// Ürünü sepetten tamamen kaldırır
  Future<void> removeProduct(String productId) async {
    if (!state.items.containsKey(productId)) return;

    final updated = Map<String, int>.from(state.items);
    updated.remove(productId);

    emit(state.copyWith(items: updated, errorMessage: null));

    try {
      await _cartRepository.saveCartItems(updated);
    } catch (_) {}
  }

  /// Sepeti tamamen boşaltır
  Future<void> clearCart() async {
    emit(state.copyWith(items: const <String, int>{}, errorMessage: null));

    try {
      await _cartRepository.clear();
    } catch (_) {}
  }

  /// Sepetteki ürün kimliklerini `ProductRepository` üzerinden tam ürün bilgisine dönüştürür.
  /// Repository'de bulunamayan ürünler çökmeye sebep olmadan atlanır.
  Future<List<CartItemView>> getCartItemViews() async {
    final views = <CartItemView>[];

    for (final entry in state.items.entries) {
      try {
        final product = await _productRepository.getProductById(entry.key);
        if (product != null) {
          views.add(CartItemView(product: product, quantity: entry.value));
        }
      } catch (_) {
        // Çökmeyi engelle ve devam et
      }
    }

    return views;
  }

  /// Sepetteki tüm satırların toplam satış tutarını (TL) hesaplar
  Future<double> calculateTotalPrice() async {
    final views = await getCartItemViews();
    return views.fold<double>(0.0, (sum, item) => sum + item.totalPrice);
  }

  /// Test senaryolarında doğrudan başlangıç sepetini enjekte etmek için kullanılır
  void setInitialCartForTesting(Map<String, int> items) {
    emit(state.copyWith(items: Map<String, int>.from(items), isLoading: false));
  }
}
