import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sparks/app/theme/app_colors.dart';
import 'package:sparks/app/theme/app_spacing.dart';
import 'package:sparks/app/theme/app_text_styles.dart';
import 'package:sparks/core/utils/currency_formatter.dart';
import 'package:sparks/features/cart/domain/entities/cart_item_view.dart';
import 'package:sparks/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:sparks/features/cart/presentation/cubit/cart_state.dart';

/// SPARKS Sipariş Öncesi İnceleme ve Kontrol Ekranı (CheckoutScreen).
///
/// Özellikler:
/// - `CartCubit` ile doğrudan entegrasyon ve tek merkezli fiyat/sepet senkronizasyonu.
/// - Sepetteki gerçek ürünleri, adetleri, birim fiyatları ve satır toplamlarını editoryal listeleme.
/// - Ara toplam, teslimat ve genel toplam dökümü.
/// - Sepet boşaldığında veya boş açıldığında editoryal bilgilendirme ve sepete geri dönüş.
/// - Dürüstlük İlkesi: Sahte ödeme formu, sahte kart/kupon veya uydurma sipariş numarası üretmez.
///   Ödeme ve sipariş altyapısının henüz aktif olmadığını açıkça bildirir.
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({
    super.key,
    this.cartCubit,
    this.onBack,
    this.onReturnToCart,
    this.onReturnToCatalog,
  });

  /// Test edilebilirlik için dışarıdan enjekte edilebilen CartCubit örneği
  final CartCubit? cartCubit;

  /// Geri dönme aksiyonu için geri çağrım
  final VoidCallback? onBack;

  /// Sepete dönme aksiyonu için geri çağrım
  final VoidCallback? onReturnToCart;

  /// Kataloğa dönme aksiyonu için geri çağrım
  final VoidCallback? onReturnToCatalog;

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  CartCubit _resolveCubit(BuildContext context) {
    if (widget.cartCubit != null) return widget.cartCubit!;
    try {
      return context.read<CartCubit>();
    } catch (_) {
      return CartCubit.instance;
    }
  }

  void _handleBack() {
    if (widget.onBack != null) {
      widget.onBack!();
    } else if (context.canPop()) {
      context.pop();
    } else {
      context.go('/cart');
    }
  }

  void _handleReturnToCart() {
    if (widget.onReturnToCart != null) {
      widget.onReturnToCart!();
    } else {
      context.go('/cart');
    }
  }

  void _showNoticeMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Ödeme altyapısı henüz aktif değildir. Gerçek sipariş oluşturulamaz.',
        ),
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cubit = _resolveCubit(context);

    return Scaffold(
      key: const ValueKey('checkout_screen'),
      backgroundColor: AppColors.shoppingBackground,
      appBar: AppBar(
        backgroundColor: AppColors.shoppingBackground,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          key: const ValueKey('checkout_back_button'),
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryText),
          onPressed: _handleBack,
        ),
        title: Text(
          'SİPARİŞ ÖZETİ',
          style: AppTextStyles.brandLogoMedium.copyWith(fontSize: 18),
        ),
      ),
      body: SafeArea(
        child: BlocBuilder<CartCubit, CartState>(
          bloc: cubit,
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primaryText,
                    ),
                  ),
                ),
              );
            }

            if (state.isEmpty) {
              return _buildEmptyState();
            }

            return FutureBuilder<List<CartItemView>>(
              future: cubit.getCartItemViews(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData) {
                  return const Center(
                    child: SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primaryText,
                        ),
                      ),
                    ),
                  );
                }

                final views = snapshot.data ?? const <CartItemView>[];
                if (views.isEmpty) {
                  return _buildEmptyState();
                }

                final subtotal = views.fold<double>(
                  0.0,
                  (sum, item) => sum + item.totalPrice,
                );

                return Column(
                  children: [
                    Expanded(
                      child: ListView(
                        key: const ValueKey('checkout_items_list'),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.screenHorizontal,
                          vertical: AppSpacing.md,
                        ),
                        children: [
                          // 1. Ürün İnceleme Başlığı
                          Text(
                            'SİPARİŞ EDİLECEK ÜRÜNLER (${state.totalItemCount})',
                            style: AppTextStyles.caption.copyWith(
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryText,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),

                          // 2. Ürün Kalemleri Listesi
                          ...views.map((item) => _buildItemTile(item)),

                          const Divider(color: AppColors.divider, height: 36),

                          // 3. Fiyat Özeti Dökümü
                          _buildPriceBreakdown(subtotal),

                          const SizedBox(height: AppSpacing.lg),

                          // 4. Dürüstlük ve Bilgilendirme Kutusu
                          _buildNoticeBox(),

                          const SizedBox(height: AppSpacing.lg),
                        ],
                      ),
                    ),

                    // 5. Sabit Alt Siparişi Tamamla Alanı
                    _buildBottomBar(subtotal),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      key: const ValueKey('checkout_empty_state'),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenHorizontal,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.shopping_bag_outlined,
              size: 48,
              color: AppColors.secondaryText,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'SEPETİNİZDE ÜRÜN BULUNMUYOR',
              textAlign: TextAlign.center,
              style: AppTextStyles.sectionHeading.copyWith(
                fontSize: 16,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Sipariş özeti görüntülemek için sepetinizde en az bir ürün olmalıdır.',
              textAlign: TextAlign.center,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.secondaryText,
                height: 1.5,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            OutlinedButton(
              key: const ValueKey('checkout_return_cart_button'),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primaryText),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
              ),
              onPressed: _handleReturnToCart,
              child: Text(
                'SEPETE DÖN',
                style: AppTextStyles.buttonTextOutlined,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemTile(CartItemView item) {
    final product = item.product;

    return Padding(
      key: ValueKey('checkout_item_tile_${product.id}'),
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Küçük Görsel
          SizedBox(
            width: 64,
            child: AspectRatio(
              aspectRatio: 3 / 4,
              child: Container(
                color: AppColors.editorialAnthracite,
                child: Image.network(
                  product.images.first,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child: Icon(
                      Icons.broken_image_outlined,
                      color: AppColors.secondaryText,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),

          // Ürün Başlığı, Renk ve Fiyat Hesabı
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.title,
                  style: AppTextStyles.productTitle.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  product.colorAndCode,
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 10,
                    color: AppColors.secondaryText,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${item.quantity} x ${CurrencyFormatter.format(product.price)}',
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 11,
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),

          // Satır Toplamı
          Text(
            CurrencyFormatter.format(item.totalPrice),
            style: AppTextStyles.productPrice.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceBreakdown(double subtotal) {
    return Column(
      children: [
        // Ara Toplam
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'ARA TOPLAM',
              style: AppTextStyles.caption.copyWith(
                letterSpacing: 1.2,
                color: AppColors.secondaryText,
              ),
            ),
            Text(
              CurrencyFormatter.format(subtotal),
              key: const ValueKey('checkout_subtotal_price'),
              style: AppTextStyles.body.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),

        // Standart Teslimat
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'STANDART TESLİMAT',
              style: AppTextStyles.caption.copyWith(
                letterSpacing: 1.2,
                color: AppColors.secondaryText,
              ),
            ),
            Text(
              'ÜCRETSİZ',
              key: const ValueKey('checkout_shipping_fee'),
              style: AppTextStyles.caption.copyWith(
                color: AppColors.primaryText,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),

        const Divider(color: AppColors.dividerLight),
        const SizedBox(height: AppSpacing.xs),

        // Genel Toplam
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'GENEL TOPLAM',
              style: AppTextStyles.menuItem.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Flexible(
              child: Text(
                CurrencyFormatter.format(subtotal),
                key: const ValueKey('checkout_total_price'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.productPrice.copyWith(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNoticeBox() {
    return Container(
      key: const ValueKey('checkout_notice_box'),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.shoppingBackground,
        border: Border.all(color: AppColors.dividerLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.info_outline,
                size: 16,
                color: AppColors.secondaryText,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'ÖNEMLİ BİLGİLENDİRME',
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: AppColors.primaryText,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'SPARKS ödeme ve sipariş altyapısı henüz aktif değildir. '
            'Bu ekran sepet içeriğinizi ve alışveriş öncesi kontrollerinizi incelemeniz için hazırlanmıştır. '
            'Canlı sipariş ve güvenli ödeme entegrasyonu sonraki aşamalarda sunulacaktır.',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.secondaryText,
              fontSize: 11,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(double subtotal) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.shoppingBackground,
        border: Border(top: BorderSide(color: AppColors.divider, width: 1)),
      ),
      padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
            key: const ValueKey('checkout_complete_button'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryText,
              foregroundColor: AppColors.shoppingBackground,
              elevation: 0,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: () => _showNoticeMessage(context),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'SİPARİŞİ TAMAMLA (${CurrencyFormatter.format(subtotal)})',
                style: AppTextStyles.buttonText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
