import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sparks/app/router/app_router.dart';
import 'package:sparks/app/theme/app_colors.dart';
import 'package:sparks/app/theme/app_spacing.dart';
import 'package:sparks/app/theme/app_text_styles.dart';
import 'package:sparks/core/constants/app_constants.dart';
import 'package:sparks/core/constants/app_images.dart';
import 'package:sparks/core/widgets/sparks_image.dart';

/// SPARKS Tam Ekran Editoryal Açılış Ekranı (Splash Screen).
/// Zara yüksek moda estetiğinden ilham alan tam ekran fotoğraf,
/// yavaş zoom animasyonu, buzlu cam buton ve soldan sağa kayan dev serif logoyu içerir.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // 1. Arka plan yavaş büyüme (6 saniye) animasyon denetleyicisi
  late final AnimationController _backgroundController;
  late final Animation<double> _backgroundScaleAnimation;

  // 2. İçerik (Logo ve Buton - 2 saniye) animasyon denetleyicisi
  late final AnimationController _contentController;
  late final Animation<double> _logoFadeAnimation;
  late final Animation<Offset> _logoSlideAnimation;
  late final Animation<double> _buttonFadeAnimation;
  late final Animation<Offset> _buttonSlideAnimation;

  @override
  void initState() {
    super.initState();

    // Arka plan animasyonu yapılandırması (6 sn, 1.0 -> 1.06)
    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    );
    _backgroundScaleAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(
        parent: _backgroundController,
        curve: Curves.easeOutCubic,
      ),
    );

    // İçerik animasyonu yapılandırması (2 sn, kademeli giriş)
    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // SPARKS logosu: Soldan sağa kayma ve belirme (0.1 - 0.7 aralığı)
    _logoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.1, 0.7, curve: Curves.easeOut),
      ),
    );
    _logoSlideAnimation =
        Tween<Offset>(
          begin: const Offset(-0.15, 0.0),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _contentController,
            curve: const Interval(0.1, 0.7, curve: Curves.easeOutCubic),
          ),
        );

    // Koleksiyonu Keşfet Butonu: Logodan hemen sonra alttan yukarı ve belirme (0.4 - 0.9 aralığı)
    _buttonFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.4, 0.9, curve: Curves.easeOut),
      ),
    );
    _buttonSlideAnimation =
        Tween<Offset>(begin: const Offset(0.0, 0.15), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _contentController,
            curve: const Interval(0.4, 0.9, curve: Curves.easeOutCubic),
          ),
        );

    // Animasyonları başlat
    _backgroundController.forward();
    _contentController.forward();
  }

  @override
  void dispose() {
    // Bellek sızıntısını önlemek için her iki denetleyici de serbest bırakılır
    _backgroundController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _onExplorePressed() {
    // GoRouter üzerinden ana uygulamaya geçiş (Geri tuşunda splash'e dönülmez)
    context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.shoppingBackground,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Katman: Tam Ekran Yavaş Büyüyen Fotoğraf ve Gradient
          _SplashBackground(scaleAnimation: _backgroundScaleAnimation),

          // 2. Katman: Editoryal İçerik Katmanı (Buton ve Dev Logo)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenHorizontal,
                vertical: AppSpacing.screenVertical,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(flex: 3),

                  // Orta / Orta-Üst Bölüm: Buzlu Cam Efektli "Koleksiyonu Keşfet" Butonu
                  SlideTransition(
                    position: _buttonSlideAnimation,
                    child: FadeTransition(
                      opacity: _buttonFadeAnimation,
                      child: Center(
                        child: _EditorialGlassButton(
                          onPressed: _onExplorePressed,
                        ),
                      ),
                    ),
                  ),

                  const Spacer(flex: 4),

                  // Alt Bölüm: Soldan Sağa Kayan Dev SPARKS Serif Marka Logosu
                  SlideTransition(
                    position: _logoSlideAnimation,
                    child: FadeTransition(
                      opacity: _logoFadeAnimation,
                      child: Text(
                        AppConstants.appName,
                        style: AppTextStyles.brandLogoLarge.copyWith(
                          fontSize: 48,
                          letterSpacing: 8.0,
                          height: 1.0,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Tam ekran editoryal moda fotoğrafını, scale animasyonunu ve kontrast degrade'ini yönetir.
class _SplashBackground extends StatelessWidget {
  const _SplashBackground({required this.scaleAnimation});

  final Animation<double> scaleAnimation;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Arka plan rengi (Görsel yüklenirken beyaz parlamayı önler)
        Container(color: AppColors.editorialAnthracite),

        // Yavaş zoom yapan görsel
        AnimatedBuilder(
          animation: scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: scaleAnimation.value,
              alignment: Alignment.center,
              child: child,
            );
          },
          child: SparksImage(
            imageUrl: AppImages.splashBackground,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            fallbackWidget: Container(
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
            ),
          ),
        ),

        // Karartma Degrade Katmanı: Alt kısımda SPARKS logosunun okunabilirliği için koyulaşır
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.15),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.45),
                  Colors.black.withValues(alpha: 0.85),
                ],
                stops: const [0.0, 0.4, 0.75, 1.0],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// İnce çerçeveli, yarı saydam buzlu cam (Glassmorphism) efektli editoryal buton.
class _EditorialGlassButton extends StatelessWidget {
  const _EditorialGlassButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            border: Border.all(
              color: AppColors.primaryText.withValues(alpha: 0.8),
              width: AppSpacing.borderWidth,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onPressed,
              splashColor: Colors.white.withValues(alpha: 0.15),
              highlightColor: Colors.white.withValues(alpha: 0.08),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.md,
                ),
                child: Text(
                  AppConstants.exploreCollectionBtn,
                  style: AppTextStyles.buttonTextOutlined.copyWith(
                    letterSpacing: 2.5,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
