import 'package:flutter/foundation.dart';

/// SPARKS Merkezi Sepet Durumu (CartState).
///
/// Bütün sepet verisini tek bir güvenilir kaynaktan (Single Source of Truth) yönetir.
/// `items` haritası `productId -> quantity` çiftlerini saklar; toplam sayaç ve
/// sepet doluluk durumu bu haritadan anlık olarak türetilir.
class CartState {
  const CartState({
    this.items = const <String, int>{},
    this.isLoading = false,
    this.errorMessage,
  });

  /// Ürün kimliği -> adet eşleşmesi (Örn: {"sparks-w-001": 2, "sparks-w-002": 1})
  final Map<String, int> items;

  /// Sepet verisi yerel depolamadan yüklenirken true olur
  final bool isLoading;

  /// Hata durumu mesajı
  final String? errorMessage;

  /// Sepetteki tüm ürünlerin toplam adedi (Örn: 2 + 1 = 3)
  int get totalItemCount =>
      items.values.fold(0, (sum, quantity) => sum + quantity);

  /// Sepetteki farklı ürün (satır) sayısı
  int get lineItemCount => items.length;

  /// Sepetin boş olup olmadığı
  bool get isEmpty => items.isEmpty;

  /// Belirtilen ürünün sepetteki adedi (Yoksa 0 döner)
  int getQuantity(String productId) => items[productId] ?? 0;

  /// Belirtilen ürünün sepette bulunup bulunmadığı
  bool containsProduct(String productId) =>
      items.containsKey(productId) && (items[productId] ?? 0) > 0;

  CartState copyWith({
    Map<String, int>? items,
    bool? isLoading,
    String? errorMessage,
  }) {
    return CartState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CartState &&
        mapEquals(other.items, items) &&
        other.isLoading == isLoading &&
        other.errorMessage == errorMessage;
  }

  @override
  int get hashCode => Object.hash(
    Object.hashAll(items.keys),
    Object.hashAll(items.values),
    isLoading,
    errorMessage,
  );

  @override
  String toString() =>
      'CartState(totalItems: $totalItemCount, lines: $lineItemCount, isLoading: $isLoading)';
}
