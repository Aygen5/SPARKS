import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sparks/app/router/app_router.dart';
import 'package:sparks/app/theme/app_colors.dart';
import 'package:sparks/app/theme/app_spacing.dart';
import 'package:sparks/app/theme/app_text_styles.dart';
import 'package:sparks/core/constants/app_constants.dart';
import 'package:sparks/core/constants/app_images.dart';
import 'package:sparks/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:sparks/features/auth/presentation/cubit/auth_state.dart';

/// SPARKS Ana Sayfası (Lookbook).
/// 4 editoryal moda fotoğrafını tam ekran dikey PageView içinde sunar.
/// SPARKS logosu sağ alt köşede sabit bir katman olarak durur ve kaydırmada hareket etmez.
/// Fotoğrafın herhangi bir yerine dokunulduğunda Menü sekmesine (/menu) yönlendirir.
/// Sağ üst köşede oturum kapalıyken zarif bir GİRİŞ YAP butonu sunar.
class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    this.onPhotoTap,
    this.onLoginTap,
    this.authCubit,
  });

  /// Opsiyonel dokunma geri çağrımı (testlerde ve özel yönlendirmelerde kullanılır).
  /// Belirtilmezse varsayılan olarak `context.go(AppRoutes.menu)` çalışır.
  final VoidCallback? onPhotoTap;

  /// Giriş yap bağlantısına dokunulduğunda tetiklenen opsiyonel geri çağrım
  final VoidCallback? onLoginTap;

  /// Test edilebilirlik için dışarıdan enjekte edilebilen AuthCubit örneği
  final AuthCubit? authCubit;

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

  AuthCubit _resolveAuthCubit(BuildContext context) {
    if (widget.authCubit != null) return widget.authCubit!;
    try {
      return context.read<AuthCubit>();
    } catch (_) {
      return AuthCubit.instance;
    }
  }

  void _handlePhotoTap() {
    if (widget.onPhotoTap != null) {
      widget.onPhotoTap!();
    } else {
      context.go(AppRoutes.menu);
    }
  }

  void _handleLoginTap() {
    if (widget.onLoginTap != null) {
      widget.onLoginTap!();
    } else {
      context.push(AppRoutes.login);
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

          // 4. Katman: Sabit Sağ Üst Giriş Yap Butonu (Oturum kapalıyken görünür)
          Positioned(
            top: MediaQuery.of(context).padding.top + AppSpacing.sm,
            right: AppSpacing.screenHorizontal,
            child: BlocBuilder<AuthCubit, AuthState>(
              bloc: _resolveAuthCubit(context),
              builder: (context, authState) {
                if (authState.isAuthenticated) {
                  return const SizedBox.shrink();
                }
                return GestureDetector(
                  key: const ValueKey('home_login_button'),
                  onTap: _handleLoginTap,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      border: Border.all(
                        color: AppColors.primaryText.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Text(
                      'GİRİŞ YAP',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primaryText,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.5,
                        fontSize: 11,
                      ),
                    ),
                  ),
                );
              },
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
