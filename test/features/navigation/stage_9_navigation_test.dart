import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sparks/app/app.dart';
import 'package:sparks/app/router/app_router.dart';
import 'package:sparks/features/account/presentation/account_screen.dart';
import 'package:sparks/features/favorites/presentation/favorites_screen.dart';
import 'package:sparks/features/orders/presentation/orders_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  group('Aşama 9 — Navigasyon ve Ekran Geçiş Testleri', () {
    setUp(() {
      AppRouter.reset(initialLocation: AppRoutes.account);
    });

    testWidgets('1. GoRouter /account rotasında AccountScreen açılır', (
      tester,
    ) async {
      await tester.pumpWidget(const SparksApp());
      await tester.pumpAndSettle();

      expect(find.byType(AccountScreen), findsOneWidget);
    });

    testWidgets(
      '2. AccountScreen üzerinden FAVORİLERİM tıklandığında /favorites rotasına gidilir ve geri dönülebilir',
      (tester) async {
        await tester.pumpWidget(const SparksApp());
        await tester.pumpAndSettle();

        expect(find.byType(AccountScreen), findsOneWidget);

        // FAVORİLERİM kısayoluna tıkla
        await tester.tap(
          find.byKey(const ValueKey('account_favorites_button')),
        );
        await tester.pumpAndSettle();

        expect(find.byType(FavoritesScreen), findsOneWidget);
        expect(
          find.byKey(const ValueKey('favorites_back_button')),
          findsOneWidget,
        );

        // Geri butonuna dokun
        await tester.tap(find.byKey(const ValueKey('favorites_back_button')));
        await tester.pumpAndSettle();

        expect(find.byType(AccountScreen), findsOneWidget);
      },
    );

    testWidgets(
      '3. AccountScreen üzerinden ALIŞVERİŞLERİM tıklandığında /account/orders rotasına gidilir ve geri dönülebilir',
      (tester) async {
        await tester.pumpWidget(const SparksApp());
        await tester.pumpAndSettle();

        expect(find.byType(AccountScreen), findsOneWidget);

        // ALIŞVERİŞLERİM kısayoluna tıkla
        await tester.tap(find.byKey(const ValueKey('account_orders_button')));
        await tester.pumpAndSettle();

        expect(find.byType(OrdersScreen), findsOneWidget);
        expect(
          find.byKey(const ValueKey('orders_back_button')),
          findsOneWidget,
        );

        // Geri butonuna dokun
        await tester.tap(find.byKey(const ValueKey('orders_back_button')));
        await tester.pumpAndSettle();

        expect(find.byType(AccountScreen), findsOneWidget);
      },
    );
  });
}
