import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sparks/app/theme/app_colors.dart';
import 'package:sparks/app/theme/app_spacing.dart';
import 'package:sparks/app/theme/app_text_styles.dart';

/// SPARKS Alışverişlerim Ekranı (OrdersScreen).
///
/// Özellikler:
/// - Projede gerçek sipariş/ödeme backend altyapısı bulunmadığından sahte siparişler üretilmez.
/// - Tamamlanmış bir sipariş kaydı olmadığını ve sipariş geçmişi için sipariş altyapısının
///   gerektiğini dürüst ve net bir editoryal dille kullanıcıya aktarır.
/// - Kataloğa dönüş (`KATALOĞA DÖN`) ve sepete yönlendirme (`SEPETE GİT`) aksiyonları içerir.
class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key, this.onCatalogNavigate, this.onCartNavigate});

  /// Kataloğa dönüş için test veya özel geri çağrım
  final VoidCallback? onCatalogNavigate;

  /// Sepete yönlendirme için test veya özel geri çağrım
  final VoidCallback? onCartNavigate;

  void _handleCatalogNavigate(BuildContext context) {
    if (onCatalogNavigate != null) {
      onCatalogNavigate!();
    } else {
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/menu');
      }
    }
  }

  void _handleCartNavigate(BuildContext context) {
    if (onCartNavigate != null) {
      onCartNavigate!();
    } else {
      context.go('/cart');
    }
  }

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();

    return Scaffold(
      backgroundColor: AppColors.shoppingBackground,
      appBar: AppBar(
        backgroundColor: AppColors.shoppingBackground,
        elevation: 0,
        centerTitle: true,
        leading: canPop
            ? IconButton(
                key: const ValueKey('orders_back_button'),
                icon: const Icon(
                  Icons.arrow_back,
                  color: AppColors.primaryText,
                ),
                onPressed: () => context.pop(),
              )
            : null,
        title: Text(
          'ALIŞVERİŞLERİM',
          style: AppTextStyles.brandLogoMedium.copyWith(fontSize: 18),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            key: const ValueKey('orders_empty_state'),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenHorizontal,
              vertical: AppSpacing.lg,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.receipt_long_outlined,
                  size: 48,
                  color: AppColors.secondaryText,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'HENÜZ BİR SİPARİŞİNİZ YOK',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.sectionHeading.copyWith(
                    fontSize: 18,
                    letterSpacing: 2.5,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 380),
                  child: Text(
                    'Tamamlanmış bir alışveriş kaydınız bulunmamaktadır. Sipariş geçmişinizin listelenebilmesi için sipariş ve ödeme altyapısının tamamlanması gerekmektedir.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.secondaryText,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Aksiyon Butonları
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 320),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      OutlinedButton(
                        key: const ValueKey('orders_catalog_button'),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.primaryText),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () => _handleCatalogNavigate(context),
                        child: Text(
                          'KATALOĞA DÖN',
                          style: AppTextStyles.buttonTextOutlined,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      ElevatedButton(
                        key: const ValueKey('orders_cart_button'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryText,
                          foregroundColor: AppColors.shoppingBackground,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () => _handleCartNavigate(context),
                        child: Text(
                          'SEPETE GİT',
                          style: AppTextStyles.buttonText,
                        ),
                      ),
                    ],
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
