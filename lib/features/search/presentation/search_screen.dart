import 'package:flutter/material.dart';
import 'package:sparks/app/theme/app_colors.dart';
import 'package:sparks/app/theme/app_spacing.dart';
import 'package:sparks/app/theme/app_text_styles.dart';
import 'package:sparks/core/constants/app_constants.dart';

/// SPARKS Arama Geçici Ekranı.
/// Aşama 3 kapsamında navigasyon hedefini doğrulamak için hazırlanmış minimal ekrandır.
/// Arama çubuğu ve öneriler sonraki aşamalarda geliştirilecektir.
class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.shoppingBackground,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenHorizontal,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppConstants.tabSearch,
                  style: AppTextStyles.sectionHeading.copyWith(
                    letterSpacing: 4.0,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Arama ve keşif işlevi sonraki aşamada geliştirilecektir.',
                  style: AppTextStyles.caption,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
