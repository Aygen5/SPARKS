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

void main() {
  setUpAll(() {
    // Test ortamında çalışma zamanı font indirme isteğini kapat ve sistem fallback fontlarını kullan
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('Aşama 1 — Tasarım Sistemi ve Temel Tema Testleri', () {
    setUp(() {
      AppRouter.reset(initialLocation: AppRoutes.root);
    });

    test(
      '1. Renk sistemi beklenen editoryal ve alışveriş değerlerine sahiptir',
      () {
        // Editoryal renkler
        expect(AppColors.editorialCream, const Color(0xFFFDFBF7));
        expect(AppColors.editorialBeige, const Color(0xFFE8E1D5));
        expect(AppColors.editorialStone, const Color(0xFFD9D2C7));
        expect(AppColors.editorialBrown, const Color(0xFF5A3E2B));
        expect(AppColors.editorialAnthracite, const Color(0xFF222222));

        // Alışveriş renkleri
        expect(AppColors.shoppingBackground, const Color(0xFF000000));
        expect(AppColors.primaryText, const Color(0xFFFFFFFF));
        expect(AppColors.secondaryText, const Color(0xFF8E8E8E));
        expect(AppColors.divider, const Color(0xFF1F1F1F));
      },
    );

    test('2. Keskin köşe ilkesi (0 radius) ve boşluk sabitleri doğrulanır', () {
      expect(AppSpacing.buttonRadius, 0.0);
      expect(AppSpacing.cardRadius, 0.0);
      expect(AppSpacing.dialogRadius, 0.0);
      expect(AppSpacing.borderWidth, 1.0);
      expect(AppSpacing.buttonHeight, 52.0);
      expect(AppSpacing.bottomBarHeight, 64.0);
    });

    test('3. Editoryal görsel URL sabitleri eksiksiz ve doğrudur', () {
      expect(AppImages.splashBackground, isNotEmpty);
      expect(AppImages.homeLookbookImages.length, 4);
      expect(AppImages.homeLook1, isNotEmpty);
      expect(AppImages.homeLook2, isNotEmpty);
      expect(AppImages.homeLook3, isNotEmpty);
      expect(AppImages.homeLook4, isNotEmpty);
    });

    test('4. Tipografi hiyerarşisi serif ve sans-serif stillerini içerir', () {
      expect(AppTextStyles.brandLogoLarge.fontSize, 42);
      expect(AppTextStyles.sectionHeading.fontSize, 24);
      expect(AppTextStyles.menuGroup.fontSize, 11);
      expect(AppTextStyles.menuItem.fontSize, 13);
      expect(AppTextStyles.productTitle.fontSize, 13);
      expect(AppTextStyles.productPrice.fontSize, 14);
      expect(AppTextStyles.buttonText.fontSize, 12);
    });

    test(
      '5. Material 3 teması keskin köşeli butonları ve siyah zemini yönetir',
      () {
        final theme = AppTheme.darkTheme;

        expect(theme.useMaterial3, isTrue);
        expect(theme.brightness, Brightness.dark);
        expect(theme.scaffoldBackgroundColor, AppColors.shoppingBackground);
        expect(theme.colorScheme.surface, AppColors.shoppingBackground);
        expect(theme.colorScheme.primary, AppColors.primaryText);

        // Buton temalarının keskin köşeli (zero radius) olduğunu doğrula
        final elevatedShape = theme.elevatedButtonTheme.style?.shape?.resolve(
          {},
        );
        expect(elevatedShape, isA<RoundedRectangleBorder>());
        expect(
          (elevatedShape as RoundedRectangleBorder).borderRadius,
          BorderRadius.zero,
        );

        final outlinedShape = theme.outlinedButtonTheme.style?.shape?.resolve(
          {},
        );
        expect(outlinedShape, isA<RoundedRectangleBorder>());
        expect(
          (outlinedShape as RoundedRectangleBorder).borderRadius,
          BorderRadius.zero,
        );
      },
    );

    testWidgets(
      '6. SparksApp kök widget olarak hatasız açılır ve marka adını gösterir',
      (WidgetTester tester) async {
        await tester.pumpWidget(const SparksApp());
        await tester.pumpAndSettle();

        expect(find.text(AppConstants.appName), findsOneWidget);
      },
    );
  });
}
