import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sparks/app/theme/app_theme.dart';
import 'package:sparks/features/account/presentation/account_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  Widget createAccountWidget({
    VoidCallback? onNavigateToFavorites,
    VoidCallback? onNavigateToOrders,
    VoidCallback? onNavigateToCart,
  }) {
    return MaterialApp(
      theme: AppTheme.darkTheme,
      home: AccountScreen(
        onNavigateToFavorites: onNavigateToFavorites,
        onNavigateToOrders: onNavigateToOrders,
        onNavigateToCart: onNavigateToCart,
      ),
    );
  }

  group('Aşama 9 — Hesabım Ekranı (AccountScreen) Testleri', () {
    testWidgets('1. Hesabım ekranı hatasız açılır ve başlığı gösterir', (
      tester,
    ) async {
      await tester.pumpWidget(createAccountWidget());
      await tester.pumpAndSettle();

      expect(find.text('HESAP'), findsOneWidget);
      expect(find.byKey(const ValueKey('account_screen_list')), findsOneWidget);
    });

    testWidgets(
      '2. Gerçek auth altyapısı olmadığından misafir kullanıcı kartı ve bilgilendirme gösterilir',
      (tester) async {
        await tester.pumpWidget(createAccountWidget());
        await tester.pumpAndSettle();

        expect(
          find.byKey(const ValueKey('account_guest_card')),
          findsOneWidget,
        );
        expect(find.text('MİSAFİR KULLANICI'), findsOneWidget);
        expect(find.text('Giriş yapılmadı'), findsOneWidget);
        expect(
          find.textContaining(
            'kimlik doğrulama altyapısı henüz aktif değildir',
          ),
          findsOneWidget,
        );

        // Sahte isim, sahte e-posta veya uydurma profil fotoğrafı olmamalı
        expect(find.text('Aygen'), findsNothing);
        expect(find.text('admin@sparks.com'), findsNothing);
      },
    );

    testWidgets(
      '3. Giriş / Kayıt butonuna dokunulduğunda bilgilendirici SnackBar gösterilir',
      (tester) async {
        await tester.pumpWidget(createAccountWidget());
        await tester.pumpAndSettle();

        final loginBtn = find.byKey(const ValueKey('account_login_button'));
        expect(loginBtn, findsOneWidget);
        expect(find.text('GİRİŞ / KAYIT (YAKINDA)'), findsOneWidget);

        await tester.tap(loginBtn);
        await tester.pumpAndSettle();

        expect(
          find.text('Kimlik doğrulama ve üyelik servisi henüz aktif değildir.'),
          findsOneWidget,
        );
      },
    );

    testWidgets('4. FAVORİLERİM kısayolu doğru eylemi tetikler', (
      tester,
    ) async {
      bool favoritesTapped = false;

      await tester.pumpWidget(
        createAccountWidget(
          onNavigateToFavorites: () => favoritesTapped = true,
        ),
      );
      await tester.pumpAndSettle();

      final favItem = find.byKey(const ValueKey('account_favorites_button'));
      expect(favItem, findsOneWidget);
      expect(find.text('FAVORİLERİM'), findsOneWidget);

      await tester.tap(favItem);
      await tester.pumpAndSettle();

      expect(favoritesTapped, isTrue);
    });

    testWidgets('5. ALIŞVERİŞLERİM kısayolu doğru eylemi tetikler', (
      tester,
    ) async {
      bool ordersTapped = false;

      await tester.pumpWidget(
        createAccountWidget(onNavigateToOrders: () => ordersTapped = true),
      );
      await tester.pumpAndSettle();

      final ordersItem = find.byKey(const ValueKey('account_orders_button'));
      expect(ordersItem, findsOneWidget);
      expect(find.text('ALIŞVERİŞLERİM'), findsOneWidget);

      await tester.tap(ordersItem);
      await tester.pumpAndSettle();

      expect(ordersTapped, isTrue);
    });

    testWidgets('6. SEPETİM kısayolu doğru eylemi tetikler', (tester) async {
      bool cartTapped = false;

      await tester.pumpWidget(
        createAccountWidget(onNavigateToCart: () => cartTapped = true),
      );
      await tester.pumpAndSettle();

      final cartItem = find.byKey(const ValueKey('account_cart_button'));
      expect(cartItem, findsOneWidget);
      expect(find.text('SEPETİM'), findsOneWidget);

      await tester.tap(cartItem);
      await tester.pumpAndSettle();

      expect(cartTapped, isTrue);
    });

    testWidgets('7. Destek ve sürüm bilgisi bölümü doğru görüntülenir', (
      tester,
    ) async {
      await tester.pumpWidget(createAccountWidget());
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('account_support_section')),
        findsOneWidget,
      );
      expect(find.text('SPARKS v1.0.0'), findsOneWidget);
      expect(
        find.text('Müşteri Desteği: destek@sparks.fashion'),
        findsOneWidget,
      );
    });

    testWidgets(
      '8. Dar ekran boyutlarında (360x640) AccountScreen taşma olmadan render edilir',
      (tester) async {
        tester.view.physicalSize = const Size(360, 640);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(createAccountWidget());
        await tester.pumpAndSettle();

        expect(
          find.byKey(const ValueKey('account_guest_card')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('account_favorites_button')),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      },
    );
  });
}
