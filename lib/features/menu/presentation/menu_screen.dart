import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sparks/app/router/app_router.dart';
import 'package:sparks/app/theme/app_colors.dart';
import 'package:sparks/app/theme/app_spacing.dart';
import 'package:sparks/app/theme/app_text_styles.dart';
import 'package:sparks/core/constants/app_constants.dart';
import 'package:sparks/features/menu/data/menu_data.dart';
import 'package:sparks/features/menu/domain/entities/menu_item.dart';

/// SPARKS İki Sütunlu Editoryal Menü Ekranı.
///
/// Üst Bölüm:
/// - KADIN / ERKEK reyon sekmeleri (Playfair Display serif tipografisi).
///
/// Gövde Bölümü (İki Sütunlu Editoryal Düzen):
/// - Sol Sütun: Numaralandırılmış ana kategori başlıkları (|01| YENİ ÜRÜNLER, vb.).
/// - Sağ Sütun: Alt kategoriler (THE NEW, KABAN | MONT, CEKET, vb.).
///
/// Bir kategoriye dokunulduğunda cinsiyet ve kategori bağlamı `/catalog` rotasına aktarılır.
class MenuScreen extends StatefulWidget {
  const MenuScreen({
    super.key,
    this.initialGender = AppConstants.genderWomen,
    this.onCategoryTap,
  });

  /// Başlangıçta seçili cinsiyet ("KADIN" veya "ERKEK")
  final String initialGender;

  /// Kategoriye dokunulduğunda çalışacak isteğe bağlı geri çağrım (Testler veya özel yönlendirmeler için)
  final void Function(String gender, String category)? onCategoryTap;

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  late String _selectedGender;

  @override
  void initState() {
    super.initState();
    _selectedGender = widget.initialGender;
  }

  void _selectGender(String gender) {
    if (_selectedGender != gender) {
      setState(() {
        _selectedGender = gender;
      });
    }
  }

  void _handleCategoryTap(String categoryTitle) {
    if (widget.onCategoryTap != null) {
      widget.onCategoryTap!(_selectedGender, categoryTitle);
    } else {
      // GoRouter üzerinden katalog geçiş ekranına yönlendir
      final uri = Uri(
        path: AppRoutes.catalog,
        queryParameters: {'gender': _selectedGender, 'category': categoryTitle},
      );
      context.push(uri.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final sections = MenuData.getSectionsForGender(_selectedGender);

    return Scaffold(
      backgroundColor: AppColors.shoppingBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Üst Bölüm: KADIN / ERKEK Editoryal Sekmeleri
            _GenderTabsHeader(
              selectedGender: _selectedGender,
              onGenderSelected: _selectGender,
            ),

            const SizedBox(height: AppSpacing.sm),

            // 2. İki Sütunlu Kategori Listesi (Dikey Kaydırılabilir)
            Expanded(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontal,
                  vertical: AppSpacing.md,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < sections.length; i++) ...[
                      _MenuSectionRow(
                        section: sections[i],
                        onCategoryTap: _handleCategoryTap,
                      ),
                      if (i < sections.length - 1)
                        const SizedBox(height: AppSpacing.xl),
                    ],
                    // Alt navigasyon çubuğu için ilave alt nefes payı
                    const SizedBox(height: AppSpacing.lg),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// KADIN / ERKEK reyon seçim sekmelerini yöneten üst başlık bileşeni.
class _GenderTabsHeader extends StatelessWidget {
  const _GenderTabsHeader({
    required this.selectedGender,
    required this.onGenderSelected,
  });

  final String selectedGender;
  final ValueChanged<String> onGenderSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.shoppingBackground,
        border: Border(
          bottom: BorderSide(
            color: AppColors.divider,
            width: AppSpacing.borderWidth,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
      ),
      child: Row(
        children: [
          // KADIN Sekmesi
          _GenderTabItem(
            key: const ValueKey('menu_tab_KADIN'),
            title: AppConstants.genderWomen,
            isSelected: selectedGender == AppConstants.genderWomen,
            onTap: () => onGenderSelected(AppConstants.genderWomen),
          ),
          const SizedBox(width: AppSpacing.xl),

          // ERKEK Sekmesi
          _GenderTabItem(
            key: const ValueKey('menu_tab_ERKEK'),
            title: AppConstants.genderMen,
            isSelected: selectedGender == AppConstants.genderMen,
            onTap: () => onGenderSelected(AppConstants.genderMen),
          ),
        ],
      ),
    );
  }
}

/// Tek bir cinsiyet sekme öğesi (Playfair Display serif ve aktif alt çizgi).
class _GenderTabItem extends StatelessWidget {
  const _GenderTabItem({
    super.key,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTextStyles.sectionHeading.copyWith(
                fontSize: 20,
                color: isSelected
                    ? AppColors.primaryText
                    : AppColors.secondaryText,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            // Aktif sekme alt çizgisi
            AnimatedContainer(
              key: isSelected ? const ValueKey('active_tab_indicator') : null,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              height: 2.0,
              width: 32.0,
              color: isSelected ? AppColors.primaryText : Colors.transparent,
            ),
          ],
        ),
      ),
    );
  }
}

/// Tek bir bölümün sol (ana grup) ve sağ (alt kategoriler) sütun yerleşimi.
class _MenuSectionRow extends StatelessWidget {
  const _MenuSectionRow({required this.section, required this.onCategoryTap});

  final MenuSection section;
  final ValueChanged<String> onCategoryTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sol Sütun: Numaralandırılmış Ana Grup Başlığı
        SizedBox(
          width: 130,
          child: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(section.headerDisplay, style: AppTextStyles.menuGroup),
          ),
        ),

        const SizedBox(width: AppSpacing.md),

        // Sağ Sütun: Alt Kategoriler Listesi
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final item in section.items)
                _MenuCategoryRowItem(
                  item: item,
                  onTap: () => onCategoryTap(item.title),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Sağ sütundaki tek bir tıklanabilir alt kategori satırı.
class _MenuCategoryRowItem extends StatelessWidget {
  const _MenuCategoryRowItem({required this.item, required this.onTap});

  final MenuCategoryItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: ValueKey('menu_item_${item.id}'),
      onTap: onTap,
      splashColor: Colors.white.withValues(alpha: 0.05),
      highlightColor: Colors.white.withValues(alpha: 0.03),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: SizedBox(
          width: double.infinity,
          child: Text(item.title, style: AppTextStyles.menuItem),
        ),
      ),
    );
  }
}
