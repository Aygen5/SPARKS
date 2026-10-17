import 'package:flutter/material.dart';
import 'package:sparks/app/theme/app_colors.dart';
import 'package:sparks/app/theme/app_spacing.dart';
import 'package:sparks/app/theme/app_text_styles.dart';
import 'package:sparks/core/constants/app_constants.dart';

/// SPARKS Sepet Geçici Ekranı.
/// Aşama 3 kapsamında navigasyon hedefini doğrulamak için hazırlanmış minimal ekrandır.
/// Alışveriş sepeti ve sipariş akışı sonraki aşamalarda geliştirilecektir.
class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

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
                  AppConstants.tabCart,
                  style: AppTextStyles.sectionHeading.copyWith(
                    letterSpacing: 4.0,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Alışveriş sepeti ve sipariş akışı sonraki aşamada geliştirilecektir.',
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
