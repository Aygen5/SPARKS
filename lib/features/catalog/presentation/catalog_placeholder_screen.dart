import 'package:flutter/material.dart';
import 'package:sparks/features/catalog/domain/repositories/product_repository.dart';
import 'package:sparks/features/catalog/presentation/catalog_screen.dart';

/// SPARKS Katalog Geçici Ekranı (Aşama 5 Test Uyumluluk Sarmalayıcısı).
/// Aşama 6 ile birlikte tam donanımlı [CatalogScreen] ekranını çağırır.
class CatalogPlaceholderScreen extends StatelessWidget {
  const CatalogPlaceholderScreen({
    super.key,
    required this.gender,
    required this.category,
    this.repository,
  });

  /// Seçilen cinsiyet bağlamı ("KADIN" veya "ERKEK")
  final String gender;

  /// Seçilen kategori adı (Örn: "CEKET", "KABAN | MONT")
  final String category;

  /// İsteğe bağlı repository örneği
  final ProductRepository? repository;

  @override
  Widget build(BuildContext context) {
    return CatalogScreen(
      gender: gender,
      category: category,
      repository: repository,
    );
  }
}
