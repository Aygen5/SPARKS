import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sparks/app/router/app_router.dart';
import 'package:sparks/app/theme/app_theme.dart';
import 'package:sparks/core/constants/app_constants.dart';
import 'package:sparks/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:sparks/features/cart/presentation/cubit/cart_cubit.dart';

/// SPARKS uygulamasının kök widget'ı.
/// `MultiBlocProvider` ile merkezi `CartCubit` ve `AuthCubit`'i tüm uygulama ağacına sunar;
/// MaterialApp.router ile GoRouter ve monokrom editoryal temayı bir araya getirir.
class SparksApp extends StatelessWidget {
  const SparksApp({
    super.key,
    this.routerConfig,
    this.cartCubit,
    this.authCubit,
  });

  final RouterConfig<Object>? routerConfig;
  final CartCubit? cartCubit;
  final AuthCubit? authCubit;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<CartCubit>.value(value: cartCubit ?? CartCubit.instance),
        BlocProvider<AuthCubit>.value(value: authCubit ?? AuthCubit.instance),
      ],
      child: MaterialApp.router(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.dark,
        routerConfig: routerConfig ?? AppRouter.router,
      ),
    );
  }
}
