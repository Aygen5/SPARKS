import 'package:flutter/material.dart';
import 'package:sparks/app/theme/app_colors.dart';
import 'package:sparks/app/theme/app_spacing.dart';
import 'package:sparks/app/theme/app_text_styles.dart';
import 'package:sparks/core/constants/app_constants.dart';

/// SPARKS 5 Sekmeli Kalıcı Alt Navigasyon Çubuğu (Bottom Navigation Bar).
///
/// Sıralama:
/// 1. Anasayfa (İkon + "Anasayfa")
/// 2. MENÜ (İkonsuz, yalnızca "MENÜ")
/// 3. Arama (İkon + "Arama")
/// 4. HESAP (İkonsuz, yalnızca "HESAP")
/// 5. Sepet (İkon + "[ 0 ]" minimal sepet gösterimi)
///
/// Tasarım İlkeleri:
/// - Tam siyah arka plan (#000000).
/// - Aktif sekmenin altında küçük beyaz nokta indikatörü.
/// - Sıfır border radius, keskin köşeli editoryal yapı.
/// - Üstte 1px ince ayırıcı çizgi (divider).
/// - Küçük ekranlarda taşma yapmayan esnek ve dokunulabilir alanlar.
class SparksBottomNavBar extends StatelessWidget {
  const SparksBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.cartItemCount = 0,
  });

  /// Seçili aktif sekme indeksi (0: Anasayfa, 1: Menü, 2: Arama, 3: Hesap, 4: Sepet)
  final int currentIndex;

  /// Sekmeye dokunulduğunda tetiklenen geri çağrım
  final ValueChanged<int> onTap;

  /// Sepetteki güncel ürün adedi (Aşama 3'te varsayılan 0)
  final int cartItemCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.shoppingBackground,
        border: Border(
          top: BorderSide(
            color: AppColors.divider,
            width: AppSpacing.borderWidth,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: AppSpacing.bottomBarHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Sekme: Anasayfa (İkon + Anasayfa)
              Expanded(
                child: _NavBarItem(
                  key: const ValueKey('nav_tab_home'),
                  index: 0,
                  isSelected: currentIndex == 0,
                  label: AppConstants.tabHome,
                  icon: Icons.home_outlined,
                  onTap: () => onTap(0),
                ),
              ),

              // 2. Sekme: MENÜ (İkonsuz, yalnızca metin)
              Expanded(
                child: _NavBarItem(
                  key: const ValueKey('nav_tab_menu'),
                  index: 1,
                  isSelected: currentIndex == 1,
                  label: AppConstants.tabMenu,
                  icon: null,
                  onTap: () => onTap(1),
                ),
              ),

              // 3. Sekme: Arama (İkon + Arama)
              Expanded(
                child: _NavBarItem(
                  key: const ValueKey('nav_tab_search'),
                  index: 2,
                  isSelected: currentIndex == 2,
                  label: AppConstants.tabSearch,
                  icon: Icons.search,
                  onTap: () => onTap(2),
                ),
              ),

              // 4. Sekme: HESAP (İkonsuz, yalnızca metin)
              Expanded(
                child: _NavBarItem(
                  key: const ValueKey('nav_tab_account'),
                  index: 3,
                  isSelected: currentIndex == 3,
                  label: AppConstants.tabAccount,
                  icon: null,
                  onTap: () => onTap(3),
                ),
              ),

              // 5. Sekme: Sepet (İkon + [ 0 ])
              Expanded(
                child: _NavBarItem(
                  key: const ValueKey('nav_tab_cart'),
                  index: 4,
                  isSelected: currentIndex == 4,
                  label: '[ $cartItemCount ]',
                  icon: Icons.shopping_bag_outlined,
                  onTap: () => onTap(4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Alt navigasyon çubuğu içindeki tek bir sekme öğesi.
class _NavBarItem extends StatelessWidget {
  const _NavBarItem({
    super.key,
    required this.index,
    required this.isSelected,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final int index;
  final bool isSelected;
  final String label;
  final IconData? icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final itemColor = isSelected
        ? AppColors.primaryText
        : AppColors.secondaryText;
    final fontWeight = isSelected ? FontWeight.w600 : FontWeight.w400;

    return InkWell(
      onTap: onTap,
      splashColor: Colors.white.withValues(alpha: 0.05),
      highlightColor: Colors.white.withValues(alpha: 0.03),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // İkon veya Metin İçerik Alanı (Sabit 32px yükseklik dikey hizalamayı dengeler)
            SizedBox(
              height: 32,
              child: Center(
                child: icon != null
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(icon, size: 18, color: itemColor),
                          const SizedBox(height: 2),
                          Text(
                            label,
                            style: AppTextStyles.caption.copyWith(
                              fontSize: 10,
                              fontWeight: fontWeight,
                              letterSpacing: 0.5,
                              color: itemColor,
                              height: 1.0,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      )
                    : Text(
                        label,
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 11,
                          fontWeight: fontWeight,
                          letterSpacing: 1.2,
                          color: itemColor,
                          height: 1.0,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
              ),
            ),

            const SizedBox(height: AppSpacing.xs),

            // Aktif Sekme Göstergesi (Seçili sekmenin altındaki beyaz nokta)
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              width: AppSpacing.activeIndicatorSize,
              height: AppSpacing.activeIndicatorSize,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.activeIndicator
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
