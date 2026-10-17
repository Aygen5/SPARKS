import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sparks/app/theme/app_colors.dart';
import 'package:sparks/app/theme/app_spacing.dart';
import 'package:sparks/app/theme/app_text_styles.dart';
import 'package:sparks/core/constants/app_constants.dart';

/// SPARKS Ürün Detayı Geçici Ekranı (Placeholder).
/// Aşama 6 kapsamında katalog veya arama ekranından ürün tıklandığında ürün kimliğini
/// taşımak ve navigasyon akışını korumak için tasarlanmıştır.
/// Tam donanımlı editoryal ürün detay sayfası Aşama 7'de geliştirilecektir.
class ProductDetailPlaceholderScreen extends StatelessWidget {
  const ProductDetailPlaceholderScreen({super.key, required this.productId});

  /// Görüntülenen ürünün kimliği
  final String productId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.shoppingBackground,
      appBar: AppBar(
        backgroundColor: AppColors.shoppingBackground,
        elevation: 0,
        leading: IconButton(
          key: const ValueKey('product_detail_back_button'),
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryText),
          onPressed: () => context.pop(),
        ),
        title: Text(AppConstants.appName, style: AppTextStyles.brandLogoMedium),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'ÜRÜN DETAYI',
                  style: AppTextStyles.sectionHeading.copyWith(
                    letterSpacing: 3.0,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'ID: $productId',
                  key: const ValueKey('product_detail_id_text'),
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.secondaryText,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Bu ekran Aşama 7 kapsamında iki büyük editoryal görsel, malzeme sekmeleri ve sepete ekleme özellikleriyle geliştirilecektir.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
