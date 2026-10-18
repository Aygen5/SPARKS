import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sparks/app/theme/app_colors.dart';
import 'package:sparks/app/theme/app_text_styles.dart';
import 'package:sparks/core/constants/app_constants.dart';
import 'package:sparks/features/account/presentation/account_screen.dart';
import 'package:sparks/features/auth/presentation/login_screen.dart';
import 'package:sparks/features/auth/presentation/register_screen.dart';
import 'package:sparks/features/cart/presentation/cart_screen.dart';
import 'package:sparks/features/catalog/presentation/catalog_placeholder_screen.dart';
import 'package:sparks/features/checkout/presentation/checkout_screen.dart';
import 'package:sparks/features/favorites/presentation/favorites_screen.dart';
import 'package:sparks/features/home/presentation/home_screen.dart';
import 'package:sparks/features/menu/presentation/menu_screen.dart';
import 'package:sparks/features/navigation/presentation/main_scaffold.dart';
import 'package:sparks/features/orders/presentation/orders_screen.dart';
import 'package:sparks/features/product_detail/presentation/product_detail_screen.dart';
import 'package:sparks/features/search/presentation/search_screen.dart';
import 'package:sparks/features/splash/presentation/splash_screen.dart';

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
  static const String checkout = '/checkout';
  static const String catalog = '/catalog';
  static const String productDetail = '/product/:id';
  static const String favorites = '/favorites';
  static const String orders = '/account/orders';
  static const String login = '/login';
  static const String register = '/register';
}

class AppRouter {
  const AppRouter._();

  /// Bağımsız router örneği oluşturan fabrika metodu (test edilebilirlik sağlar)
  static GoRouter createRouter({String initialLocation = AppRoutes.splash}) {
    return GoRouter(
      initialLocation: initialLocation,
      routes: [
        // 1. Açılış Ekranı (Splash Screen - Başlangıç Rotası)
        // Alt navigasyon çubuğu içermez; bağımsız tam ekran editoryal rotadır.
        GoRoute(
          path: AppRoutes.splash,
          name: 'splash',
          builder: (context, state) => const SplashScreen(),
        ),

        // 2. Ana Uygulama Kalıcı 5 Sekmeli Kabuğu (StatefulShellRoute)
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return MainScaffold(navigationShell: navigationShell);
          },
          branches: [
            // Dal 0: Anasayfa (Lookbook 4 Fotoğraflı Dikey Akış)
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.home,
                  name: 'home',
                  pageBuilder: (context, state) {
                    return CustomTransitionPage<void>(
                      key: state.pageKey,
                      child: const HomeScreen(),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                            // Açılış ekranından yumuşak editoryal fade-in geçişi
                            return FadeTransition(
                              opacity: CurveTween(curve: Curves.easeInOut)
                                  .animate(animation),
                              child: child,
                            );
                          },
                    );
                  },
                ),
              ],
            ),

            // Dal 1: MENÜ
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.menu,
                  name: 'menu',
                  builder: (context, state) => const MenuScreen(),
                ),
              ],
            ),

            // Dal 2: Arama
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.search,
                  name: 'search',
                  builder: (context, state) => const SearchScreen(),
                ),
              ],
            ),

            // Dal 3: HESAP
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.account,
                  name: 'account',
                  builder: (context, state) => const AccountScreen(),
                ),
              ],
            ),

            // Dal 4: Sepet
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.cart,
                  name: 'cart',
                  builder: (context, state) => const CartScreen(),
                ),
              ],
            ),
          ],
        ),

        // 3. Ürün Listeleme Ekranı (CatalogScreen sarmalayıcısı)
        GoRoute(
          path: AppRoutes.catalog,
          name: 'catalog',
          builder: (context, state) {
            final gender =
                state.uri.queryParameters['gender'] ?? AppConstants.genderWomen;
            final category = state.uri.queryParameters['category'] ?? '';
            return CatalogPlaceholderScreen(gender: gender, category: category);
          },
        ),

        // 4. Ürün Detayı Rotası (Aşama 7 Gerçek Detay Ekranı)
        GoRoute(
          path: AppRoutes.productDetail,
          name: 'productDetail',
          builder: (context, state) {
            final productId = state.pathParameters['id'] ?? '';
            return ProductDetailScreen(productId: productId);
          },
        ),

        // 5. Favoriler Rotası (Aşama 9 Gerçek Favoriler Ekranı)
        GoRoute(
          path: AppRoutes.favorites,
          name: 'favorites',
          builder: (context, state) => const FavoritesScreen(),
        ),

        // 6. Alışverişlerim Rotası (Aşama 9 Gerçek Alışverişlerim Ekranı)
        GoRoute(
          path: AppRoutes.orders,
          name: 'orders',
          builder: (context, state) => const OrdersScreen(),
        ),

        // 7. Sipariş Özeti / Checkout Rotası (Aşama 10 Gerçek İnceleme Ekranı)
        GoRoute(
          path: AppRoutes.checkout,
          name: 'checkout',
          builder: (context, state) => const CheckoutScreen(),
        ),

        // 8. Kullanıcı Giriş Ekranı (Aşama 12 Aşağıdan Yukarı Animasyonlu Rota)
        GoRoute(
          path: AppRoutes.login,
          name: 'login',
          pageBuilder: (context, state) {
            return CustomTransitionPage<void>(
              key: state.pageKey,
              child: const LoginScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                    const begin = Offset(0.0, 1.0);
                    const end = Offset.zero;
                    const curve = Curves.easeOutCubic;
                    final tween = Tween(
                      begin: begin,
                      end: end,
                    ).chain(CurveTween(curve: curve));
                    return SlideTransition(
                      position: animation.drive(tween),
                      child: child,
                    );
                  },
            );
          },
        ),

        // 9. Kullanıcı Kayıt Ekranı (Aşama 12 Aşağıdan Yukarı Animasyonlu Rota)
        GoRoute(
          path: AppRoutes.register,
          name: 'register',
          pageBuilder: (context, state) {
            return CustomTransitionPage<void>(
              key: state.pageKey,
              child: const RegisterScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                    const begin = Offset(0.0, 1.0);
                    const end = Offset.zero;
                    const curve = Curves.easeOutCubic;
                    final tween = Tween(
                      begin: begin,
                      end: end,
                    ).chain(CurveTween(curve: curve));
                    return SlideTransition(
                      position: animation.drive(tween),
                      child: child,
                    );
                  },
            );
          },
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
