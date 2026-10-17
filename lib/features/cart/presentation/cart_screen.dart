import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sparks/app/theme/app_colors.dart';
import 'package:sparks/app/theme/app_spacing.dart';
import 'package:sparks/app/theme/app_text_styles.dart';
import 'package:sparks/core/constants/app_constants.dart';
import 'package:sparks/core/utils/currency_formatter.dart';
import 'package:sparks/features/cart/domain/entities/cart_item_view.dart';
import 'package:sparks/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:sparks/features/cart/presentation/cubit/cart_state.dart';

/// SPARKS Gerçek Alışveriş Sepeti Ekranı (CartScreen).
///
/// Özellikler:
/// - `CartCubit` ile tek merkezden yönetilen reaktif durum.
/// - Sepetteki ürünlerin gerçek fotoğrafları, başlıkları ve güncel fiyatları.
/// - Adet azaltma (-) ve artırma (+) kontrolleri (minimum adet 1'dir).
/// - Ürünü sepetten tamamen kaldırma (SİL butonu).
/// - Boş sepet durumu ve "KATALOĞA DÖN" yönlendirmesi.
/// - Dinamik genel toplam ve toplam adet göstergesi.
/// - Monokrom ve keskin köşeli editoryal tasarım.
class CartScreen extends StatefulWidget {
  const CartScreen({super.key, this.cartCubit, this.onCatalogNavigate});

  /// Test edilebilirlik için dışarıdan enjekte edilebilen CartCubit örneği
  final CartCubit? cartCubit;

  /// Boş sepet durumunda kataloğa gitme eylemi için özel geri çağrım
  final VoidCallback? onCatalogNavigate;

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  CartCubit _resolveCubit(BuildContext context) {
    if (widget.cartCubit != null) return widget.cartCubit!;
    try {
      return context.read<CartCubit>();
    } catch (_) {
      return CartCubit.instance;
    }
  }

  void _navigateToCatalog() {
    if (widget.onCatalogNavigate != null) {
      widget.onCatalogNavigate!();
    } else {
      context.go('/catalog');
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = _resolveCubit(context);

    return Scaffold(
      backgroundColor: AppColors.shoppingBackground,
      appBar: _buildAppBar(cubit),
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
              return _buildEmptyCart();
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
                  return _buildEmptyCart();
                }

                return Column(
                  children: [
                    // Sepet Ürünleri Listesi
                    Expanded(
                      child: ListView.separated(
                        key: const ValueKey('cart_items_list'),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.screenHorizontal,
                          vertical: AppSpacing.md,
                        ),
                        itemCount: views.length,
                        separatorBuilder: (context, index) =>
                            const Divider(color: AppColors.divider, height: 32),
                        itemBuilder: (context, index) {
                          final item = views[index];
                          return _buildCartItemTile(cubit, item);
                        },
                      ),
                    ),

                    // Sabit Alt Özet ve Sipariş Çubuğu
                    _buildCheckoutSummary(cubit, views, state),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(CartCubit cubit) {
    return AppBar(
      backgroundColor: AppColors.shoppingBackground,
      elevation: 0,
      centerTitle: true,
      title: Text(
        AppConstants.tabCart.toUpperCase(),
        style: AppTextStyles.brandLogoMedium.copyWith(fontSize: 20),
      ),
      actions: [
        BlocBuilder<CartCubit, CartState>(
          bloc: cubit,
          builder: (context, state) {
            if (state.isEmpty) return const SizedBox.shrink();
            return TextButton(
              key: const ValueKey('cart_clear_button'),
              onPressed: () => cubit.clearCart(),
              child: Text(
                'SEPETİ TEMİZLE',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.secondaryText,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      key: const ValueKey('cart_empty_state'),
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
              'SEPETİNİZ BOŞ',
              style: AppTextStyles.sectionHeading.copyWith(
                fontSize: 18,
                letterSpacing: 3.0,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Henüz sepetinize bir ürün eklemediniz. En yeni koleksiyon parçalarını keşfetmek için kataloğumuza göz atın.',
              textAlign: TextAlign.center,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.secondaryText,
                height: 1.5,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            OutlinedButton(
              key: const ValueKey('cart_empty_catalog_button'),
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
              onPressed: _navigateToCatalog,
              child: Text(
                'KATALOĞA DÖN',
                style: AppTextStyles.buttonTextOutlined,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItemTile(CartCubit cubit, CartItemView item) {
    final product = item.product;

    return Container(
      key: ValueKey('cart_item_card_${product.id}'),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Ürün Görseli (3:4 Editoryal Oran)
          SizedBox(
            width: 80,
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
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),

          // 2. Ürün Bilgileri ve Kontroller
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Başlık
                Text(
                  product.title,
                  style: AppTextStyles.productTitle.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),

                // Renk ve Ürün Kodu
                Text(
                  product.colorAndCode,
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 10,
                    color: AppColors.secondaryText,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),

                // Birim Fiyat
                Text(
                  CurrencyFormatter.format(product.price),
                  style: AppTextStyles.productPrice.copyWith(fontSize: 13),
                ),
                const SizedBox(height: AppSpacing.sm),

                // Adet Kontrolleri ve Silme Aksiyonu
                Row(
                  children: [
                    // Adet Azalt (-)
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.dividerLight),
                      ),
                      child: IconButton(
                        key: ValueKey('cart_qty_decrease_${product.id}'),
                        padding: EdgeInsets.zero,
                        icon: const Icon(
                          Icons.remove,
                          size: 14,
                          color: AppColors.primaryText,
                        ),
                        onPressed: () => cubit.decrementQuantity(product.id),
                      ),
                    ),

                    // Mevcut Adet
                    Container(
                      width: 40,
                      height: 32,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(color: AppColors.dividerLight),
                          bottom: BorderSide(color: AppColors.dividerLight),
                        ),
                      ),
                      child: Text(
                        '${item.quantity}',
                        key: ValueKey('cart_qty_value_${product.id}'),
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),

                    // Adet Artır (+)
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.dividerLight),
                      ),
                      child: IconButton(
                        key: ValueKey('cart_qty_increase_${product.id}'),
                        padding: EdgeInsets.zero,
                        icon: const Icon(
                          Icons.add,
                          size: 14,
                          color: AppColors.primaryText,
                        ),
                        onPressed: () => cubit.incrementQuantity(product.id),
                      ),
                    ),

                    const Spacer(),

                    // Ürünü Kaldır
                    IconButton(
                      key: ValueKey('cart_item_delete_${product.id}'),
                      icon: const Icon(
                        Icons.delete_outline,
                        size: 18,
                        color: AppColors.secondaryText,
                      ),
                      tooltip: 'Sepetten Kaldır',
                      onPressed: () => cubit.removeProduct(product.id),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutSummary(
    CartCubit cubit,
    List<CartItemView> views,
    CartState state,
  ) {
    final totalPrice = views.fold<double>(
      0.0,
      (sum, item) => sum + item.totalPrice,
    );

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.shoppingBackground,
        border: Border(top: BorderSide(color: AppColors.divider, width: 1)),
      ),
      padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Toplam Ürün Adedi
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TOPLAM ÜRÜN:',
                style: AppTextStyles.caption.copyWith(
                  letterSpacing: 1.5,
                  color: AppColors.secondaryText,
                ),
              ),
              Text(
                '${state.totalItemCount} ADET',
                key: const ValueKey('cart_total_items'),
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),

          // Genel Toplam Fiyat
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'GENEL TOPLAM:',
                style: AppTextStyles.menuItem.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Flexible(
                child: Text(
                  CurrencyFormatter.format(totalPrice),
                  key: const ValueKey('cart_total_price'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.productPrice.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Satın Alma Aksiyon Butonu (Aşama 10 için editoryal bilgilendirme)
          ElevatedButton(
            key: const ValueKey('cart_checkout_button'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryText,
              foregroundColor: AppColors.shoppingBackground,
              elevation: 0,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Sipariş tamamlama akışı Aşama 10\'da eklenecektir.',
                  ),
                  duration: Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Text(
              'DEVAM ET (${state.totalItemCount})',
              style: AppTextStyles.buttonText,
            ),
          ),
        ],
      ),
    );
  }
}
