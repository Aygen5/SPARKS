import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sparks/app/router/app_router.dart';
import 'package:sparks/app/theme/app_colors.dart';
import 'package:sparks/app/theme/app_spacing.dart';
import 'package:sparks/app/theme/app_text_styles.dart';
import 'package:sparks/core/constants/app_constants.dart';
import 'package:sparks/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:sparks/features/auth/presentation/cubit/auth_state.dart';

/// SPARKS Kullanıcı Giriş Ekranı (LoginScreen).
///
/// Editoryal monokrom tasarım diline uygun olarak;
/// - Aşağıdan yukarıya kayarak tam ekran açılır.
/// - E-posta ve şifre doğrulama kontrolleri içerir.
/// - Şifre görünürlüğü açma/kapatma desteği sunar.
/// - Hataları kullanıcı dostu Türkçe açıklamalarla gösterir.
/// - `AuthCubit` üzerinden merkezi kimlik doğrulama yönetimini çalıştırır.
class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    this.authCubit,
    this.onClose,
    this.onRegisterTap,
    this.onLoginSuccess,
  });

  /// Test edilebilirlik için dışarıdan enjekte edilebilen AuthCubit örneği
  final AuthCubit? authCubit;

  /// Ekranı kapatma / geri dönme aksiyonu
  final VoidCallback? onClose;

  /// Kayıt ol ekranına geçiş aksiyonu
  final VoidCallback? onRegisterTap;

  /// Başarılı giriş sonrası geri çağrım
  final VoidCallback? onLoginSuccess;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  AuthCubit _resolveCubit(BuildContext context) {
    if (widget.authCubit != null) return widget.authCubit!;
    try {
      return context.read<AuthCubit>();
    } catch (_) {
      return AuthCubit.instance;
    }
  }

  void _handleClose() {
    if (widget.onClose != null) {
      widget.onClose!();
    } else if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.home);
    }
  }

  void _handleRegisterNavigation() {
    if (widget.onRegisterTap != null) {
      widget.onRegisterTap!();
    } else {
      context.push(AppRoutes.register);
    }
  }

  Future<void> _handleForgotPassword(AuthCubit cubit) async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Lütfen önce e-posta adresinizi yukarıdaki alana giriniz.',
          ),
          duration: Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final sent = await cubit.sendPasswordResetEmail(email: email);
    if (!mounted) return;

    if (sent) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '$email adresine parola sıfırlama bağlantısı gönderildi.',
          ),
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _submit(AuthCubit cubit) async {
    if (!_formKey.currentState!.validate()) return;

    cubit.clearError();
    final success = await cubit.signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      if (widget.onLoginSuccess != null) {
        widget.onLoginSuccess!();
      } else if (context.canPop()) {
        context.pop();
      } else {
        context.go('/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = _resolveCubit(context);

    return Scaffold(
      key: const ValueKey('login_screen'),
      backgroundColor: AppColors.shoppingBackground,
      appBar: AppBar(
        backgroundColor: AppColors.shoppingBackground,
        elevation: 0,
        leading: IconButton(
          key: const ValueKey('login_close_button'),
          icon: const Icon(Icons.close, color: AppColors.primaryText),
          onPressed: _handleClose,
        ),
        title: Text(
          AppConstants.appName,
          style: AppTextStyles.brandLogoMedium.copyWith(fontSize: 22),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: BlocConsumer<AuthCubit, AuthState>(
          bloc: cubit,
          listener: (context, state) {
            if (state.hasError && state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: AppColors.error,
                  duration: const Duration(seconds: 4),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          builder: (context, state) {
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontal,
                  vertical: AppSpacing.md,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 1. Editoryal Karşılama Başlığı
                      Text(
                        'TEKRAR HOŞ GELDİNİZ',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.sectionHeading.copyWith(
                          fontSize: 22,
                          letterSpacing: 2.0,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'GİRİŞ YAP',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.caption.copyWith(
                          letterSpacing: 3.0,
                          fontWeight: FontWeight.w700,
                          color: AppColors.secondaryText,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // Hata Banner'ı
                      if (state.hasError && state.errorMessage != null) ...[
                        Container(
                          key: const ValueKey('login_error_banner'),
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColors.shoppingBackground,
                            border: Border.all(color: AppColors.error),
                          ),
                          child: Text(
                            state.errorMessage!,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.error,
                              height: 1.4,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                      ],

                      // 2. E-posta Alanı
                      Text(
                        'E-POSTA',
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 11,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.secondaryText,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        key: const ValueKey('login_email_input'),
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        autocorrect: false,
                        enableSuggestions: false,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.primaryText,
                        ),
                        decoration: InputDecoration(
                          hintText: 'ornek@sparks.fashion',
                          hintStyle: AppTextStyles.caption.copyWith(
                            color: AppColors.secondaryText.withValues(
                              alpha: 0.6,
                            ),
                          ),
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.zero,
                            borderSide: BorderSide(
                              color: AppColors.dividerLight,
                            ),
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.zero,
                            borderSide: BorderSide(
                              color: AppColors.dividerLight,
                            ),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.zero,
                            borderSide: BorderSide(
                              color: AppColors.primaryText,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 14,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Lütfen e-posta adresinizi giriniz.';
                          }
                          final emailRegex = RegExp(
                            r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                          );
                          if (!emailRegex.hasMatch(value.trim())) {
                            return 'Geçerli bir e-posta adresi giriniz.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // 3. Şifre Alanı
                      Text(
                        'ŞİFRE',
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 11,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.secondaryText,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        key: const ValueKey('login_password_input'),
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        autocorrect: false,
                        enableSuggestions: false,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.primaryText,
                        ),
                        decoration: InputDecoration(
                          hintText: '••••••••',
                          hintStyle: AppTextStyles.caption.copyWith(
                            color: AppColors.secondaryText.withValues(
                              alpha: 0.6,
                            ),
                          ),
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.zero,
                            borderSide: BorderSide(
                              color: AppColors.dividerLight,
                            ),
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.zero,
                            borderSide: BorderSide(
                              color: AppColors.dividerLight,
                            ),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.zero,
                            borderSide: BorderSide(
                              color: AppColors.primaryText,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 14,
                          ),
                          suffixIcon: IconButton(
                            key: const ValueKey('login_password_toggle'),
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: AppColors.secondaryText,
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Lütfen şifrenizi giriniz.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.sm),

                      // 4. Beni Hatırla & Şifremi Unuttum Satırı
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: Checkbox(
                                  key: const ValueKey(
                                    'login_remember_me_checkbox',
                                  ),
                                  value: _rememberMe,
                                  activeColor: AppColors.primaryText,
                                  checkColor: AppColors.shoppingBackground,
                                  side: const BorderSide(
                                    color: AppColors.dividerLight,
                                  ),
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.zero,
                                  ),
                                  onChanged: (val) {
                                    setState(() {
                                      _rememberMe = val ?? false;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _rememberMe = !_rememberMe;
                                  });
                                },
                                child: Text(
                                  'Beni Hatırla',
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.secondaryText,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          TextButton(
                            key: const ValueKey('login_forgot_password_button'),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            onPressed: () => _handleForgotPassword(cubit),
                            child: Text(
                              'Şifremi Unuttum?',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.secondaryText,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // 5. Giriş Yap Butonu
                      ElevatedButton(
                        key: const ValueKey('login_submit_button'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryText,
                          foregroundColor: AppColors.shoppingBackground,
                          elevation: 0,
                          minimumSize: const Size(double.infinity, 52),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                        ),
                        onPressed: state.isLoading
                            ? null
                            : () => _submit(cubit),
                        child: state.isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 1.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.shoppingBackground,
                                  ),
                                ),
                              )
                            : Text(
                                'GİRİŞ YAP',
                                style: AppTextStyles.buttonText,
                              ),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // 6. Kayıt Ol Bağlantısı
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Hesabınız yok mu?',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.secondaryText,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          GestureDetector(
                            key: const ValueKey('login_to_register_button'),
                            onTap: _handleRegisterNavigation,
                            child: Text(
                              'KAYIT OL',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.primaryText,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.2,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
