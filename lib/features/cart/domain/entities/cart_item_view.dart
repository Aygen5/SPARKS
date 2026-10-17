import 'package:sparks/features/catalog/domain/entities/product.dart';

/// SPARKS Sepet Satırı Görünüm Modeli (CartItemView).
/// `Product` varlığı ile sepetteki adedini birleştirir; ara toplamı hesaplar.
class CartItemView {
  const CartItemView({required this.product, required this.quantity})
    : assert(quantity > 0, 'Ürün adedi 0 veya negatif olamaz');

  /// Sepetteki ürün
  final Product product;

  /// Sepetteki ürün adedi
  final int quantity;

  /// Bu satırın toplam satış tutarı (Fiyat * Adet)
  double get totalPrice => product.price * quantity;

  CartItemView copyWith({Product? product, int? quantity}) {
    return CartItemView(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CartItemView &&
        other.product.id == product.id &&
        other.quantity == quantity;
  }

  @override
  int get hashCode => Object.hash(product.id, quantity);

  @override
  String toString() =>
      'CartItemView(product: ${product.title}, quantity: $quantity, total: $totalPrice TL)';
}
