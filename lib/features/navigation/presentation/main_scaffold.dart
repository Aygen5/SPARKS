import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sparks/app/theme/app_colors.dart';
import 'package:sparks/features/navigation/presentation/sparks_bottom_nav_bar.dart';

/// SPARKS Ana Uygulama Kabuğu (MainScaffold).
///
/// StatefulShellRoute ile çalışarak 5 ana sekme (Anasayfa, Menü, Arama, Hesap, Sepet)
/// arasında geçiş yaparken alt navigasyon çubuğunun kalıcı kalmasını sağlar.
/// Sekmelerin kendi iç durumları ve kaydırma pozisyonları korunur.
class MainScaffold extends StatelessWidget {
  const MainScaffold({super.key, required this.navigationShell});

  /// GoRouter durum bilgili navigasyon kabuğu
  final StatefulNavigationShell navigationShell;

  void _onTabSelected(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.shoppingBackground,
      body: navigationShell,
      bottomNavigationBar: SparksBottomNavBar(
        currentIndex: navigationShell.currentIndex,
        onTap: _onTabSelected,
      ),
    );
  }
}
