import 'package:flutter/foundation.dart';
import 'package:sparks/features/favorites/data/datasources/favorites_local_data_source.dart';
import 'package:sparks/features/favorites/data/repositories/favorites_repository_impl.dart';
import 'package:sparks/features/favorites/domain/repositories/favorites_repository.dart';

/// SPARKS Merkezi Favori Durum Yöneticisi (FavoritesManager).
///
/// Uygulama genelinde favoriye eklenen ürün kimliklerini (ID) yönetir.
/// `ChangeNotifier` arayüzü sayesinde dinleyicileri (UI ekranlarını ve widget'ları)
/// anlık olarak uyarır ve `SharedPreferences` üzerinden kalıcı saklama sağlar.
class FavoritesManager extends ChangeNotifier {
  FavoritesManager({FavoritesRepository? repository, Set<String>? initialIds})
    : _repository =
          repository ??
          FavoritesRepositoryImpl(
            localDataSource: const FavoritesLocalDataSourceImpl(),
          ) {
    if (initialIds != null) {
      _favoriteIds.addAll(initialIds);
      _isInitialized = true;
    }
  }

  /// Singleton / küresel erişim örneği
  static FavoritesManager instance = FavoritesManager();

  /// Testler için yöneticinin durumunu sıfırlar veya yeni bir örnek enjekte eder
  static void resetForTesting([FavoritesManager? newInstance]) {
    instance = newInstance ?? FavoritesManager();
  }

  final FavoritesRepository _repository;
  final Set<String> _favoriteIds = <String>{};
  bool _isInitialized = false;

  /// Yöneticinin yerel depolamadan başlatılıp başlatılmadığı
  bool get isInitialized => _isInitialized;

  /// Favori ürün kimliklerinin salt-okunur kümesi
  Set<String> get favoriteIds => Set<String>.unmodifiable(_favoriteIds);

  /// Toplam favori ürün sayısı
  int get count => _favoriteIds.length;

  /// Belirtilen ürünün favori olup olmadığını senkron olarak kontrol eder
  bool isFavorite(String productId) {
    return _favoriteIds.contains(productId);
  }

  /// Yerel depolamadaki kayıtlı favorileri belleğe asenkron olarak yükler
  Future<void> init() async {
    try {
      final savedIds = await _repository.getFavoriteIds();
      _favoriteIds.clear();
      _favoriteIds.addAll(savedIds);
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      // Hata durumunda boş liste ile devam edilir
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// Ürünü favorilere ekler veya favorilerden çıkarır (Toggle)
  Future<bool> toggleFavorite(String productId) async {
    final willBeFavorite = !_favoriteIds.contains(productId);

    if (willBeFavorite) {
      _favoriteIds.add(productId);
    } else {
      _favoriteIds.remove(productId);
    }
    notifyListeners();

    try {
      await _repository.toggleFavorite(productId);
    } catch (_) {
      // Kalıcı depolama hatasında bellek durumu korunur
    }

    return willBeFavorite;
  }

  /// Ürünü favorilere ekler
  Future<void> addFavorite(String productId) async {
    if (!_favoriteIds.contains(productId)) {
      _favoriteIds.add(productId);
      notifyListeners();
      try {
        await _repository.addFavorite(productId);
      } catch (_) {}
    }
  }

  /// Ürünü favorilerden çıkarır
  Future<void> removeFavorite(String productId) async {
    if (_favoriteIds.contains(productId)) {
      _favoriteIds.remove(productId);
      notifyListeners();
      try {
        await _repository.removeFavorite(productId);
      } catch (_) {}
    }
  }

  /// Tüm favorileri temizler
  Future<void> clear() async {
    if (_favoriteIds.isNotEmpty) {
      _favoriteIds.clear();
      notifyListeners();
      try {
        await _repository.clear();
      } catch (_) {}
    }
  }

  /// Test senaryolarında doğrudan başlangıç favori kümesini tanımlamak için kullanılır
  void setInitialFavoritesForTesting(Set<String> ids) {
    _favoriteIds.clear();
    _favoriteIds.addAll(ids);
    _isInitialized = true;
    notifyListeners();
  }
}
