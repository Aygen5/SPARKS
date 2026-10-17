import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sparks/app/app.dart';
import 'package:sparks/app/router/app_router.dart';
import 'package:sparks/app/theme/app_colors.dart';
import 'package:sparks/app/theme/app_spacing.dart';
import 'package:sparks/app/theme/app_text_styles.dart';
import 'package:sparks/app/theme/app_theme.dart';
import 'package:sparks/core/constants/app_constants.dart';
import 'package:sparks/core/constants/app_images.dart';
import 'package:sparks/features/account/presentation/account_screen.dart';
import 'package:sparks/features/cart/presentation/cart_screen.dart';
import 'package:sparks/features/home/presentation/home_screen.dart';
import 'package:sparks/features/menu/presentation/menu_screen.dart';
import 'package:sparks/features/navigation/presentation/main_scaffold.dart';
import 'package:sparks/features/navigation/presentation/sparks_bottom_nav_bar.dart';
import 'package:sparks/features/search/presentation/search_screen.dart';

void main() {
  setUpAll(() {
    // Test ortamında çalışma zamanı font indirme isteğini kapat ve sistem fallback fontlarını kullan
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group(
    'Aşama 1 & 2 — Tasarım Sistemi ve Editoryal Açılış Ekranı Testleri',
    () {
      setUp(() {
        AppRouter.reset(initialLocation: AppRoutes.splash);
      });

      test(
        '1. Renk sistemi beklenen editoryal ve alışveriş değerlerine sahiptir',
        () {
          expect(AppColors.editorialCream, const Color(0xFFFDFBF7));
          expect(AppColors.editorialBeige, const Color(0xFFE8E1D5));
          expect(AppColors.editorialStone, const Color(0xFFD9D2C7));
          expect(AppColors.editorialBrown, const Color(0xFF5A3E2B));
          expect(AppColors.editorialAnthracite, const Color(0xFF222222));
          expect(AppColors.shoppingBackground, const Color(0xFF000000));
          expect(AppColors.primaryText, const Color(0xFFFFFFFF));
          expect(AppColors.secondaryText, const Color(0xFF8E8E8E));
          expect(AppColors.divider, const Color(0xFF1F1F1F));
        },
      );

      test(
        '2. Keskin köşe ilkesi (0 radius) ve boşluk sabitleri doğrulanır',
        () {
          expect(AppSpacing.buttonRadius, 0.0);
          expect(AppSpacing.cardRadius, 0.0);
          expect(AppSpacing.dialogRadius, 0.0);
          expect(AppSpacing.borderWidth, 1.0);
          expect(AppSpacing.buttonHeight, 52.0);
          expect(AppSpacing.bottomBarHeight, 64.0);
          expect(AppSpacing.activeIndicatorSize, 4.0);
        },
      );

      test('3. Editoryal görsel URL sabitleri eksiksiz ve doğrudur', () {
        expect(AppImages.splashBackground, isNotEmpty);
        expect(AppImages.homeLookbookImages.length, 4);
      });

      test(
        '4. Tipografi hiyerarşisi serif ve sans-serif stillerini içerir',
        () {
          expect(AppTextStyles.brandLogoLarge.fontSize, 42);
          expect(AppTextStyles.sectionHeading.fontSize, 24);
          expect(AppTextStyles.buttonText.fontSize, 12);
        },
      );

      test(
        '5. Material 3 teması keskin köşeli butonları ve siyah zemini yönetir',
        () {
          final theme = AppTheme.darkTheme;
          expect(theme.useMaterial3, isTrue);
          expect(theme.brightness, Brightness.dark);
          expect(theme.scaffoldBackgroundColor, AppColors.shoppingBackground);
        },
      );

      testWidgets(
        '6. SplashScreen başlangıç rotası olarak açılır, logo ve buton görünür',
        (WidgetTester tester) async {
          await tester.pumpWidget(const SparksApp());

          // Animasyonların tamamlanması için zaman tanı
          await tester.pump(const Duration(milliseconds: 500));
          await tester.pump(const Duration(milliseconds: 1500));

          // Logo ve butonun ekranda olduğunu doğrula
          expect(find.text(AppConstants.appName), findsOneWidget);
          expect(find.text(AppConstants.exploreCollectionBtn), findsOneWidget);
        },
      );

      testWidgets(
        '7. Koleksiyonu Keşfet butonuna basıldığında ana hedefe yumuşak geçiş yapılır',
        (WidgetTester tester) async {
          await tester.pumpWidget(const SparksApp());

          // Animasyonları bitir
          await tester.pump(const Duration(seconds: 2));

          final buttonFinder = find.text(AppConstants.exploreCollectionBtn);
          expect(buttonFinder, findsOneWidget);

          // Butona dokun
          await tester.tap(buttonFinder);
          await tester.pumpAndSettle();

          // Ana sayfa Lookbook ekranının açıldığını doğrula
          expect(find.byType(HomeScreen), findsOneWidget);
          expect(
            find.byKey(const ValueKey('lookbook_image_0')),
            findsOneWidget,
          );
        },
      );

      testWidgets(
        '8. Dar ekran boyutlarında (360x640) SplashScreen taşma olmadan render edilir',
        (WidgetTester tester) async {
          tester.view.physicalSize = const Size(360, 640);
          tester.view.devicePixelRatio = 1.0;
          addTearDown(() {
            tester.view.resetPhysicalSize();
            tester.view.resetDevicePixelRatio();
          });

          await tester.pumpWidget(const SparksApp());
          await tester.pump(const Duration(seconds: 2));

          expect(find.text(AppConstants.appName), findsOneWidget);
          expect(find.text(AppConstants.exploreCollectionBtn), findsOneWidget);
        },
      );
    },
  );

  group('Aşama 3 — Lookbook ve 5 Sekmeli Alt Navigasyon Testleri', () {
    setUp(() {
      AppRouter.reset(initialLocation: AppRoutes.home);
    });

    testWidgets(
      '9. Ana sayfa (Lookbook) 4 fotoğraf içeren dikey PageView barındırır',
      (WidgetTester tester) async {
        await tester.pumpWidget(const SparksApp());
        await tester.pumpAndSettle();

        expect(find.byType(HomeScreen), findsOneWidget);
        expect(find.byType(PageView), findsOneWidget);

        final pageView = tester.widget<PageView>(find.byType(PageView));
        expect(pageView.scrollDirection, Axis.vertical);

        // İlk fotoğrafın varlığını doğrula
        expect(find.byKey(const ValueKey('lookbook_image_0')), findsOneWidget);
      },
    );

    testWidgets(
      '10. SPARKS marka logosu Lookbook üzerinde sabit sağ alt katmanda yer alır',
      (WidgetTester tester) async {
        await tester.pumpWidget(const SparksApp());
        await tester.pumpAndSettle();

        final logoFinder = find.text(AppConstants.appName);
        expect(logoFinder, findsOneWidget);

        // Sayfayı dikey kaydır
        await tester.drag(find.byType(PageView), const Offset(0, -400));
        await tester.pumpAndSettle();

        // Kaydırmadan sonra da logonun sabit şekilde ekranda kaldığını doğrula
        expect(logoFinder, findsOneWidget);
      },
    );

    testWidgets(
      '11. 5 sekmeli alt navigasyon çubuğu doğru sıralama, ikon ve etiketlerle görünür',
      (WidgetTester tester) async {
        await tester.pumpWidget(const SparksApp());
        await tester.pumpAndSettle();

        expect(find.byType(SparksBottomNavBar), findsOneWidget);

        // 1. Anasayfa
        expect(find.byKey(const ValueKey('nav_tab_home')), findsOneWidget);
        expect(find.text(AppConstants.tabHome), findsOneWidget);
        expect(find.byIcon(Icons.home_outlined), findsOneWidget);

        // 2. MENÜ (ikonsuz)
        expect(find.byKey(const ValueKey('nav_tab_menu')), findsOneWidget);
        expect(find.text(AppConstants.tabMenu), findsOneWidget);

        // 3. Arama
        expect(find.byKey(const ValueKey('nav_tab_search')), findsOneWidget);
        expect(find.text(AppConstants.tabSearch), findsOneWidget);
        expect(find.byIcon(Icons.search), findsOneWidget);

        // 4. HESAP (ikonsuz)
        expect(find.byKey(const ValueKey('nav_tab_account')), findsOneWidget);
        expect(find.text(AppConstants.tabAccount), findsOneWidget);

        // 5. Sepet ([ 0 ] minimal sepet badge)
        expect(find.byKey(const ValueKey('nav_tab_cart')), findsOneWidget);
        expect(find.text('[ 0 ]'), findsOneWidget);
        expect(find.byIcon(Icons.shopping_bag_outlined), findsOneWidget);
      },
    );

    testWidgets(
      '12. Lookbook üzerindeki fotoğrafa dokunulduğunda Menü sekmesine geçilir',
      (WidgetTester tester) async {
        await tester.pumpWidget(const SparksApp());
        await tester.pumpAndSettle();

        // Lookbook ilk fotoğrafına dokun
        await tester.tap(find.byKey(const ValueKey('lookbook_image_0')));
        await tester.pumpAndSettle();

        // Menü ekranının açıldığını doğrula
        expect(find.byType(MenuScreen), findsOneWidget);
        // Alt barın kalıcı kaldığını doğrula
        expect(find.byType(SparksBottomNavBar), findsOneWidget);
      },
    );

    testWidgets(
      '13. Alt navigasyon sekmelerine dokunulduğunda doğru hedefler açılır ve bar kalıcıdır',
      (WidgetTester tester) async {
        await tester.pumpWidget(const SparksApp());
        await tester.pumpAndSettle();

        // Arama sekmesine tıkla
        await tester.tap(find.byKey(const ValueKey('nav_tab_search')));
        await tester.pumpAndSettle();
        expect(find.byType(SearchScreen), findsOneWidget);
        expect(find.byType(SparksBottomNavBar), findsOneWidget);

        // Hesap sekmesine tıkla
        await tester.tap(find.byKey(const ValueKey('nav_tab_account')));
        await tester.pumpAndSettle();
        expect(find.byType(AccountScreen), findsOneWidget);
        expect(find.byType(SparksBottomNavBar), findsOneWidget);

        // Sepet sekmesine tıkla
        await tester.tap(find.byKey(const ValueKey('nav_tab_cart')));
        await tester.pumpAndSettle();
        expect(find.byType(CartScreen), findsOneWidget);
        expect(find.byType(SparksBottomNavBar), findsOneWidget);

        // Anasayfa sekmesine geri dön
        await tester.tap(find.byKey(const ValueKey('nav_tab_home')));
        await tester.pumpAndSettle();
        expect(find.byType(HomeScreen), findsOneWidget);
        expect(find.byType(SparksBottomNavBar), findsOneWidget);
      },
    );

    testWidgets(
      '14. Dar ekran boyutlarında (360x640) 5 sekmeli bar ve Lookbook taşma olmadan render edilir',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(360, 640);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(const SparksApp());
        await tester.pumpAndSettle();

        expect(find.byType(MainScaffold), findsOneWidget);
        expect(find.byType(SparksBottomNavBar), findsOneWidget);
        expect(find.byType(HomeScreen), findsOneWidget);
      },
    );
  });
}
