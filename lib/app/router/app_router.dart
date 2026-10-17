import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sparks/app/theme/app_colors.dart';
import 'package:sparks/app/theme/app_text_styles.dart';
import 'package:sparks/features/splash/presentation/splash_screen.dart';

import 'package:sparks/features/home/presentation/home_screen.dart';

/// SPARKS merkezi GoRouter rota tanımları.
/// Kaynak: docs/architecture.md
class AppRoutes {
  const AppRoutes._();

  static const String splash = '/';
  static const String home = '/home';
  static const String menu = '/menu';
  static const String search = '/search';
  static const String account = '/account';
  static const String cart = '/cart';
  static const String catalog = '/catalog';
  static const String productDetail = '/product/:id';
  static const String orders = '/account/orders';
}

class AppRouter {
  const AppRouter._();

  /// Bağımsız router örneği oluşturan fabrika metodu (test edilebilirlik sağlar)
  static GoRouter createRouter({String initialLocation = AppRoutes.splash}) {
    return GoRouter(
      initialLocation: initialLocation,
      routes: [
        // 1. Açılış Ekranı (Splash Screen - Başlangıç Rotası)
        GoRoute(
          path: AppRoutes.splash,
          name: 'splash',
          builder: (context, state) => const SplashScreen(),
        ),

        // 2. Ana Sayfa Rotası (Lookbook 4 Fotoğraflı Dikey Akış)
        GoRoute(
          path: AppRoutes.home,
          name: 'home',
          pageBuilder: (context, state) {
            return CustomTransitionPage<void>(
              key: state.pageKey,
              child: const HomeScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                    // Yumuşak editoryal fade-in geçiş efekti
                    return FadeTransition(
                      opacity: CurveTween(curve: Curves.easeInOut)
                          .animate(animation),
                      child: child,
                    );
                  },
            );
          },
        ),

        // 3. Menü Geçici Hedef Rotası (Fotoğrafa dokunulduğunda açılır)
        GoRoute(
          path: AppRoutes.menu,
          name: 'menu',
          builder: (context, state) => const Scaffold(
            backgroundColor: AppColors.shoppingBackground,
            body: Center(
              child: Text(
                'MENÜ',
                style: TextStyle(color: AppColors.primaryText),
              ),
            ),
          ),
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        backgroundColor: AppColors.shoppingBackground,
        body: Center(
          child: Text(
            'Sayfa bulunamadı: ${state.uri}',
            style: AppTextStyles.body,
          ),
        ),
      ),
    );
  }

  /// Varsayılan uygulama router örneği
  static GoRouter router = createRouter();

  /// Testler veya sıfırlama için router'ı yeniden oluşturur
  static void reset({String initialLocation = AppRoutes.splash}) {
    router = createRouter(initialLocation: initialLocation);
  }
}
