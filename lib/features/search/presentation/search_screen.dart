import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sparks/app/theme/app_colors.dart';
import 'package:sparks/app/theme/app_spacing.dart';
import 'package:sparks/app/theme/app_text_styles.dart';
import 'package:sparks/core/constants/app_constants.dart';
import 'package:sparks/core/utils/currency_formatter.dart';
import 'package:sparks/features/catalog/data/datasources/product_local_data_source.dart';
import 'package:sparks/features/catalog/data/repositories/product_repository_impl.dart';
import 'package:sparks/features/catalog/domain/entities/product.dart';
import 'package:sparks/features/catalog/domain/repositories/product_repository.dart';
import 'package:sparks/core/widgets/sparks_image.dart';
import 'package:sparks/features/favorites/presentation/manager/favorites_manager.dart';

/// SPARKS Gerçek Zamanlı Arama ve Keşif Ekranı (SearchScreen).
///
/// Özellikler:
/// - KADIN ve ERKEK reyon sekmeleri.
/// - Çerçevesiz, ince alt çizgili minimalist arama girdisi (`NE ARIYORSUNUZ?`).
/// - Kullanıcı yazdıkça başlık, kategori, renk/kod ve açıklamada anlık arama.
/// - Arama boşken repository'den seçilmiş önerilen ürünler (`İLGİNİZİ ÇEKEBİLECEK DİĞER ÜRÜNLER`).
/// - Arama sonuçları bulunamadığında editoryal boş sonuç mesajı.
/// - Ürün tıklandığında `/product/:id` geçiş noktasına yönlendirme.
class SearchScreen extends StatefulWidget {
  const SearchScreen({
    super.key,
    this.repository,
    this.favoritesManager,
    this.onProductTap,
    this.initialGender = AppConstants.genderWomen,
  });

  /// Test edilebilirlik için enjekte edilebilen repository örneği
  final ProductRepository? repository;

  /// Test edilebilirlik için dışarıdan enjekte edilebilen FavoritesManager örneği
  final FavoritesManager? favoritesManager;

  /// Ürüne dokunulduğunda çalışacak geri çağrım
  final void Function(Product product)? onProductTap;

  /// Başlangıçta seçili cinsiyet reyonu
  final String initialGender;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late final ProductRepository _repository;
  late final FavoritesManager _favoritesManager;
  late final TextEditingController _searchController;
  late String _selectedGender;

  bool _isLoadingRecommendations = true;
  bool _isSearching = false;
  List<Product> _recommendations = [];
  List<Product> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _repository =
        widget.repository ??
        ProductRepositoryImpl(
          localDataSource: const ProductLocalDataSourceImpl(),
        );
    _favoritesManager = widget.favoritesManager ?? FavoritesManager.instance;
    _favoritesManager.addListener(_onFavoritesChanged);
    _selectedGender = widget.initialGender.trim().toUpperCase();
    _searchController = TextEditingController();
    _searchController.addListener(_onSearchInputChanged);
    _fetchRecommendations();
  }

  @override
  void dispose() {
    _favoritesManager.removeListener(_onFavoritesChanged);
    _searchController.removeListener(_onSearchInputChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onFavoritesChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _fetchRecommendations() async {
    setState(() {
      _isLoadingRecommendations = true;
    });

    try {
      final products = await _repository.getProducts(gender: _selectedGender);
      if (mounted) {
        setState(() {
          // Öneri olarak reyonun ilk 2 seçkin ürününü göster
          _recommendations = products.take(2).toList();
          _isLoadingRecommendations = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _recommendations = [];
          _isLoadingRecommendations = false;
        });
      }
    }
  }

  void _onSearchInputChanged() {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      if (_isSearching) {
        setState(() {
          _isSearching = false;
          _searchResults = [];
        });
      }
    } else {
      _performSearch(query);
    }
  }

  Future<void> _performSearch(String query) async {
    final results = await _repository.searchProducts(
      query,
      gender: _selectedGender,
    );
    if (mounted) {
      setState(() {
        _isSearching = true;
        _searchResults = results;
      });
    }
  }

  void _onGenderSelected(String gender) {
    if (_selectedGender != gender) {
      setState(() {
        _selectedGender = gender;
      });
      _fetchRecommendations();
      if (_searchController.text.trim().isNotEmpty) {
        _performSearch(_searchController.text.trim());
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.shoppingBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Üst Reyon Sekmeleri (KADIN / ERKEK)
            _buildGenderHeader(),

            const SizedBox(height: AppSpacing.sm),

            // 2. Minimalist Alt Çizgili Arama Girdisi
            _buildSearchInputField(),

            const SizedBox(height: AppSpacing.md),

            // 3. Gövde: Arama Sonuçları veya Önerilen Ürünler
            Expanded(child: _buildSearchBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        children: [
          _GenderTabButton(
            key: const ValueKey('search_tab_KADIN'),
            title: AppConstants.genderWomen,
            isSelected: _selectedGender == AppConstants.genderWomen,
            onTap: () => _onGenderSelected(AppConstants.genderWomen),
          ),
          const SizedBox(width: AppSpacing.xl),
          _GenderTabButton(
            key: const ValueKey('search_tab_ERKEK'),
            title: AppConstants.genderMen,
            isSelected: _selectedGender == AppConstants.genderMen,
            onTap: () => _onGenderSelected(AppConstants.genderMen),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchInputField() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
      ),
      child: TextField(
        key: const ValueKey('search_input_field'),
        controller: _searchController,
        style: AppTextStyles.body.copyWith(color: AppColors.primaryText),
        cursorColor: AppColors.primaryText,
        decoration: InputDecoration(
          hintText: 'NE ARIYORSUNUZ?',
          hintStyle: AppTextStyles.searchPlaceholder,
          prefixIcon: const Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.search, size: 20, color: AppColors.secondaryText),
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 24,
            minHeight: 24,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  key: const ValueKey('search_clear_button'),
                  icon: const Icon(
                    Icons.clear,
                    size: 18,
                    color: AppColors.secondaryText,
                  ),
                  onPressed: () {
                    _searchController.clear();
                  },
                )
              : null,
          filled: false,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.divider, width: 1.0),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.primaryText, width: 1.0),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBody() {
    // 1. Durum: Kullanıcı bir arama metni girdi
    if (_isSearching) {
      if (_searchResults.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'EŞLEŞEN ÜRÜN BULUNAMADI',
                  key: const ValueKey('search_empty_text'),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.sectionHeading.copyWith(
                    fontSize: 16,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Farklı bir arama terimi deneyebilir veya kategorilere göz atabilirsiniz.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return _buildProductGrid(
        key: const ValueKey('search_results_grid'),
        products: _searchResults,
      );
    }

    // 2. Durum: Arama kutusu boşken önerilen ürünler gösterilir
    if (_isLoadingRecommendations) {
      return const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryText),
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
        vertical: AppSpacing.md,
      ),
      children: [
        Text(
          'İLGİNİZİ ÇEKEBİLECEK DİĞER ÜRÜNLER',
          style: AppTextStyles.sectionHeading.copyWith(
            fontSize: 14,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        if (_recommendations.isNotEmpty)
          _buildProductGrid(
            key: const ValueKey('search_recommendations_grid'),
            products: _recommendations,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
          )
        else
          Text(
            'Bu reyon için önerilen ürün bulunamadı.',
            style: AppTextStyles.caption,
          ),
      ],
    );
  }

  Widget _buildProductGrid({
    required Key key,
    required List<Product> products,
    bool shrinkWrap = false,
    ScrollPhysics? physics,
  }) {
    return GridView.builder(
      key: key,
      shrinkWrap: shrinkWrap,
      physics: physics,
      padding: shrinkWrap
          ? EdgeInsets.zero
          : const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenHorizontal,
              vertical: AppSpacing.sm,
            ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 24,
        childAspectRatio: 0.58,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return InkWell(
          key: ValueKey('search_product_card_${product.id}'),
          onTap: () => _handleProductTap(product),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: SparksImage(
                        imageUrl: product.images.first,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Material(
                        color: Colors.transparent,
                        child: IconButton(
                          key: ValueKey('search_favorite_${product.id}'),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                          iconSize: 20,
                          icon: Icon(
                            _favoritesManager.isFavorite(product.id)
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: _favoritesManager.isFavorite(product.id)
                                ? AppColors.error
                                : AppColors.primaryText,
                          ),
                          onPressed: () =>
                              _favoritesManager.toggleFavorite(product.id),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
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
              Wrap(
                spacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    CurrencyFormatter.format(product.price),
                    style: AppTextStyles.productPrice.copyWith(
                      fontSize: 11,
                      color: AppColors.secondaryText,
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
      },
    );
  }
}

class _GenderTabButton extends StatelessWidget {
  const _GenderTabButton({
    super.key,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTextStyles.sectionHeading.copyWith(
                fontSize: 18,
                color: isSelected
                    ? AppColors.primaryText
                    : AppColors.secondaryText,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              height: 2.0,
              width: 28.0,
              color: isSelected ? AppColors.primaryText : Colors.transparent,
            ),
          ],
        ),
      ),
    );
  }
}
