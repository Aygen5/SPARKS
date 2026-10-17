import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sparks/app/theme/app_colors.dart';
import 'package:sparks/app/theme/app_text_styles.dart';
import 'package:sparks/core/constants/app_constants.dart';

/// SPARKS merkezi GoRouter rota tanımları.
/// Kaynak: docs/architecture.md
class AppRoutes {
  const AppRoutes._();

  static const String root = '/';
  static const String splash = '/splash';
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
  static GoRouter createRouter({String initialLocation = AppRoutes.root}) {
    return GoRouter(
      initialLocation: initialLocation,
      routes: [
        GoRoute(
          path: AppRoutes.root,
          name: 'root',
          builder: (context, state) => const _ArchitecturePlaceholderScreen(),
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
  static void reset({String initialLocation = AppRoutes.root}) {
    router = createRouter(initialLocation: initialLocation);
  }
}

/// Aşama 1 mimari hazırlık yer tutucusu.
/// Yeni ekran kodlaması yapılmadan önce projenin derlenebilir ve temiz temelini doğrular.
class _ArchitecturePlaceholderScreen extends StatelessWidget {
  const _ArchitecturePlaceholderScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.shoppingBackground,
      body: Center(
        child: Text(AppConstants.appName, style: AppTextStyles.brandLogoLarge),
      ),
    );
  }
}
