import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sparks/app/theme/app_colors.dart';
import 'package:sparks/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:sparks/features/cart/presentation/cubit/cart_state.dart';
import 'package:sparks/features/navigation/presentation/sparks_bottom_nav_bar.dart';

/// SPARKS Ana Uygulama Kabuğu (MainScaffold).
///
/// StatefulShellRoute ile çalışarak 5 ana sekme (Anasayfa, Menü, Arama, Hesap, Sepet)
/// arasında geçiş yaparken alt navigasyon çubuğunun kalıcı kalmasını sağlar.
/// `CartCubit` üzerindeki toplam ürün adedini anlık dinleyerek alt navigasyon sepet
/// sayacını (`[ n ]`) dinamik olarak günceller.
class MainScaffold extends StatelessWidget {
  const MainScaffold({
    super.key,
    required this.navigationShell,
    this.cartCubit,
  });

  /// GoRouter durum bilgili navigasyon kabuğu
  final StatefulNavigationShell navigationShell;

  /// Test edilebilirlik için enjekte edilebilir CartCubit örneği
  final CartCubit? cartCubit;

  void _onTabSelected(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cubit =
        cartCubit ?? (tryReadCartCubit(context) ?? CartCubit.instance);

    return Scaffold(
      backgroundColor: AppColors.shoppingBackground,
      body: navigationShell,
      bottomNavigationBar: BlocBuilder<CartCubit, CartState>(
        bloc: cubit,
        builder: (context, state) {
          return SparksBottomNavBar(
            currentIndex: navigationShell.currentIndex,
            onTap: _onTabSelected,
            cartItemCount: state.totalItemCount,
          );
        },
      ),
    );
  }

  /// Context'ten CartCubit okumayı dener; bulunamazsa null döner
  static CartCubit? tryReadCartCubit(BuildContext context) {
    try {
      return context.read<CartCubit>();
    } catch (_) {
      return null;
    }
  }
}
