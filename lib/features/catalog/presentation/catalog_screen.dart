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

/// SPARKS Ürün Kataloğu Ekranı (CatalogScreen).
///
/// Özellikler:
/// - Repository üzerinden asenkron ürün çekme, yüklenme, hata ve boş durum yönetimi.
/// - Üst kontrol barı: Geri dönüş, bağlam başlığı, `GÖRÜNÜM 1/2/3` döngüsü, filtre aç/kapa.
/// - Yatay kategori şeridi (`TÜMÜNÜ GÖR`, `SUNİ KÜRK`, `BOMBER`, `TEKNİK ŞİŞME` vb.).
/// - Beden filtresi (`XS`, `S`, `M`, `L`, `XL`), gerçek `Product.sizes` verisine bağlı.
/// - Üç farklı editoryal ürün görünüm modu:
///   - Görünüm 1: Tek sütun büyük editoryal kartlar.
///   - Görünüm 2: Yan yana 2 sütunlu dengeli ızgara.
///   - Görünüm 3: 3 sütunlu yoğun katalog (ürün isimleri gizlenir, görseller ön plandadır).
class CatalogScreen extends StatefulWidget {
  const CatalogScreen({
    super.key,
    this.gender = AppConstants.genderWomen,
    this.category = '',
    this.repository,
    this.favoritesManager,
    this.onProductTap,
    this.initialViewMode = 2,
  });

  /// Seçili cinsiyet hedefi ("KADIN" veya "ERKEK")
  final String gender;

  /// Menüden gelen kategori adı (Örn: "CEKET", "KABAN | MONT" veya boş)
  final String category;

  /// Test edilebilirlik için dışarıdan enjekte edilebilen repository örneği
  final ProductRepository? repository;

  /// Test edilebilirlik için dışarıdan enjekte edilebilen FavoritesManager örneği
  final FavoritesManager? favoritesManager;

  /// Ürüne dokunulduğunda çalışacak geri çağrım (Test veya özel yönlendirmeler için)
  final void Function(Product product)? onProductTap;

  /// Başlangıç görünüm modu (1: Tek sütun, 2: İki sütun, 3: Üç sütun)
  final int initialViewMode;

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  late final ProductRepository _repository;
  late String _selectedGender;
  String? _selectedCategory;
  String? _selectedSize;
  late int _viewMode;
  bool _showFilters = false;

  bool _isLoading = true;
  String? _errorMessage;
  List<Product> _allGenderProducts = [];

  late final FavoritesManager _favoritesManager;

  // Sabit editoryal yatay kategori etiketleri
  static const List<String> _basePills = [
    'TÜMÜNÜ GÖR',
    'SUNİ KÜRK',
    'BOMBER',
    'TEKNİK ŞİŞME',
  ];

  // Desteklenen beden seçenekleri
  static const List<String> _sizeOptions = ['XS', 'S', 'M', 'L', 'XL'];

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
    _selectedGender = widget.gender.trim().toUpperCase();
    _selectedCategory = widget.category.trim().isNotEmpty
        ? widget.category.trim()
        : null;
    _viewMode = widget.initialViewMode;
    _fetchProducts();
  }

  @override
  void dispose() {
    _favoritesManager.removeListener(_onFavoritesChanged);
    super.dispose();
  }

  void _onFavoritesChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _fetchProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final products = await _repository.getProducts(gender: _selectedGender);
      if (mounted) {
        setState(() {
          _allGenderProducts = products;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage =
              'Katalog yüklenirken bir sorun oluştu. Lütfen tekrar deneyin.';
          _isLoading = false;
        });
      }
    }
  }

  /// Aktif filtrelere (kategori ve beden) göre ürünleri filtreler
  List<Product> get _filteredProducts {
    return _allGenderProducts.where((product) {
      // 1. Kategori filtresi
      if (_selectedCategory != null &&
          _selectedCategory != 'TÜMÜNÜ GÖR' &&
          _selectedCategory!.isNotEmpty) {
        final catUpper = _selectedCategory!.toUpperCase();
        final prodCatUpper = product.category.toUpperCase();
        final prodTitleUpper = product.title.toUpperCase();
        final prodDescUpper = product.description.toUpperCase();

        final matchesCategory =
            prodCatUpper == catUpper ||
            prodCatUpper.contains(catUpper) ||
            prodTitleUpper.contains(catUpper) ||
            prodDescUpper.contains(catUpper);

        if (!matchesCategory) return false;
      }

      // 2. Beden filtresi (gerçek Product.sizes listesi ile doğrulanır)
      if (_selectedSize != null) {
        if (!product.sizes.contains(_selectedSize)) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  /// Dinamik yatay kategori butonları listesi
  List<String> get _categoryPills {
    final pills = <String>['TÜMÜNÜ GÖR'];
    if (widget.category.trim().isNotEmpty &&
        !_basePills.contains(widget.category.trim().toUpperCase())) {
      pills.add(widget.category.trim());
    }
    pills.addAll(['SUNİ KÜRK', 'BOMBER', 'TEKNİK ŞİŞME']);
    return pills;
  }

  void _cycleViewMode() {
    setState(() {
      _viewMode = _viewMode == 3 ? 1 : _viewMode + 1;
    });
  }

  void _onCategoryPillSelected(String pill) {
    setState(() {
      if (pill == 'TÜMÜNÜ GÖR') {
        _selectedCategory = null;
      } else {
        _selectedCategory = pill;
      }
    });
  }

  void _onSizeSelected(String size) {
    setState(() {
      if (_selectedSize == size) {
        _selectedSize = null; // Seçimi kaldır
      } else {
        _selectedSize = size;
      }
    });
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
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Üst Kontrol Barı (Görünüm modu, filtreler, mağaza)
            _buildControlsBar(),

            const Divider(color: AppColors.divider, height: 1),

            // Yatay Kategori Şeridi
            _buildCategoryPills(),

            // Beden Filtresi (Filtreler tıklandığında açılır)
            if (_showFilters) ...[
              _buildSizeFilterBar(),
              const Divider(color: AppColors.divider, height: 1),
            ],

            // Gövde Alanı: Yüklenme / Hata / Boş / Ürün Listesi
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    final categoryText = _selectedCategory ?? 'TÜMÜ';
    return AppBar(
      backgroundColor: AppColors.shoppingBackground,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        key: const ValueKey('catalog_back_button'),
        icon: const Icon(Icons.arrow_back, color: AppColors.primaryText),
        onPressed: () => context.pop(),
      ),
      title: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(AppConstants.appName, style: AppTextStyles.brandLogoMedium),
          const SizedBox(height: 2),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _selectedGender,
                style: AppTextStyles.caption.copyWith(
                  fontSize: 10,
                  letterSpacing: 2.0,
                  color: AppColors.secondaryText,
                ),
              ),
              Text(
                ' / ',
                style: AppTextStyles.caption.copyWith(
                  fontSize: 10,
                  color: AppColors.secondaryText,
                ),
              ),
              Text(
                categoryText,
                style: AppTextStyles.caption.copyWith(
                  fontSize: 10,
                  letterSpacing: 2.0,
                  color: AppColors.secondaryText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlsBar() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
        vertical: AppSpacing.xs,
      ),
      color: AppColors.shoppingBackground,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Görünüm Modu Değiştirici Buton (1 -> 2 -> 3 -> 1)
          InkWell(
            key: const ValueKey('catalog_view_mode_button'),
            onTap: _cycleViewMode,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.grid_view,
                    size: 13,
                    color: AppColors.secondaryText,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'GÖRÜNÜM $_viewMode',
                    key: const ValueKey('catalog_view_mode_text'),
                    style: AppTextStyles.caption.copyWith(
                      letterSpacing: 1.0,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryText,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Filtreler Butonu
          InkWell(
            key: const ValueKey('catalog_filter_button'),
            onTap: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _showFilters ? Icons.filter_list_off : Icons.tune,
                    size: 13,
                    color: _selectedSize != null
                        ? AppColors.primaryText
                        : AppColors.secondaryText,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _selectedSize != null ? 'FİLTRE [1]' : 'FİLTRELER',
                    style: AppTextStyles.caption.copyWith(
                      letterSpacing: 1.0,
                      fontSize: 10,
                      color: _selectedSize != null
                          ? AppColors.primaryText
                          : AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Mağaza Butonu (Tasarım göstergesi)
          InkWell(
            key: const ValueKey('catalog_store_button'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Mağaza stoğu sorgulama özelliği yakında eklenecektir.',
                  ),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                'MAĞAZA',
                style: AppTextStyles.caption.copyWith(
                  letterSpacing: 1.0,
                  fontSize: 10,
                  color: AppColors.secondaryText,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryPills() {
    final pills = _categoryPills;

    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenHorizontal,
        ),
        itemCount: pills.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final pill = pills[index];
          final isSelected =
              (_selectedCategory == null && pill == 'TÜMÜNÜ GÖR') ||
              (_selectedCategory != null &&
                  _selectedCategory!.toUpperCase() == pill.toUpperCase());

          return InkWell(
            key: ValueKey('category_pill_$pill'),
            onTap: () => _onCategoryPillSelected(pill),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryText : Colors.transparent,
                border: Border.all(
                  color: isSelected ? AppColors.primaryText : AppColors.divider,
                  width: 1,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                pill,
                style: AppTextStyles.caption.copyWith(
                  fontSize: 11,
                  letterSpacing: 1.2,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                  color: isSelected
                      ? AppColors.shoppingBackground
                      : AppColors.secondaryText,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSizeFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
        vertical: AppSpacing.sm,
      ),
      color: const Color(0x33222222),
      child: Row(
        children: [
          Text(
            'BEDEN:',
            style: AppTextStyles.caption.copyWith(
              letterSpacing: 1.5,
              fontWeight: FontWeight.w600,
              color: AppColors.secondaryText,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: SizedBox(
              height: 32,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _sizeOptions.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final size = _sizeOptions[index];
                  final isSelected = _selectedSize == size;

                  return InkWell(
                    key: ValueKey('size_pill_$size'),
                    onTap: () => _onSizeSelected(size),
                    child: Container(
                      width: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryText
                            : Colors.transparent,
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primaryText
                              : AppColors.divider,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        size,
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 11,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w400,
                          color: isSelected
                              ? AppColors.shoppingBackground
                              : AppColors.primaryText,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          if (_selectedSize != null)
            TextButton(
              onPressed: () => setState(() => _selectedSize = null),
              child: Text(
                'TEMİZLE',
                style: AppTextStyles.caption.copyWith(
                  fontSize: 10,
                  color: AppColors.secondaryText,
                ),
              ),
            ),
        ],
      ),
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
                key: const ValueKey('catalog_retry_button'),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primaryText),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                ),
                onPressed: _fetchProducts,
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

    final products = _filteredProducts;

    if (products.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'BU KATEGORİDE ÜRÜN BULUNAMADI',
                textAlign: TextAlign.center,
                style: AppTextStyles.sectionHeading.copyWith(
                  fontSize: 16,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Seçtiğiniz filtrelere uygun ürün bulunamadı. Filtreleri temizleyerek diğer ürünleri inceleyebilirsiniz.',
                textAlign: TextAlign.center,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.secondaryText,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              OutlinedButton(
                key: const ValueKey('catalog_clear_filters_button'),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primaryText),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                ),
                onPressed: () {
                  setState(() {
                    _selectedCategory = null;
                    _selectedSize = null;
                  });
                },
                child: Text(
                  'FİLTRELERİ TEMİZLE',
                  style: AppTextStyles.buttonTextOutlined,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Görünüm Moduna Göre Liste / Izgara Render
    switch (_viewMode) {
      case 1:
        return _buildMode1LargeEditorial(products);
      case 3:
        return _buildMode3DenseCatalog(products);
      case 2:
      default:
        return _buildMode2TwoColumnGrid(products);
    }
  }

  Widget _buildFavoriteButton(Product product, {bool mini = false}) {
    final isFav = _favoritesManager.isFavorite(product.id);
    return Material(
      color: Colors.transparent,
      child: IconButton(
        key: ValueKey('catalog_favorite_${product.id}'),
        padding: EdgeInsets.zero,
        constraints: mini
            ? const BoxConstraints(minWidth: 24, minHeight: 24)
            : const BoxConstraints(minWidth: 32, minHeight: 32),
        iconSize: mini ? 16 : 20,
        icon: Icon(
          isFav ? Icons.favorite : Icons.favorite_border,
          color: isFav ? AppColors.error : AppColors.primaryText,
        ),
        onPressed: () => _favoritesManager.toggleFavorite(product.id),
      ),
    );
  }

  /// Görünüm 1: Büyük Editoryal Tek Sütun
  Widget _buildMode1LargeEditorial(List<Product> products) {
    return ListView.separated(
      key: const ValueKey('catalog_list_mode_1'),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
        vertical: AppSpacing.md,
      ),
      itemCount: products.length,
      separatorBuilder: (context, index) => const SizedBox(height: 32),
      itemBuilder: (context, index) {
        final product = products[index];
        return InkWell(
          key: ValueKey('product_card_${product.id}'),
          onTap: () => _handleProductTap(product),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Büyük Editoryal Görsel
              AspectRatio(
                aspectRatio: 3 / 4,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: SparksImage(
                        imageUrl: product.images.first,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: _buildFavoriteButton(product),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

              // Ürün Başlığı
              Text(
                product.title,
                style: AppTextStyles.productTitle.copyWith(
                  letterSpacing: 1.5,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),

              // Fiyat ve İndirim
              Row(
                children: [
                  Text(
                    CurrencyFormatter.format(product.price),
                    style: AppTextStyles.productPrice.copyWith(
                      color: product.isDiscounted
                          ? AppColors.primaryText
                          : AppColors.secondaryText,
                      fontWeight: product.isDiscounted
                          ? FontWeight.w700
                          : FontWeight.w400,
                    ),
                  ),
                  if (product.isDiscounted && product.oldPrice != null) ...[
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      CurrencyFormatter.format(product.oldPrice!),
                      style: AppTextStyles.productOldPrice,
                    ),
                  ],
                  if (product.discountText != null) ...[
                    const SizedBox(width: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
                      color: AppColors.primaryText,
                      child: Text(
                        product.discountText!,
                        style: AppTextStyles.discountTag.copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.shoppingBackground,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  /// Görünüm 2: Yan Yana İki Sütunlu Izgara
  Widget _buildMode2TwoColumnGrid(List<Product> products) {
    return GridView.builder(
      key: const ValueKey('catalog_list_mode_2'),
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
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return InkWell(
          key: ValueKey('product_card_${product.id}'),
          onTap: () => _handleProductTap(product),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ürün Görseli
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
                      child: _buildFavoriteButton(product),
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

              // Fiyat & İndirim
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

  /// Görünüm 3: Üç Sütunlu Yoğun Katalog (İsimler gizlenir, sadece editoryal fotoğraflar)
  Widget _buildMode3DenseCatalog(List<Product> products) {
    return GridView.builder(
      key: const ValueKey('catalog_list_mode_3'),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
        vertical: AppSpacing.sm,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
        childAspectRatio: 0.65,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return InkWell(
          key: ValueKey('product_card_${product.id}'),
          onTap: () => _handleProductTap(product),
          child: Container(
            color: AppColors.editorialAnthracite,
            child: Stack(
              children: [
                Positioned.fill(
                  child: SparksImage(
                    imageUrl: product.images.first,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 2,
                  right: 2,
                  child: _buildFavoriteButton(product, mini: true),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
