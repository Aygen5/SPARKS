import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sparks/app/router/app_router.dart';
import 'package:sparks/app/theme/app_theme.dart';
import 'package:sparks/core/constants/app_constants.dart';
import 'package:sparks/features/catalog/presentation/catalog_placeholder_screen.dart';
import 'package:sparks/features/menu/data/menu_data.dart';
import 'package:sparks/features/menu/presentation/menu_screen.dart';

void main() {
  setUpAll(() {
    // Test ortamında çalışma zamanı font indirme isteğini kapat
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Widget buildTestableWidget({
    void Function(String gender, String category)? onCategoryTap,
    String initialGender = AppConstants.genderWomen,
  }) {
    return MaterialApp(
      theme: AppTheme.darkTheme,
      home: Scaffold(
        body: MenuScreen(
          onCategoryTap: onCategoryTap,
          initialGender: initialGender,
        ),
      ),
    );
  }

  group('Aşama 5 — İki Sütunlu Editoryal Menü ve Kategori Akışı Testleri', () {
    testWidgets(
      '1. MenuScreen açıldığında varsayılan olarak KADIN sekmesi aktiftir',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildTestableWidget());
        await tester.pumpAndSettle();

        // KADIN ve ERKEK sekmeleri mevcut
        expect(find.text('KADIN'), findsOneWidget);
        expect(find.text('ERKEK'), findsOneWidget);

        // Varsayılan olarak KADIN sekmesi seçili ve alt çizgi göstergesi mevcut
        expect(
          find.byKey(const ValueKey('active_tab_indicator')),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      '2. Sol sütunda |01| YENİ ÜRÜNLER, |02| KOLEKSİYON, |03| AYAKKABI | AKSESUAR başlıkları görünür',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildTestableWidget());
        await tester.pumpAndSettle();

        expect(find.text('|01| YENİ ÜRÜNLER'), findsOneWidget);
        expect(find.text('|02| KOLEKSİYON'), findsOneWidget);
        expect(find.text('|03| AYAKKABI | AKSESUAR'), findsOneWidget);
      },
    );

    testWidgets(
      '3. KADIN kategorisinde THE NEW, CEKET, ETEK, TOP | BODY, ÇANTA öğeleri mevcuttur',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildTestableWidget());
        await tester.pumpAndSettle();

        expect(find.text('THE NEW'), findsOneWidget);
        expect(find.text('CEKET'), findsOneWidget);
        expect(find.text('ETEK'), findsOneWidget);
        expect(find.text('TOP | BODY'), findsOneWidget);
        expect(find.text('ÇANTA'), findsOneWidget);
        expect(find.text('KABAN | MONT'), findsOneWidget);
        expect(find.text('PANTOLON'), findsOneWidget);
      },
    );

    testWidgets(
      '4. ERKEK sekmesine tıklandığında sekme aktifleşir ve ETEK, TOP | BODY, ÇANTA kaybolur',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildTestableWidget());
        await tester.pumpAndSettle();

        // Başlangıçta kadın kategorileri mevcut
        expect(find.text('ETEK'), findsOneWidget);
        expect(find.text('TOP | BODY'), findsOneWidget);
        expect(find.text('ÇANTA'), findsOneWidget);

        // ERKEK sekmesine tıkla
        await tester.tap(find.byKey(const ValueKey('menu_tab_ERKEK')));
        await tester.pumpAndSettle();

        // ERKEK sekmesinde kadın kategorileri bulunmamalı
        expect(find.text('ETEK'), findsNothing);
        expect(find.text('TOP | BODY'), findsNothing);
        expect(find.text('ÇANTA'), findsNothing);

        // Erkek kategorisinde ortak parçalar hala bulunmalı
        expect(find.text('THE NEW'), findsOneWidget);
        expect(find.text('CEKET'), findsOneWidget);
        expect(find.text('PANTOLON'), findsOneWidget);
        expect(find.text('KAZAK | HIRKA'), findsOneWidget);

        // Sol sütun başlıkları erkekte de tutarlılıkla görünmeli
        expect(find.text('|01| YENİ ÜRÜNLER'), findsOneWidget);
        expect(find.text('|02| KOLEKSİYON'), findsOneWidget);
        expect(find.text('|03| AYAKKABI | AKSESUAR'), findsOneWidget);
      },
    );

    testWidgets(
      '5. Bir kategoriye tıklandığında onCategoryTap callback doğru parametrelerle tetiklenir',
      (WidgetTester tester) async {
        String? selectedGender;
        String? selectedCategory;

        await tester.pumpWidget(
          buildTestableWidget(
            onCategoryTap: (gender, category) {
              selectedGender = gender;
              selectedCategory = category;
            },
          ),
        );
        await tester.pumpAndSettle();

        // CEKET kategorisine tıkla
        await tester.tap(find.text('CEKET'));
        await tester.pumpAndSettle();

        expect(selectedGender, 'KADIN');
        expect(selectedCategory, 'CEKET');
      },
    );

    testWidgets(
      '6. GoRouter entegrasyonunda kategori tıklandığında CatalogPlaceholderScreen açılır',
      (WidgetTester tester) async {
        AppRouter.reset(initialLocation: AppRoutes.menu);

        await tester.pumpWidget(
          MaterialApp.router(
            theme: AppTheme.darkTheme,
            routerConfig: AppRouter.router,
          ),
        );
        await tester.pumpAndSettle();

        // Menü ekranında KADIN sekmesi ve CEKET görünmeli
        expect(find.text('CEKET'), findsOneWidget);

        // CEKET öğesine tıkla -> router üzerinden CatalogPlaceholderScreen'e gitmeli
        await tester.tap(find.text('CEKET'));
        await tester.pumpAndSettle();

        // CatalogPlaceholderScreen açılmalı ve başlık ile cinsiyet gösterilmeli
        expect(find.byType(CatalogPlaceholderScreen), findsOneWidget);
        expect(find.text('CEKET'), findsWidgets);
        expect(find.text('KADIN'), findsOneWidget);

        // Geri butonuna basıldığında Menü ekranına geri dönmeli
        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();

        expect(find.byType(MenuScreen), findsOneWidget);
      },
    );

    testWidgets(
      '7. Dar ekran boyutlarında (360x640) MenuScreen taşma olmadan render edilir',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(360, 640);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(buildTestableWidget());
        await tester.pumpAndSettle();

        expect(find.byType(MenuScreen), findsOneWidget);
        expect(find.text('KADIN'), findsOneWidget);
        expect(find.text('ERKEK'), findsOneWidget);
        expect(find.text('|01| YENİ ÜRÜNLER'), findsOneWidget);
      },
    );

    testWidgets(
      '8. MenuData veri modeli bütünlüğü ve bölüm sayıları doğrulanır',
      (WidgetTester tester) async {
        final womenSections = MenuData.womenSections;
        final menSections = MenuData.menSections;

        expect(womenSections.length, 3);
        expect(menSections.length, 3);

        // Kadın toplam kategori sayısı: 1 + 7 + 2 = 10
        final womenCount = womenSections.fold<int>(
          0,
          (sum, s) => sum + s.items.length,
        );
        expect(womenCount, 10);

        // Erkek toplam kategori sayısı: 1 + 5 + 1 = 7
        final menCount = menSections.fold<int>(
          0,
          (sum, s) => sum + s.items.length,
        );
        expect(menCount, 7);
      },
    );
  });
}
