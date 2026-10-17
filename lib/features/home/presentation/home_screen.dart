import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sparks/app/router/app_router.dart';
import 'package:sparks/app/theme/app_colors.dart';
import 'package:sparks/app/theme/app_spacing.dart';
import 'package:sparks/app/theme/app_text_styles.dart';
import 'package:sparks/core/constants/app_constants.dart';
import 'package:sparks/core/constants/app_images.dart';

/// SPARKS Ana Sayfası (Lookbook).
/// 4 editoryal moda fotoğrafını tam ekran dikey PageView içinde sunar.
/// SPARKS logosu sağ alt köşede sabit bir katman olarak durur ve kaydırmada hareket etmez.
/// Fotoğrafın herhangi bir yerine dokunulduğunda Menü sekmesine (/menu) yönlendirir.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.onPhotoTap});

  /// Opsiyonel dokunma geri çağrımı (testlerde ve özel yönlendirmelerde kullanılır).
  /// Belirtilmezse varsayılan olarak `context.go(AppRoutes.menu)` çalışır.
  final VoidCallback? onPhotoTap;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _handlePhotoTap() {
    if (widget.onPhotoTap != null) {
      widget.onPhotoTap!();
    } else {
      context.go(AppRoutes.menu);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.shoppingBackground,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Katman: 4 Fotoğraflı Dikey PageView
          PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            physics: const ClampingScrollPhysics(),
            itemCount: AppImages.homeLookbookImages.length,
            itemBuilder: (context, index) {
              final imageUrl = AppImages.homeLookbookImages[index];
              return _LookbookImageItem(
                imageUrl: imageUrl,
                index: index,
                onTap: _handlePhotoTap,
              );
            },
          ),

          // 2. Katman: Sabit Alt Kontrast Gradyanı (Logonun her fotoğrafta okunabilirliği için)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 180,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.15),
                      Colors.black.withValues(alpha: 0.70),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 3. Katman: Sabit SPARKS Marka Logosu (Sağa hizalı, sayfa kaydırılsa da sabit kalır)
          Positioned(
            right: AppSpacing.screenHorizontal,
            bottom: AppSpacing.md,
            child: GestureDetector(
              onTap: _handlePhotoTap,
              behavior: HitTestBehavior.opaque,
              child: Text(
                AppConstants.appName,
                textAlign: TextAlign.right,
                style: AppTextStyles.brandLogoLarge.copyWith(
                  fontSize: 44,
                  letterSpacing: 8.0,
                  height: 1.0,
                  color: AppColors.primaryText,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Lookbook içindeki tek bir tam ekran editoryal moda fotoğrafı bileşeni.
class _LookbookImageItem extends StatelessWidget {
  const _LookbookImageItem({
    required this.imageUrl,
    required this.index,
    required this.onTap,
  });

  final String imageUrl;
  final int index;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: ValueKey('lookbook_image_$index'),
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Arka plan rengi (Görsel ağdan yüklenirken beyaz parlamayı engeller)
          Container(color: AppColors.editorialAnthracite),

          // Editoryal Yüksek Moda Fotoğrafı (BoxFit.cover ile alanı doldurur)
          Image.network(
            imageUrl,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                color: AppColors.editorialAnthracite,
                child: const Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primaryText,
                      ),
                    ),
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              // Ağ hatası durumunda editoryal degrade fallback'i
              return Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.editorialBrown,
                      AppColors.editorialAnthracite,
                      AppColors.shoppingBackground,
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
