import 'package:flutter/material.dart';
import 'package:sparks/app/router/app_router.dart';
import 'package:sparks/app/theme/app_theme.dart';
import 'package:sparks/core/constants/app_constants.dart';

/// SPARKS uygulamasının kök widget'ı.
/// MaterialApp.router ile GoRouter ve monokrom editoryal temayı bir araya getirir.
class SparksApp extends StatelessWidget {
  const SparksApp({super.key, this.routerConfig});

  final RouterConfig<Object>? routerConfig;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      routerConfig: routerConfig ?? AppRouter.router,
    );
  }
}
