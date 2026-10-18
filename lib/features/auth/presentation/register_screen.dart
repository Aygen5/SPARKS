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

/// SPARKS Kayıt Ol (Register) Ekranı.
///
/// Editoryal, minimalist ve monokromatik moda tasarım diline sadık kalınarak
/// geliştirilmiştir.
///
/// Form Alanları:
/// 1. Ad Soyad (`register_name_input`)
/// 2. E-posta (`register_email_input`)
/// 3. Şifre (`register_password_input`) + Görünürlük butonu (`register_password_toggle`)
/// 4. Şifre Tekrar (`register_password_repeat_input`) + Görünürlük butonu (`register_password_repeat_toggle`)
/// 5. Kullanım Koşulları & Gizlilik Onayı (`register_terms_checkbox`)
/// 6. Kayıt Ol Butonu (`register_submit_button`)
/// 7. Giriş Yap Bağlantısı (`register_to_login_button`)
/// 8. Kapatma Butonu (`register_close_button`)
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({
    super.key,
    this.authCubit,
    this.onClose,
    this.onLoginTap,
    this.onRegisterSuccess,
  });

  /// Test edilebilirlik için dışarıdan enjekte edilebilen AuthCubit örneği
  final AuthCubit? authCubit;

  /// Kapatma butonuna dokunulduğunda çağrılır
  final VoidCallback? onClose;

  /// "Zaten hesabınız var mı? Giriş Yap" bağlantısına dokunulduğunda çağrılır
  final VoidCallback? onLoginTap;

  /// Kayıt başarılı olduğunda çağrılır
  final VoidCallback? onRegisterSuccess;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _passwordRepeatController;

  bool _obscurePassword = true;
  bool _obscurePasswordRepeat = true;
  bool _termsAccepted = false;
  bool _termsError = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _passwordRepeatController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordRepeatController.dispose();
    super.dispose();
  }

  AuthCubit _resolveAuthCubit(BuildContext context) {
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

  void _handleLoginNavigation() {
    if (widget.onLoginTap != null) {
      widget.onLoginTap!();
    } else if (context.canPop()) {
      context.pushReplacement(AppRoutes.login);
    } else {
      context.go(AppRoutes.login);
    }
  }

  Future<void> _submitRegister(AuthCubit cubit) async {
    setState(() {
      _termsError = !_termsAccepted;
    });

    final isFormValid = _formKey.currentState?.validate() ?? false;
    if (!isFormValid || !_termsAccepted) {
      return;
    }

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    final success = await cubit.signUp(
      email: email,
      password: password,
      displayName: name,
    );

    if (success && mounted) {
      if (widget.onRegisterSuccess != null) {
        widget.onRegisterSuccess!();
      } else if (context.canPop()) {
        context.pop();
      } else {
        context.go(AppRoutes.home);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = _resolveAuthCubit(context);

    return Scaffold(
      key: const ValueKey('register_screen'),
      backgroundColor: AppColors.shoppingBackground,
      body: SafeArea(
        child: BlocConsumer<AuthCubit, AuthState>(
          bloc: cubit,
          listener: (context, state) {
            if (state.isAuthenticated && widget.onRegisterSuccess != null) {
              widget.onRegisterSuccess!();
            }
          },
          builder: (context, authState) {
            final isLoading = authState.isLoading;
            final errorMessage = authState.errorMessage;

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  children: [
                    // Üst Bar: Kapat Butonu
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.screenHorizontal,
                        vertical: AppSpacing.sm,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            key: const ValueKey('register_close_button'),
                            icon: const Icon(
                              Icons.close,
                              color: AppColors.primaryText,
                              size: 26,
                            ),
                            tooltip: 'Kapat',
                            onPressed: _handleClose,
                          ),
                        ],
                      ),
                    ),

                    // Kaydırılabilir Form İçeriği
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.screenHorizontal,
                        ),
                        physics: const BouncingScrollPhysics(),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: AppSpacing.xs),

                              // SPARKS Logo
                              Center(
                                child: Text(
                                  AppConstants.appName,
                                  style: AppTextStyles.brandLogoLarge.copyWith(
                                    fontSize: 38,
                                    letterSpacing: 6.0,
                                    color: AppColors.primaryText,
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xs),

                              // Alt Başlık / Editoryal Karşılama
                              Center(
                                child: Text(
                                  'HESAP OLUŞTUR',
                                  style: AppTextStyles.sectionHeading.copyWith(
                                    fontSize: 16,
                                    letterSpacing: 3.0,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primaryText,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Center(
                                child: Text(
                                  'Özel editoryal moda dünyasını keşfetmek için katılın.',
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.secondaryText,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xl),

                              // Hata Mesajı Bannerı
                              if (errorMessage != null &&
                                  errorMessage.isNotEmpty) ...[
                                Container(
                                  key: const ValueKey('register_error_banner'),
                                  padding: const EdgeInsets.all(AppSpacing.sm),
                                  margin: const EdgeInsets.only(
                                    bottom: AppSpacing.md,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.error.withValues(
                                      alpha: 0.12,
                                    ),
                                    border: Border.all(
                                      color: AppColors.error.withValues(
                                        alpha: 0.6,
                                      ),
                                    ),
                                    borderRadius: BorderRadius.zero,
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Icon(
                                        Icons.error_outline,
                                        color: AppColors.error,
                                        size: 18,
                                      ),
                                      const SizedBox(width: AppSpacing.xs),
                                      Expanded(
                                        child: Text(
                                          errorMessage,
                                          style: AppTextStyles.caption.copyWith(
                                            color: AppColors.error,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],

                              // 1. Ad Soyad Alanı
                              _buildFieldLabel('AD SOYAD'),
                              const SizedBox(height: 6),
                              TextFormField(
                                key: const ValueKey('register_name_input'),
                                controller: _nameController,
                                keyboardType: TextInputType.name,
                                textCapitalization: TextCapitalization.words,
                                style: AppTextStyles.body.copyWith(
                                  color: AppColors.primaryText,
                                ),
                                decoration: _inputDecoration(
                                  hintText: 'Adınızı ve soyadınızı giriniz',
                                ),
                                validator: (value) {
                                  final trimmed = value?.trim() ?? '';
                                  if (trimmed.isEmpty) {
                                    return 'Lütfen adınızı ve soyadınızı giriniz.';
                                  }
                                  if (trimmed.length < 2) {
                                    return 'Ad soyad en az 2 karakter olmalıdır.';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: AppSpacing.md),

                              // 2. E-Posta Alanı
                              _buildFieldLabel('E-POSTA ADRESİ'),
                              const SizedBox(height: 6),
                              TextFormField(
                                key: const ValueKey('register_email_input'),
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                autocorrect: false,
                                style: AppTextStyles.body.copyWith(
                                  color: AppColors.primaryText,
                                ),
                                decoration: _inputDecoration(
                                  hintText: 'ornek@sparks.fashion',
                                ),
                                validator: (value) {
                                  final trimmed = value?.trim() ?? '';
                                  if (trimmed.isEmpty) {
                                    return 'Lütfen e-posta adresinizi giriniz.';
                                  }
                                  final emailRegex = RegExp(
                                    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                                  );
                                  if (!emailRegex.hasMatch(trimmed)) {
                                    return 'Geçerli bir e-posta adresi giriniz.';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: AppSpacing.md),

                              // 3. Şifre Alanı
                              _buildFieldLabel('ŞİFRE'),
                              const SizedBox(height: 6),
                              TextFormField(
                                key: const ValueKey('register_password_input'),
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                style: AppTextStyles.body.copyWith(
                                  color: AppColors.primaryText,
                                ),
                                decoration: _inputDecoration(
                                  hintText: 'En az 6 karakter',
                                  suffixIcon: IconButton(
                                    key: const ValueKey(
                                      'register_password_toggle',
                                    ),
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
                                    return 'Lütfen bir şifre belirleyiniz.';
                                  }
                                  if (value.length < 6) {
                                    return 'Şifre en az 6 karakter olmalıdır.';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: AppSpacing.md),

                              // 4. Şifre Tekrar Alanı
                              _buildFieldLabel('ŞİFRE TEKRAR'),
                              const SizedBox(height: 6),
                              TextFormField(
                                key: const ValueKey(
                                  'register_password_repeat_input',
                                ),
                                controller: _passwordRepeatController,
                                obscureText: _obscurePasswordRepeat,
                                style: AppTextStyles.body.copyWith(
                                  color: AppColors.primaryText,
                                ),
                                decoration: _inputDecoration(
                                  hintText: 'Şifrenizi yeniden giriniz',
                                  suffixIcon: IconButton(
                                    key: const ValueKey(
                                      'register_password_repeat_toggle',
                                    ),
                                    icon: Icon(
                                      _obscurePasswordRepeat
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      color: AppColors.secondaryText,
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePasswordRepeat =
                                            !_obscurePasswordRepeat;
                                      });
                                    },
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Lütfen şifrenizi tekrar giriniz.';
                                  }
                                  if (value != _passwordController.text) {
                                    return 'Şifreler eşleşmiyor.';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: AppSpacing.md),

                              // 5. Kullanım Koşulları & Gizlilik Onayı Checkbox
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    _termsAccepted = !_termsAccepted;
                                    if (_termsAccepted) _termsError = false;
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4,
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: Checkbox(
                                          key: const ValueKey(
                                            'register_terms_checkbox',
                                          ),
                                          value: _termsAccepted,
                                          activeColor: AppColors.primaryText,
                                          checkColor:
                                              AppColors.shoppingBackground,
                                          side: BorderSide(
                                            color: _termsError
                                                ? AppColors.error
                                                : AppColors.primaryText
                                                      .withValues(alpha: 0.5),
                                            width: 1.2,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.zero,
                                          ),
                                          onChanged: (val) {
                                            setState(() {
                                              _termsAccepted = val ?? false;
                                              if (_termsAccepted) {
                                                _termsError = false;
                                              }
                                            });
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: AppSpacing.xs),
                                      Expanded(
                                        child: Text(
                                          'Kullanım Koşullarını ve Gizlilik Politikasını okudum, kabul ediyorum.',
                                          style: AppTextStyles.caption.copyWith(
                                            color: _termsError
                                                ? AppColors.error
                                                : AppColors.secondaryText,
                                            fontSize: 12,
                                            height: 1.4,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (_termsError) ...[
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 32,
                                    top: 4,
                                  ),
                                  child: Text(
                                    'Devam etmek için kullanım koşullarını kabul etmelisiniz.',
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.error,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ],

                              const SizedBox(height: AppSpacing.lg),

                              // 6. Kayıt Ol Butonu
                              SizedBox(
                                height: 50,
                                child: ElevatedButton(
                                  key: const ValueKey('register_submit_button'),
                                  onPressed: isLoading
                                      ? null
                                      : () => _submitRegister(cubit),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryText,
                                    foregroundColor:
                                        AppColors.shoppingBackground,
                                    elevation: 0,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.zero,
                                    ),
                                  ),
                                  child: isLoading
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Colors.black,
                                                ),
                                          ),
                                        )
                                      : Text(
                                          'KAYIT OL',
                                          style: AppTextStyles.buttonText,
                                        ),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xl),

                              // 7. Giriş Yap Bağlantısı
                              Center(
                                child: TextButton(
                                  key: const ValueKey(
                                    'register_to_login_button',
                                  ),
                                  onPressed: _handleLoginNavigation,
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppColors.secondaryText,
                                  ),
                                  child: RichText(
                                    text: TextSpan(
                                      style: AppTextStyles.caption.copyWith(
                                        color: AppColors.secondaryText,
                                      ),
                                      children: [
                                        const TextSpan(
                                          text: 'Zaten bir hesabınız var mı? ',
                                        ),
                                        TextSpan(
                                          text: 'Giriş Yap',
                                          style: AppTextStyles.caption.copyWith(
                                            color: AppColors.primaryText,
                                            fontWeight: FontWeight.w700,
                                            decoration:
                                                TextDecoration.underline,
                                            decorationColor:
                                                AppColors.primaryText,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.lg),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: AppTextStyles.caption.copyWith(
        color: AppColors.primaryText,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.5,
        fontSize: 11,
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hintText,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: AppTextStyles.body.copyWith(
        color: AppColors.secondaryText.withValues(alpha: 0.6),
        fontSize: 12,
      ),
      filled: true,
      fillColor: Colors.black,
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(
          color: AppColors.primaryText.withValues(alpha: 0.25),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(
          color: AppColors.primaryText.withValues(alpha: 0.25),
        ),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: AppColors.primaryText, width: 1.5),
      ),
      errorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: AppColors.error, width: 1.5),
      ),
      errorStyle: AppTextStyles.caption.copyWith(
        color: AppColors.error,
        fontSize: 11,
      ),
    );
  }
}
