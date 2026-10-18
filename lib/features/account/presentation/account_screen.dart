import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sparks/app/router/app_router.dart';
import 'package:sparks/app/theme/app_colors.dart';
import 'package:sparks/app/theme/app_spacing.dart';
import 'package:sparks/app/theme/app_text_styles.dart';
import 'package:sparks/core/constants/app_constants.dart';
import 'package:sparks/features/auth/domain/entities/app_user.dart';
import 'package:sparks/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:sparks/features/auth/presentation/cubit/auth_state.dart';

/// SPARKS Hesabım Ekranı (AccountScreen).
///
/// Aşama 13: Oturum Durumuna (AuthCubit) Göre Dinamik Ekran.
/// - Misafir Kullanıcı:
///   - "MİSAFİR KULLANICI" kartı (`account_guest_card`)
///   - "GİRİŞ YAP" (`account_login_button`) ve "KAYIT OL" (`account_register_button`) aksiyonları
///   - Favorilerim, Alışverişlerim ve Sepetim kısayolları çalışmaya devam eder
/// - Giriş Yapmış Kullanıcı:
///   - "HESABIM" kartı (`account_user_card`)
///   - Gerçek e-posta adresi (`account_user_email`) ve varsa gerçek ad soyad
///   - Sahte avatar veya uydurma profil bilgisi gösterilmez
///   - "ÇIKIŞ YAP" butonu (`account_logout_button`) ve editoryal onay dialogu (`account_logout_confirm_dialog`)
///   - Çıkış sonrasında anında misafir görünümüne dönüş
class AccountScreen extends StatelessWidget {
  const AccountScreen({
    super.key,
    this.authCubit,
    this.onLoginTap,
    this.onRegisterTap,
    this.onLogoutTap,
    this.onNavigateToFavorites,
    this.onNavigateToOrders,
    this.onNavigateToCart,
  });

  /// Test edilebilirlik için dışarıdan enjekte edilebilen AuthCubit örneği
  final AuthCubit? authCubit;

  /// Giriş Yap butonuna dokunulduğunda çağrılır
  final VoidCallback? onLoginTap;

  /// Kayıt Ol butonuna dokunulduğunda çağrılır
  final VoidCallback? onRegisterTap;

  /// Çıkış Yap butonuna dokunulduğunda çağrılır
  final VoidCallback? onLogoutTap;

  /// Favoriler ekranına geçiş için geri çağrım
  final VoidCallback? onNavigateToFavorites;

  /// Alışverişlerim ekranına geçiş için geri çağrım
  final VoidCallback? onNavigateToOrders;

  /// Sepet sekmesine geçiş için geri çağrım
  final VoidCallback? onNavigateToCart;

  AuthCubit _resolveAuthCubit(BuildContext context) {
    if (authCubit != null) return authCubit!;
    try {
      return context.read<AuthCubit>();
    } catch (_) {
      return AuthCubit.instance;
    }
  }

  void _handleLoginTap(BuildContext context) {
    if (onLoginTap != null) {
      onLoginTap!();
    } else {
      context.push(AppRoutes.login);
    }
  }

  void _handleRegisterTap(BuildContext context) {
    if (onRegisterTap != null) {
      onRegisterTap!();
    } else {
      context.push(AppRoutes.register);
    }
  }

  void _handleLogoutTap(BuildContext context, AuthCubit cubit) {
    if (onLogoutTap != null) {
      onLogoutTap!();
      return;
    }

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          key: const ValueKey('account_logout_confirm_dialog'),
          backgroundColor: AppColors.editorialAnthracite,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          title: Text(
            'OTURUMU KAPAT',
            style: AppTextStyles.menuItem.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 2.0,
            ),
          ),
          content: Text(
            'Hesabınızdan çıkış yapmak istediğinize emin misiniz? Favorileriniz ve sepetiniz bu cihazda korunacaktır.',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.secondaryText,
              fontSize: 12,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              key: const ValueKey('account_logout_cancel_button'),
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'VAZGEÇ',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.secondaryText,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.0,
                ),
              ),
            ),
            ElevatedButton(
              key: const ValueKey('account_logout_confirm_button'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryText,
                foregroundColor: AppColors.shoppingBackground,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
                elevation: 0,
              ),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await cubit.signOut();
              },
              child: Text(
                'ÇIKIŞ YAP',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.shoppingBackground,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _handleFavoritesTap(BuildContext context) {
    if (onNavigateToFavorites != null) {
      onNavigateToFavorites!();
    } else {
      context.push(AppRoutes.favorites);
    }
  }

  void _handleOrdersTap(BuildContext context) {
    if (onNavigateToOrders != null) {
      onNavigateToOrders!();
    } else {
      context.push(AppRoutes.orders);
    }
  }

  void _handleCartTap(BuildContext context) {
    if (onNavigateToCart != null) {
      onNavigateToCart!();
    } else {
      context.go(AppRoutes.cart);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = _resolveAuthCubit(context);

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
        child: BlocBuilder<AuthCubit, AuthState>(
          bloc: cubit,
          builder: (context, authState) {
            final user = authState.user;
            final isAuthenticated = authState.isAuthenticated && user != null;

            return ListView(
              key: const ValueKey('account_screen_list'),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenHorizontal,
                vertical: AppSpacing.md,
              ),
              children: [
                // 1. Duruma göre Misafir veya Giriş Yapmış Kullanıcı Kartı
                if (isAuthenticated)
                  _buildUserCard(context, cubit, user)
                else
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
            );
          },
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
            'Siparişlerinizi ve üyelik deneyiminizi kişiselleştirmek için giriş yapabilir veya yeni bir hesap oluşturabilirsiniz. Favorileriniz ve sepetiniz bu cihazda saklanmaya devam eder.',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.secondaryText,
              height: 1.4,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  key: const ValueKey('account_login_button'),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primaryText),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () => _handleLoginTap(context),
                  child: Text(
                    'GİRİŞ YAP',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primaryText,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: OutlinedButton(
                  key: const ValueKey('account_register_button'),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: AppColors.secondaryText.withValues(alpha: 0.6),
                    ),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () => _handleRegisterTap(context),
                  child: Text(
                    'KAYIT OL',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.secondaryText,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(BuildContext context, AuthCubit cubit, AppUser user) {
    final title =
        user.displayName != null && user.displayName!.trim().isNotEmpty
        ? user.formattedName
        : 'SPARKS ÜYESİ';

    return Container(
      key: const ValueKey('account_user_card'),
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
                  Icons.person,
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
                      title,
                      style: AppTextStyles.menuItem.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user.email,
                      key: const ValueKey('account_user_email'),
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primaryText.withValues(alpha: 0.85),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            user.isEmailVerified
                ? 'Doğrulanmış SPARKS üyesi'
                : 'Oturum aktif (E-posta doğrulaması bekleniyor)',
            key: const ValueKey('account_user_status'),
            style: AppTextStyles.caption.copyWith(
              color: AppColors.secondaryText,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton(
            key: const ValueKey('account_logout_button'),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.error),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            onPressed: () => _handleLogoutTap(context, cubit),
            child: Text(
              'ÇIKIŞ YAP',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
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
