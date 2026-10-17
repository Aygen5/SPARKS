import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sparks/app/theme/app_colors.dart';
import 'package:sparks/app/theme/app_spacing.dart';
import 'package:sparks/app/theme/app_text_styles.dart';
import 'package:sparks/core/constants/app_constants.dart';

/// SPARKS Ürün Listesi Geçici Geçiş Ekranı.
/// Aşama 5 kapsamında menüden seçilen kategori ve cinsiyet bağlamını doğrulamak için hazırlanmış minimal ekrandır.
/// 3 görünüm modlu gerçek ürün listesi ve filtreleme Aşama 6'da geliştirilecektir.
class CatalogPlaceholderScreen extends StatelessWidget {
  const CatalogPlaceholderScreen({
    super.key,
    required this.gender,
    required this.category,
  });

  /// Seçilen cinsiyet bağlamı ("KADIN" veya "ERKEK")
  final String gender;

  /// Seçilen kategori adı (Örn: "CEKET", "KABAN | MONT")
  final String category;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.shoppingBackground,
      appBar: AppBar(
        backgroundColor: AppColors.shoppingBackground,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          key: const ValueKey('catalog_back_button'),
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryText),
          onPressed: () => context.pop(),
        ),
        title: Text(AppConstants.appName, style: AppTextStyles.brandLogoMedium),
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenHorizontal,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Cinsiyet Etiketi (Örn: "KADIN")
                Text(
                  gender.toUpperCase(),
                  style: AppTextStyles.caption.copyWith(
                    letterSpacing: 3.0,
                    color: AppColors.secondaryText,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),

                // Kategori Başlığı (Örn: "CEKET")
                Text(
                  category.toUpperCase(),
                  style: AppTextStyles.sectionHeading.copyWith(
                    letterSpacing: 2.0,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.md),

                // Açıklayıcı Geçiş Notu
                Text(
                  'Bu kategoriye ait ürün listesi, 3 farklı görünüm modu ve beden filtresi Aşama 6\'da geliştirilecektir.',
                  style: AppTextStyles.caption.copyWith(height: 1.5),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
