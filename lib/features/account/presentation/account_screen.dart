import 'package:flutter/material.dart';
import 'package:sparks/app/theme/app_colors.dart';
import 'package:sparks/app/theme/app_spacing.dart';
import 'package:sparks/app/theme/app_text_styles.dart';
import 'package:sparks/core/constants/app_constants.dart';

/// SPARKS Hesap Geçici Ekranı.
/// Aşama 3 kapsamında navigasyon hedefini doğrulamak için hazırlanmış minimal ekrandır.
/// Kullanıcı profili ve siparişler sonraki aşamalarda geliştirilecektir.
class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

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
                  AppConstants.tabAccount,
                  style: AppTextStyles.sectionHeading.copyWith(
                    letterSpacing: 4.0,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Kullanıcı hesabı ve profil özellikleri sonraki aşamada geliştirilecektir.',
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
