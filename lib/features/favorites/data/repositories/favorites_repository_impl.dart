import 'package:sparks/features/favorites/data/datasources/favorites_local_data_source.dart';
import 'package:sparks/features/favorites/domain/repositories/favorites_repository.dart';

/// SPARKS FavoritesRepository somut uygulaması.
/// `FavoritesLocalDataSource` aracılığıyla yerel kalıcılığı sağlar;
/// `Set<String>` yapısıyla benzersizliği garanti eder ve duplikasyonları önler.
class FavoritesRepositoryImpl implements FavoritesRepository {
  FavoritesRepositoryImpl({required this.localDataSource});

  final FavoritesLocalDataSource localDataSource;
  Set<String>? _cachedIds;

  @override
  Future<Set<String>> getFavoriteIds() async {
    if (_cachedIds != null) {
      return Set<String>.from(_cachedIds!);
    }
    _cachedIds = await localDataSource.getFavoriteIds();
    return Set<String>.from(_cachedIds!);
  }

  @override
  Future<bool> isFavorite(String productId) async {
    final ids = await getFavoriteIds();
    return ids.contains(productId);
  }

  @override
  Future<void> addFavorite(String productId) async {
    final ids = await getFavoriteIds();
    if (!ids.contains(productId)) {
      ids.add(productId);
      _cachedIds = ids;
      await localDataSource.saveFavoriteIds(ids);
    }
  }

  @override
  Future<void> removeFavorite(String productId) async {
    final ids = await getFavoriteIds();
    if (ids.contains(productId)) {
      ids.remove(productId);
      _cachedIds = ids;
      await localDataSource.saveFavoriteIds(ids);
    }
  }

  @override
  Future<bool> toggleFavorite(String productId) async {
    final ids = await getFavoriteIds();
    final isFav = ids.contains(productId);
    if (isFav) {
      ids.remove(productId);
    } else {
      ids.add(productId);
    }
    _cachedIds = ids;
    await localDataSource.saveFavoriteIds(ids);
    return !isFav;
  }

  @override
  Future<void> clear() async {
    _cachedIds = <String>{};
    await localDataSource.clear();
  }
}
