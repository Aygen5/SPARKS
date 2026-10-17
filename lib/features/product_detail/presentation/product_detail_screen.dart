import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:sparks/features/favorites/presentation/manager/favorites_manager.dart';

/// SPARKS Ürün Detay Sayfası (ProductDetailScreen).
///
/// Özellikler:
/// - Repository üzerinden asenkron ürün çekme, yüklenme ve hata/bulunamadı durumları.
/// - Üst bar: Geri butonu (`Icons.arrow_back`), marka logosu ve favori kalp butonu.
/// - İki editoryal görselden oluşan sayfalama (`PageView`) ve "1/2" sayfa indikatörü.
/// - Ürün adı, cinsiyet/kategori etiketi, indirimli ve normal fiyat gösterimi.
/// - Renk ve ürün kodu bilgisi ile panoya kopyalama (`Clipboard`) ve SnackBar bildirimi.
/// - `AÇIKLAMA` ve `MALZEMELER` editoryal sekmeleri.
/// - Stok durumuna göre `TÜKENDİ` veya `SEPETE EKLE` aksiyon butonu.
class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({
    super.key,
    required this.productId,
    this.repository,
    this.favoritesManager,
    this.isFavoriteInitial = false,
    this.onFavoriteToggle,
  });

  /// Görüntülenecek ürünün benzersiz kimliği (Örn: "sparks-w-001")
  final String productId;

  /// Test edilebilirlik ve bağımsızlık için enjekte edilebilir ürün repository'si
  final ProductRepository? repository;

  /// Test edilebilirlik ve durum yönetimi için merkezi favori yöneticisi
  final FavoritesManager? favoritesManager;

  /// Başlangıç favori durumu (opsiyonel)
  final bool isFavoriteInitial;

  /// Favori durumu değiştiğinde tetiklenen geri çağrım (opsiyonel)
  final ValueChanged<bool>? onFavoriteToggle;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late final ProductRepository _repository;
  late final FavoritesManager _favoritesManager;
  Product? _product;
  bool _isLoading = true;
  String? _errorMessage;
  int _activeImageIndex = 0;
  int _selectedTab = 0; // 0: Açıklama, 1: Malzemeler

  bool get _isFavorite => _favoritesManager.isFavorite(widget.productId);

  @override
  void initState() {
    super.initState();
    _favoritesManager = widget.favoritesManager ?? FavoritesManager.instance;
    if (widget.isFavoriteInitial) {
      _favoritesManager.addFavorite(widget.productId);
    }
    _favoritesManager.addListener(_onFavoritesChanged);

    _repository =
        widget.repository ??
        ProductRepositoryImpl(
          localDataSource: const ProductLocalDataSourceImpl(),
        );
    _loadProduct();
  }

  @override
  void dispose() {
    _favoritesManager.removeListener(_onFavoritesChanged);
    super.dispose();
  }

  void _onFavoritesChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  /// Ürün detay verisini repository üzerinden asenkron yükler
  Future<void> _loadProduct() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final product = await _repository.getProductById(widget.productId);
      if (!mounted) return;

      setState(() {
        _product = product;
        _isLoading = false;
        if (product == null) {
          _errorMessage = 'Aradığınız ürün katalogda bulunamadı.';
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage =
            'Ürün yüklenirken bir sorun oluştu. Lütfen tekrar deneyin.';
      });
    }
  }

  /// Favori durumunu değiştirir
  Future<void> _toggleFavorite() async {
    final newState = await _favoritesManager.toggleFavorite(widget.productId);
    widget.onFavoriteToggle?.call(newState);
  }

  /// Renk ve referans kodunu panoya kopyalar ve kullanıcıyı SnackBar ile bilgilendirir
  Future<void> _copyColorAndCode() async {
    if (_product == null) return;
    try {
      await Clipboard.setData(ClipboardData(text: _product!.colorAndCode));
    } catch (_) {
      // Platform ve izin kısıtlarında hata yakalanır
    }
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Renk ve ürün kodu kopyalandı'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.shoppingBackground,
      appBar: _buildAppBar(),
      body: SafeArea(child: _buildBody()),
      bottomNavigationBar:
          _product != null && !_isLoading && _errorMessage == null
          ? _buildBottomActionBar()
          : null,
    );
  }

  /// Üst Editoryal Bar (Geri dönüş, SPARKS logosu ve Kalp ikonu)
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.shoppingBackground,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        key: const ValueKey('product_detail_back_button'),
        icon: const Icon(Icons.arrow_back, color: AppColors.primaryText),
        onPressed: () {
          if (Navigator.of(context).canPop()) {
            context.pop();
          } else {
            context.go('/catalog');
          }
        },
      ),
      title: Text(AppConstants.appName, style: AppTextStyles.brandLogoMedium),
      actions: [
        IconButton(
          key: const ValueKey('product_favorite_button'),
          icon: Icon(
            _isFavorite ? Icons.favorite : Icons.favorite_border,
            color: _isFavorite ? AppColors.primaryText : AppColors.primaryText,
          ),
          onPressed: _toggleFavorite,
        ),
      ],
    );
  }

  /// Ana Ekran Gövdesi: Yüklenme, Hata ve Ürün Detay Akışı
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(
            key: ValueKey('product_detail_loading'),
            strokeWidth: 1.5,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryText),
          ),
        ),
      );
    }

    if (_errorMessage != null || _product == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'ÜRÜN BULUNAMADI',
                style: AppTextStyles.sectionHeading.copyWith(
                  fontSize: 18,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                _errorMessage ?? 'Aradığınız ürün mevcut değil.',
                textAlign: TextAlign.center,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.secondaryText,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              OutlinedButton(
                key: const ValueKey('product_detail_retry_button'),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primaryText),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                ),
                onPressed: _loadProduct,
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

    final product = _product!;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. İki Editoryal Fotoğraftan Oluşan Sayfalanabilir Galeri
          _buildImageGallery(product),

          // 2. Ürün Bilgileri Bölümü (Kategori, Başlık, Fiyat, Kod)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenHorizontal,
              vertical: AppSpacing.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Reyon ve Kategori
                Text(
                  '${product.gender} · ${product.category}',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.secondaryText,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),

                // Ürün Başlığı
                Text(
                  product.title,
                  key: const ValueKey('product_detail_title'),
                  style: AppTextStyles.sectionHeading.copyWith(
                    fontSize: 20,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),

                // Fiyat Gösterimi (İndirimli veya Normal)
                _buildPriceSection(product),

                const SizedBox(height: AppSpacing.md),

                // Renk ve Referans Kodu + Kopyalama Butonu
                _buildColorAndCodeRow(product),

                const SizedBox(height: AppSpacing.md),
                const Divider(color: AppColors.divider, height: 1),
                const SizedBox(height: AppSpacing.md),

                // 3. Editoryal Sekmeler (AÇIKLAMA / MALZEMELER)
                _buildTabs(),

                const SizedBox(height: AppSpacing.md),

                // 4. Aktif Sekme İçeriği
                _buildTabContent(product),

                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// İki Editoryal Görseli ve "1/2" Sayfa İndikatörünü İçeren Galeri
  Widget _buildImageGallery(Product product) {
    return AspectRatio(
      aspectRatio: 3 / 4,
      child: Stack(
        children: [
          PageView.builder(
            itemCount: product.images.length,
            onPageChanged: (index) {
              setState(() {
                _activeImageIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final imageUrl = product.images[index];
              return Container(
                color: AppColors.editorialAnthracite,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
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
                      size: 40,
                    ),
                  ),
                ),
              );
            },
          ),

          // Sağ Alt Editoryal Sayfa İndikatörü (Örn: "1/2")
          Positioned(
            right: AppSpacing.screenHorizontal,
            bottom: AppSpacing.md,
            child: Container(
              key: const ValueKey('product_image_indicator'),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              color: AppColors.black.withValues(alpha: 0.75),
              child: Text(
                '${_activeImageIndex + 1}/${product.images.length}',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.primaryText,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Fiyat Bilgisi: İndirimli ise eski fiyat ve indirim yüzdesiyle birlikte gösterir
  Widget _buildPriceSection(Product product) {
    if (product.isDiscounted) {
      return Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.xs,
        children: [
          Text(
            CurrencyFormatter.format(product.price),
            key: const ValueKey('product_detail_price'),
            style: AppTextStyles.productPrice.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            CurrencyFormatter.format(product.oldPrice!),
            key: const ValueKey('product_detail_old_price'),
            style: AppTextStyles.productOldPrice.copyWith(fontSize: 14),
          ),
          if (product.discountText != null &&
              product.discountText!.trim().isNotEmpty)
            Container(
              key: const ValueKey('product_detail_discount_badge'),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              color: AppColors.white,
              child: Text(
                product.discountText!,
                style: AppTextStyles.discountTag.copyWith(
                  color: AppColors.black,
                ),
              ),
            ),
        ],
      );
    }

    return Text(
      CurrencyFormatter.format(product.price),
      key: const ValueKey('product_detail_price'),
      style: AppTextStyles.productPrice.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  /// Renk ve Ürün Referans Kodu + Panoya Kopyalama Butonu
  Widget _buildColorAndCodeRow(Product product) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      color: AppColors.divider,
      child: Row(
        children: [
          Expanded(
            child: Text(
              product.colorAndCode,
              key: const ValueKey('product_color_code_text'),
              style: AppTextStyles.caption.copyWith(
                color: AppColors.secondaryText,
                letterSpacing: 1.2,
              ),
            ),
          ),
          IconButton(
            key: const ValueKey('copy_code_button'),
            icon: const Icon(
              Icons.copy,
              size: 16,
              color: AppColors.secondaryText,
            ),
            tooltip: 'Kodu Kopyala',
            splashRadius: 18,
            onPressed: _copyColorAndCode,
          ),
        ],
      ),
    );
  }

  /// `AÇIKLAMA` ve `MALZEMELER` Editoryal Sekme Başlıkları
  Widget _buildTabs() {
    return Row(
      children: [
        _buildTabItem(title: 'AÇIKLAMA', index: 0, key: 'tab_description'),
        const SizedBox(width: AppSpacing.lg),
        _buildTabItem(title: 'MALZEMELER', index: 1, key: 'tab_materials'),
      ],
    );
  }

  Widget _buildTabItem({
    required String title,
    required int index,
    required String key,
  }) {
    final isSelected = _selectedTab == index;
    return InkWell(
      key: ValueKey(key),
      onTap: () {
        setState(() {
          _selectedTab = index;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: isSelected
                  ? AppTextStyles.menuItem.copyWith(
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.5,
                    )
                  : AppTextStyles.caption.copyWith(
                      color: AppColors.secondaryText,
                      letterSpacing: 1.5,
                    ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Container(
              height: 2,
              width: 28,
              color: isSelected ? AppColors.primaryText : Colors.transparent,
            ),
          ],
        ),
      ),
    );
  }

  /// Aktif Sekmeye Göre Gösterilen Metin İçeriği
  Widget _buildTabContent(Product product) {
    if (_selectedTab == 0) {
      return Text(
        product.description,
        key: const ValueKey('tab_content_description'),
        style: AppTextStyles.body.copyWith(
          color: AppColors.secondaryText,
          height: 1.6,
        ),
      );
    }

    return Text(
      product.materials,
      key: const ValueKey('tab_content_materials'),
      style: AppTextStyles.body.copyWith(
        color: AppColors.secondaryText,
        height: 1.6,
      ),
    );
  }

  /// Alt Sabit Aksiyon Barı (Stokta: SEPETE EKLE / Tükendi: TÜKENDİ)
  Widget _buildBottomActionBar() {
    final product = _product!;

    return Container(
      color: AppColors.shoppingBackground,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
        vertical: AppSpacing.sm,
      ),
      child: SafeArea(
        child: SizedBox(
          height: AppSpacing.buttonHeight,
          child: product.isOutOfStock
              ? Container(
                  key: const ValueKey('product_action_button'),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    border: Border.all(color: AppColors.dividerLight),
                  ),
                  child: Text(
                    'TÜKENDİ',
                    style: AppTextStyles.buttonTextOutlined.copyWith(
                      color: AppColors.secondaryText,
                      letterSpacing: 2.0,
                    ),
                  ),
                )
              : ElevatedButton(
                  key: const ValueKey('product_action_button'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryText,
                    foregroundColor: AppColors.shoppingBackground,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Sepet özelliği Aşama 8\'de eklenecektir.',
                        ),
                        duration: Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: Text('SEPETE EKLE', style: AppTextStyles.buttonText),
                ),
        ),
      ),
    );
  }
}
