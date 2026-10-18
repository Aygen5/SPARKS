import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sparks/app/theme/app_colors.dart';
import 'package:sparks/app/theme/app_spacing.dart';
import 'package:sparks/app/theme/app_text_styles.dart';
import 'package:sparks/core/utils/currency_formatter.dart';
import 'package:sparks/features/catalog/data/datasources/product_local_data_source.dart';
import 'package:sparks/features/catalog/data/repositories/product_repository_impl.dart';
import 'package:sparks/features/catalog/domain/entities/product.dart';
import 'package:sparks/features/catalog/domain/repositories/product_repository.dart';
import 'package:sparks/features/favorites/presentation/manager/favorites_manager.dart';

/// SPARKS Gerçek Favoriler Ekranı (FavoritesScreen).
///
/// Özellikler:
/// - Merkezi `FavoritesManager` dinleyicisi ile favori listesini anlık senkronize eder.
/// - Favori ürün kimliklerine karşılık gelen ürün verilerini `ProductRepository` üzerinden asenkron yükler.
/// - Başka ekranda (katalog, arama, detay) favori durumu değiştiğinde anında güncellenir.
/// - Bu ekranda kalp ikonuna basıldığında ürün listeden gecikmeden çıkarılır.
/// - Boş durum tasarımı ve kataloğa yönlendirme (`KATALOĞA DÖN`).
/// - Yüklenme, hata ve tekrar deneme durumları.
/// - Ürüne dokunulduğunda gerçek `/product/:id` rotasına yönlendirme.
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({
    super.key,
    this.favoritesManager,
    this.productRepository,
    this.onProductTap,
    this.onCatalogNavigate,
  });

  /// Test edilebilirlik için dışarıdan enjekte edilebilen FavoritesManager
  final FavoritesManager? favoritesManager;

  /// Test edilebilirlik için dışarıdan enjekte edilebilen ProductRepository
  final ProductRepository? productRepository;

  /// Ürüne dokunulduğunda çalışacak geri çağrım (opsiyonel)
  final void Function(Product product)? onProductTap;

  /// Boş favori ekranından kataloğa dönüş aksiyonu (opsiyonel)
  final VoidCallback? onCatalogNavigate;

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late final FavoritesManager _favoritesManager;
  late final ProductRepository _productRepository;

  bool _isLoading = true;
  String? _errorMessage;
  List<Product> _favoriteProducts = [];

  @override
  void initState() {
    super.initState();
    _favoritesManager = widget.favoritesManager ?? FavoritesManager.instance;
    _productRepository =
        widget.productRepository ??
        ProductRepositoryImpl(
          localDataSource: const ProductLocalDataSourceImpl(),
        );

    _favoritesManager.addListener(_onFavoritesChanged);
    _loadFavoriteProducts();
  }

  @override
  void dispose() {
    _favoritesManager.removeListener(_onFavoritesChanged);
    super.dispose();
  }

  /// Merkezi yöneticide favori durumu değiştiğinde çalışır
  Future<void> _onFavoritesChanged() async {
    final currentIds = _favoritesManager.favoriteIds;

    // Listeden çıkarılan ürünleri anında UI'dan filtrele
    final filtered =
        _favoriteProducts.where((p) => currentIds.contains(p.id)).toList();

    // Yeni eklenen kimlikler varsa onları da yükle
    final existingIds = filtered.map((p) => p.id).toSet();
    final newIds = currentIds.difference(existingIds);

    if (newIds.isEmpty) {
      if (mounted) {
        setState(() {
          _favoriteProducts = filtered;
        });
      }
      return;
    }

    // Yeni ürünleri asenkron olarak tamamla
    for (final id in newIds) {
      try {
        final product = await _productRepository.getProductById(id);
        if (product != null && !existingIds.contains(product.id)) {
          filtered.add(product);
          existingIds.add(product.id);
        }
      } catch (_) {}
    }

    if (mounted) {
      setState(() {
        _favoriteProducts = filtered;
      });
    }
  }

  /// Başlangıçta kayıtlı tüm favori ürünleri repository üzerinden çeker
  Future<void> _loadFavoriteProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final favoriteIds = _favoritesManager.favoriteIds;
      if (favoriteIds.isEmpty) {
        if (mounted) {
          setState(() {
            _favoriteProducts = [];
            _isLoading = false;
          });
        }
        return;
      }

      final products = <Product>[];
      for (final id in favoriteIds) {
        final product = await _productRepository.getProductById(id);
        if (product != null) {
          products.add(product);
        }
      }

      if (mounted) {
        setState(() {
          _favoriteProducts = products;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage =
              'Favoriler yüklenirken bir sorun oluştu. Lütfen tekrar deneyin.';
          _isLoading = false;
        });
      }
    }
  }

  void _handleProductTap(Product product) {
    if (widget.onProductTap != null) {
      widget.onProductTap!(product);
    } else {
      context.push('/product/${product.id}');
    }
  }

  void _navigateToCatalog() {
    if (widget.onCatalogNavigate != null) {
      widget.onCatalogNavigate!();
    } else {
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/menu');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.shoppingBackground,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: _buildBody(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final canPop = Navigator.of(context).canPop();

    return AppBar(
      backgroundColor: AppColors.shoppingBackground,
      elevation: 0,
      centerTitle: true,
      leading: canPop
          ? IconButton(
              key: const ValueKey('favorites_back_button'),
              icon: const Icon(Icons.arrow_back, color: AppColors.primaryText),
              onPressed: () => context.pop(),
            )
          : null,
      title: Text(
        'FAVORİLER',
        style: AppTextStyles.brandLogoMedium.copyWith(fontSize: 18),
      ),
      actions: [
        if (!_isLoading && _favoriteProducts.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.screenHorizontal),
            child: Center(
              child: Text(
                '${_favoriteProducts.length} ÜRÜN',
                key: const ValueKey('favorites_count_badge'),
                style: AppTextStyles.caption.copyWith(
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondaryText,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryText),
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.secondaryText,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              OutlinedButton(
                key: const ValueKey('favorites_retry_button'),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primaryText),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                onPressed: _loadFavoriteProducts,
                child: Text(
                  'TEKRAR DENE',
                  style: AppTextStyles.buttonTextOutlined,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_favoriteProducts.isEmpty) {
      return _buildEmptyFavorites();
    }

    return GridView.builder(
      key: const ValueKey('favorites_grid'),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
        vertical: AppSpacing.md,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 24,
        childAspectRatio: 0.58,
      ),
      itemCount: _favoriteProducts.length,
      itemBuilder: (context, index) {
        final product = _favoriteProducts[index];
        return _buildProductCard(product);
      },
    );
  }

  Widget _buildProductCard(Product product) {
    return InkWell(
      key: ValueKey('favorite_product_card_${product.id}'),
      onTap: () => _handleProductTap(product),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ürün Görseli ve Kalp İkonu Katmanı
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    color: AppColors.editorialAnthracite,
                    width: double.infinity,
                    child: Image.network(
                      product.images.first,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return const Center(
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 1.5,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primaryText,
                              ),
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: AppColors.editorialAnthracite,
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.broken_image_outlined,
                          color: AppColors.secondaryText,
                        ),
                      ),
                    ),
                  ),
                ),

                // Favoriden Çıkarma Kalp Butonu (Sağ Üst)
                Positioned(
                  top: 4,
                  right: 4,
                  child: Material(
                    color: Colors.transparent,
                    child: IconButton(
                      key: ValueKey('favorites_remove_${product.id}'),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                      iconSize: 20,
                      icon: const Icon(
                        Icons.favorite,
                        color: AppColors.error,
                      ),
                      tooltip: 'Favorilerden Çıkar',
                      onPressed: () =>
                          _favoritesManager.removeFavorite(product.id),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xs),

          // Ürün Başlığı
          Text(
            product.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.productTitle.copyWith(
              letterSpacing: 1.0,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),

          // Renk ve Referans Kodu
          Text(
            product.colorAndCode,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption.copyWith(
              fontSize: 10,
              color: AppColors.secondaryText,
            ),
          ),
          const SizedBox(height: 2),

          // Fiyat ve Varsa İndirim Etiketi
          Wrap(
            spacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                CurrencyFormatter.format(product.price),
                style: AppTextStyles.productPrice.copyWith(
                  fontSize: 11,
                  color: product.isDiscounted
                      ? AppColors.primaryText
                      : AppColors.secondaryText,
                  fontWeight: product.isDiscounted
                      ? FontWeight.w700
                      : FontWeight.w500,
                ),
              ),
              if (product.discountText != null)
                Text(
                  product.discountText!,
                  style: AppTextStyles.discountTag.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyFavorites() {
    return Center(
      key: const ValueKey('favorites_empty_state'),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenHorizontal,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.favorite_border,
              size: 48,
              color: AppColors.secondaryText,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'FAVORİ LİSTENİZ BOŞ',
              style: AppTextStyles.sectionHeading.copyWith(
                fontSize: 18,
                letterSpacing: 3.0,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Henüz favorilerinize bir ürün eklemediniz. Beğendiğiniz ürünleri kalp ikonuna dokunarak buraya kaydedebilirsiniz.',
              textAlign: TextAlign.center,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.secondaryText,
                height: 1.5,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            OutlinedButton(
              key: const ValueKey('favorites_empty_catalog_button'),
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
}
