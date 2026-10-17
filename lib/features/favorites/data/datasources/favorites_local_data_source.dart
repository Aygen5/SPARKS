import 'package:shared_preferences/shared_preferences.dart';

/// SPARKS Yerel Favori Veri Kaynağı Sözleşmesi (Data Source Contract).
/// Cihaz hafızasında yalnızca favoriye eklenmiş ürün kimliklerini (ID: `Set<String>`) saklar.
/// Kaynak: docs/architecture.md
abstract class FavoritesLocalDataSource {
  /// Saklanan favori ürün kimliklerini küme (Set) olarak döndürür.
  Future<Set<String>> getFavoriteIds();

  /// Verilen favori ürün kimliklerini kalıcı hafızaya yazar.
  Future<void> saveFavoriteIds(Set<String> ids);

  /// Tüm kayıtlı favorileri temizler.
  Future<void> clear();
}

/// SharedPreferences kullanarak favori ürün kimliklerini kalıcı olarak saklayan somut sınıf.
class FavoritesLocalDataSourceImpl implements FavoritesLocalDataSource {
  const FavoritesLocalDataSourceImpl({this.preferencesKey = _defaultKey});

  static const String _defaultKey = 'sparks_favorite_product_ids';
  final String preferencesKey;

  @override
  Future<Set<String>> getFavoriteIds() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(preferencesKey) ?? const [];
    return list.toSet();
  }

  @override
  Future<void> saveFavoriteIds(Set<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(preferencesKey, ids.toList());
  }

  @override
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(preferencesKey);
  }
}

/// Test ortamında harici platform kanalı (SharedPreferences mock) gerektirmeden
/// bellek içi (in-memory) çalışan hızlı test veri kaynağı.
class InMemoryFavoritesLocalDataSource implements FavoritesLocalDataSource {
  InMemoryFavoritesLocalDataSource([Set<String>? initialIds])
    : _store = Set<String>.from(initialIds ?? const {});

  final Set<String> _store;

  @override
  Future<Set<String>> getFavoriteIds() async {
    return Set<String>.from(_store);
  }

  @override
  Future<void> saveFavoriteIds(Set<String> ids) async {
    _store.clear();
    _store.addAll(ids);
  }

  @override
  Future<void> clear() async {
    _store.clear();
  }
}
