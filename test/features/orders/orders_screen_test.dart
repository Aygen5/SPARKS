import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sparks/app/theme/app_theme.dart';
import 'package:sparks/features/orders/presentation/orders_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  Widget createOrdersWidget({
    VoidCallback? onCatalogNavigate,
    VoidCallback? onCartNavigate,
  }) {
    return MaterialApp(
      theme: AppTheme.darkTheme,
      home: OrdersScreen(
        onCatalogNavigate: onCatalogNavigate,
        onCartNavigate: onCartNavigate,
      ),
    );
  }

  group('Aşama 9 — Alışverişlerim Ekranı (OrdersScreen) Testleri', () {
    testWidgets('1. Alışverişlerim ekranı hatasız açılır ve başlığı gösterir', (
      tester,
    ) async {
      await tester.pumpWidget(createOrdersWidget());
      await tester.pumpAndSettle();

      expect(find.text('ALIŞVERİŞLERİM'), findsOneWidget);
      expect(find.byKey(const ValueKey('orders_empty_state')), findsOneWidget);
    });

    testWidgets(
      '2. Gerçek sipariş altyapısı bulunmadığından dürüst boş durum ve açıklama gösterilir',
      (tester) async {
        await tester.pumpWidget(createOrdersWidget());
        await tester.pumpAndSettle();

        expect(find.text('HENÜZ BİR SİPARİŞİNİZ YOK'), findsOneWidget);
        expect(
          find.textContaining(
            'sipariş ve ödeme altyapısının tamamlanması gerekmektedir',
          ),
          findsOneWidget,
        );

        // Sahte sipariş numarası, uydurma kargo takibi veya sahte tutar olmamalı
        expect(find.text('SIP-12345'), findsNothing);
        expect(find.text('Kargoda'), findsNothing);
      },
    );

    testWidgets('3. KATALOĞA DÖN butonu doğru geri çağrımı tetikler', (
      tester,
    ) async {
      bool catalogNavigated = false;

      await tester.pumpWidget(
        createOrdersWidget(onCatalogNavigate: () => catalogNavigated = true),
      );
      await tester.pumpAndSettle();

      final catalogBtn = find.byKey(const ValueKey('orders_catalog_button'));
      expect(catalogBtn, findsOneWidget);
      expect(find.text('KATALOĞA DÖN'), findsOneWidget);

      await tester.tap(catalogBtn);
      await tester.pumpAndSettle();

      expect(catalogNavigated, isTrue);
    });

    testWidgets('4. SEPETE GİT butonu doğru geri çağrımı tetikler', (
      tester,
    ) async {
      bool cartNavigated = false;

      await tester.pumpWidget(
        createOrdersWidget(onCartNavigate: () => cartNavigated = true),
      );
      await tester.pumpAndSettle();

      final cartBtn = find.byKey(const ValueKey('orders_cart_button'));
      expect(cartBtn, findsOneWidget);
      expect(find.text('SEPETE GİT'), findsOneWidget);

      await tester.tap(cartBtn);
      await tester.pumpAndSettle();

      expect(cartNavigated, isTrue);
    });

    testWidgets(
      '5. Dar ekran boyutlarında (360x640) OrdersScreen taşma olmadan render edilir',
      (tester) async {
        tester.view.physicalSize = const Size(360, 640);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(createOrdersWidget());
        await tester.pumpAndSettle();

        expect(
          find.byKey(const ValueKey('orders_empty_state')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('orders_catalog_button')),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      },
    );
  });
}
