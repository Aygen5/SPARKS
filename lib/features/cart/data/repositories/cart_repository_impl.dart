import 'package:sparks/features/cart/data/datasources/cart_local_data_source.dart';
import 'package:sparks/features/cart/domain/repositories/cart_repository.dart';

/// SPARKS CartRepository somut uygulaması.
/// `CartLocalDataSource` üzerinden yerel veri saklamayı ve okumayı gerçekleştirir.
class CartRepositoryImpl implements CartRepository {
  const CartRepositoryImpl({required this.localDataSource});

  final CartLocalDataSource localDataSource;

  @override
  Future<Map<String, int>> getCartItems() async {
    return localDataSource.getCartItems();
  }

  @override
  Future<void> saveCartItems(Map<String, int> items) async {
    await localDataSource.saveCartItems(items);
  }

  @override
  Future<void> clear() async {
    await localDataSource.clear();
  }
}
