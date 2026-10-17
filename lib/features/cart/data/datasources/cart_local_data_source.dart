import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// SPARKS Yerel Sepet Veri Kaynağı Sözleşmesi (Data Source Contract).
/// Cihaz hafızasında yalnızca ürün kimliklerini ve adetlerini (`Map<String, int>`) saklar.
/// Kaynak: docs/architecture.md
abstract class CartLocalDataSource {
  /// Saklanan sepet ürün kimliklerini ve adetlerini döndürür.
  Future<Map<String, int>> getCartItems();

  /// Verilen sepet öğelerini kalıcı depolamaya kaydeder.
  Future<void> saveCartItems(Map<String, int> items);

  /// Tüm sepet verisini temizler.
  Future<void> clear();
}

/// SharedPreferences kullanarak sepet verisini JSON biçiminde saklayan somut sınıf.
class CartLocalDataSourceImpl implements CartLocalDataSource {
  const CartLocalDataSourceImpl({this.preferencesKey = _defaultKey});

  static const String _defaultKey = 'sparks_cart_items';
  final String preferencesKey;

  @override
  Future<Map<String, int>> getCartItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(preferencesKey);
      if (jsonString == null || jsonString.trim().isEmpty) {
        return <String, int>{};
      }

      final dynamic decoded = json.decode(jsonString);
      if (decoded is! Map) {
        return <String, int>{};
      }

      final result = <String, int>{};
      decoded.forEach((key, value) {
        if (key is String && value is int && value > 0) {
          result[key] = value;
        } else if (key is String && value is num && value > 0) {
          result[key] = value.toInt();
        }
      });
      return result;
    } catch (_) {
      return <String, int>{};
    }
  }

  @override
  Future<void> saveCartItems(Map<String, int> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = json.encode(items);
      await prefs.setString(preferencesKey, jsonString);
    } catch (_) {
      // Hata durumunda sessizce devam edilir
    }
  }

  @override
  Future<void> clear() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(preferencesKey);
    } catch (_) {}
  }
}

/// Test ortamında harici platform kanalı gerektirmeden
/// bellek içi (in-memory) çalışan hızlı test veri kaynağı.
class InMemoryCartLocalDataSource implements CartLocalDataSource {
  InMemoryCartLocalDataSource([Map<String, int>? initialItems])
    : _store = Map<String, int>.from(initialItems ?? const {});

  final Map<String, int> _store;

  @override
  Future<Map<String, int>> getCartItems() async {
    return Map<String, int>.from(_store);
  }

  @override
  Future<void> saveCartItems(Map<String, int> items) async {
    _store.clear();
    _store.addAll(items);
  }

  @override
  Future<void> clear() async {
    _store.clear();
  }
}
