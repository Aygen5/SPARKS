import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sparks/app/theme/app_colors.dart';
import 'package:sparks/app/theme/app_spacing.dart';
import 'package:sparks/app/theme/app_text_styles.dart';
import 'package:sparks/core/constants/app_constants.dart';

/// SPARKS Gerçek Hesabım Ekranı (AccountScreen).
///
/// Özellikler:
/// - Projede gerçek bir backend veya auth servisi bulunmadığından sahte kullanıcı profili
///   veya uydurma bilgiler üretilmez; misafir kullanıcı deneyimi dürüstçe sunulur.
/// - Giriş ve kayıt servisinin henüz aktif olmadığı açıkça belirtilir.
/// - Gerçek çalışan editoryal kısayollar:
///   - `FAVORİLERİM` -> `/favorites`
///   - `ALIŞVERİŞLERİM` -> `/account/orders`
///   - `SEPETİM` -> `/cart`
/// - Uygulama sürümü ve doğrulanabilir editoryal destek bilgisi.
class AccountScreen extends StatelessWidget {
  const AccountScreen({
    super.key,
    this.onNavigateToFavorites,
    this.onNavigateToOrders,
    this.onNavigateToCart,
  });

  /// Favoriler ekranına geçiş için geri çağrım (opsiyonel / test edilebilir)
  final VoidCallback? onNavigateToFavorites;

  /// Alışverişlerim ekranına geçiş için geri çağrım (opsiyonel / test edilebilir)
  final VoidCallback? onNavigateToOrders;

  /// Sepet sekmesine geçiş için geri çağrım (opsiyonel / test edilebilir)
  final VoidCallback? onNavigateToCart;

  void _handleFavoritesTap(BuildContext context) {
    if (onNavigateToFavorites != null) {
      onNavigateToFavorites!();
    } else {
      context.push('/favorites');
    }
  }

  void _handleOrdersTap(BuildContext context) {
    if (onNavigateToOrders != null) {
      onNavigateToOrders!();
    } else {
      context.push('/account/orders');
    }
  }

  void _handleCartTap(BuildContext context) {
    if (onNavigateToCart != null) {
      onNavigateToCart!();
    } else {
      context.go('/cart');
    }
  }

  void _showAuthNotice(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Kimlik doğrulama ve üyelik servisi henüz aktif değildir.',
        ),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.shoppingBackground,
      appBar: AppBar(
        backgroundColor: AppColors.shoppingBackground,
        elevation: 0,
        centerTitle: true,
        title: Text(
          AppConstants.tabAccount.toUpperCase(),
          style: AppTextStyles.brandLogoMedium.copyWith(fontSize: 18),
        ),
      ),
      body: SafeArea(
        child: ListView(
          key: const ValueKey('account_screen_list'),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenHorizontal,
            vertical: AppSpacing.md,
          ),
          children: [
            // 1. Misafir Kullanıcı Kartı (Dürüst ve Şeffaf Tasarım)
            _buildGuestCard(context),

            const SizedBox(height: AppSpacing.lg),
            const Divider(color: AppColors.divider, height: 1),
            const SizedBox(height: AppSpacing.md),

            // 2. Kısayol Menü Başlığı
            Text(
              'HESAP MERKEZİ',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.secondaryText,
                letterSpacing: 2.0,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            // 3. Menü Kısayolları (FAVORİLERİM, ALIŞVERİŞLERİM, SEPETİM)
            _buildMenuItem(
              key: const ValueKey('account_favorites_button'),
              title: 'FAVORİLERİM',
              subtitle: 'Kaydettiğiniz ürünleri inceleyin',
              icon: Icons.favorite_border,
              onTap: () => _handleFavoritesTap(context),
            ),
            const Divider(color: AppColors.divider, height: 1),

            _buildMenuItem(
              key: const ValueKey('account_orders_button'),
              title: 'ALIŞVERİŞLERİM',
              subtitle: 'Sipariş geçmişi ve detayları',
              icon: Icons.receipt_long_outlined,
              onTap: () => _handleOrdersTap(context),
            ),
            const Divider(color: AppColors.divider, height: 1),

            _buildMenuItem(
              key: const ValueKey('account_cart_button'),
              title: 'SEPETİM',
              subtitle: 'Sepetinizdeki ürünleri yönetin',
              icon: Icons.shopping_bag_outlined,
              onTap: () => _handleCartTap(context),
            ),
            const Divider(color: AppColors.divider, height: 1),

            const SizedBox(height: AppSpacing.xl),

            // 4. Uygulama ve Destek Bilgilendirmesi
            _buildSupportSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildGuestCard(BuildContext context) {
    return Container(
      key: const ValueKey('account_guest_card'),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.editorialAnthracite,
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: AppColors.shoppingBackground,
                ),
                child: const Icon(
                  Icons.person_outline,
                  color: AppColors.primaryText,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MİSAFİR KULLANICI',
                      style: AppTextStyles.menuItem.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Giriş yapılmadı',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.secondaryText,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Kullanıcı hesabı ve kimlik doğrulama altyapısı henüz aktif değildir. Tüm favorilerinizi ve sepetinizi bu cihaz üzerinden misafir olarak yönetebilirsiniz.',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.secondaryText,
              height: 1.4,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton(
            key: const ValueKey('account_login_button'),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.secondaryText),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            onPressed: () => _showAuthNotice(context),
            child: Text(
              'GİRİŞ / KAYIT (YAKINDA)',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.primaryText,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required Key key,
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      key: key,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primaryText, size: 22),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.menuItem.copyWith(
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.secondaryText,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: AppColors.secondaryText,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Column(
        key: const ValueKey('account_support_section'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SPARKS v1.0.0',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.secondaryText,
              letterSpacing: 1.5,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            AppConstants.appTagline,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.secondaryText,
              letterSpacing: 1.0,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Müşteri Desteği: destek@sparks.fashion',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.secondaryText,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
