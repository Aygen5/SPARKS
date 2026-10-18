import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sparks/app/theme/app_theme.dart';
import 'package:sparks/features/auth/data/mappers/auth_error_mapper.dart';
import 'package:sparks/features/auth/domain/entities/app_user.dart';
import 'package:sparks/features/auth/domain/repositories/auth_repository.dart';
import 'package:sparks/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:sparks/features/auth/presentation/cubit/auth_state.dart';
import 'package:sparks/features/auth/presentation/login_screen.dart';
import 'package:sparks/features/auth/presentation/register_screen.dart';

/// Aşama 14 Auth Akışları Test Double (Sahte Auth Repository)
class FakeStage14AuthRepository implements AuthRepository {
  FakeStage14AuthRepository({AppUser? initialUser})
    : _currentUser = initialUser {
    _streamController = StreamController<AppUser?>.broadcast(sync: true);
  }

  AppUser? _currentUser;
  late final StreamController<AppUser?> _streamController;

  bool shouldFail = false;
  String failureCode = 'invalid-credential';
  String failureMessage =
      'E-posta veya şifre hatalı. Lütfen bilgilerinizi kontrol ediniz.';

  int signInCallCount = 0;
  int signUpCallCount = 0;
  int resetPasswordCallCount = 0;
  String? lastResetEmail;

  @override
  Stream<AppUser?> get authStateChanges => _streamController.stream;

  @override
  AppUser? get currentUser => _currentUser;

  @override
  Future<AppUser> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    signInCallCount++;
    if (shouldFail) {
      throw AuthException(failureMessage, code: failureCode);
    }
    final user = AppUser(
      id: 'test-uid-stage-14',
      email: email,
      displayName: 'Aygen Yıldırım',
      isEmailVerified: true,
    );
    _currentUser = user;
    _streamController.add(user);
    return user;
  }

  @override
  Future<AppUser> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    signUpCallCount++;
    if (shouldFail) {
      throw AuthException(failureMessage, code: failureCode);
    }
    final user = AppUser(
      id: 'test-uid-stage-14-new',
      email: email,
      displayName: displayName ?? 'Aygen',
      isEmailVerified: false,
    );
    _currentUser = user;
    _streamController.add(user);
    return user;
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
    _streamController.add(null);
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    resetPasswordCallCount++;
    lastResetEmail = email;
    if (shouldFail) {
      throw AuthException(failureMessage, code: failureCode);
    }
  }

  @override
  Future<void> sendEmailVerification() async {}

  void dispose() {
    _streamController.close();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  late FakeStage14AuthRepository fakeRepo;
  late AuthCubit authCubit;

  setUp(() {
    fakeRepo = FakeStage14AuthRepository();
    authCubit = AuthCubit(authRepository: fakeRepo);
  });

  tearDown(() {
    authCubit.close();
    fakeRepo.dispose();
  });

  Widget buildLoginTestApp({
    VoidCallback? onClose,
    VoidCallback? onRegisterTap,
    VoidCallback? onLoginSuccess,
  }) {
    return MaterialApp(
      theme: AppTheme.darkTheme,
      home: BlocProvider<AuthCubit>.value(
        value: authCubit,
        child: LoginScreen(
          authCubit: authCubit,
          onClose: onClose,
          onRegisterTap: onRegisterTap,
          onLoginSuccess: onLoginSuccess,
        ),
      ),
    );
  }

  Widget buildRegisterTestApp({
    VoidCallback? onClose,
    VoidCallback? onLoginTap,
    VoidCallback? onRegisterSuccess,
  }) {
    return MaterialApp(
      theme: AppTheme.darkTheme,
      home: BlocProvider<AuthCubit>.value(
        value: authCubit,
        child: RegisterScreen(
          authCubit: authCubit,
          onClose: onClose,
          onLoginTap: onLoginTap,
          onRegisterSuccess: onRegisterSuccess,
        ),
      ),
    );
  }

  group('Aşama 14 — Auth Akışları, Validasyon ve Küçük Ekran Testleri', () {
    testWidgets(
      '1. LoginScreen 360x640 dar ekranda ve simüle edilen dar klavye yüksekliğinde taşma yapmaz',
      (tester) async {
        // 360x640 dar ekran
        tester.view.physicalSize = const Size(360, 640);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(buildLoginTestApp());
        await tester.pumpAndSettle();

        expect(find.byKey(const ValueKey('login_screen')), findsOneWidget);
        expect(tester.takeException(), isNull);

        // Sanal klavye açılma simülasyonu: Yükseklik 390'a daralır
        tester.view.physicalSize = const Size(360, 390);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        // Şifre alanına odaklanma ve kaydırma
        final passFinder = find.byKey(const ValueKey('login_password_input'));
        await tester.ensureVisible(passFinder);
        await tester.enterText(passFinder, 'Pass123!');
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      '2. RegisterScreen 360x640 dar ekranda ve sanal klavye simülasyonunda taşma yapmaz',
      (tester) async {
        tester.view.physicalSize = const Size(360, 640);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(buildRegisterTestApp());
        await tester.pumpAndSettle();

        expect(find.byKey(const ValueKey('register_screen')), findsOneWidget);
        expect(tester.takeException(), isNull);

        // Sanal klavye açılma simülasyonu: Yükseklik 390'a daralır
        tester.view.physicalSize = const Size(360, 390);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        // Form alanlarının kaydırılabilirliği
        final submitFinder = find.byKey(
          const ValueKey('register_submit_button'),
        );
        await tester.ensureVisible(submitFinder);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      '3. LoginScreen Şifremi Unuttum akışı boş e-posta ve dolu e-posta durumlarını yönetir',
      (tester) async {
        await tester.pumpWidget(buildLoginTestApp());
        await tester.pumpAndSettle();

        // Boş e-posta ile şifremi unuttum butonuna tıkla
        final forgotBtn = find.byKey(
          const ValueKey('login_forgot_password_button'),
        );
        await tester.tap(forgotBtn);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        // Bilgilendirme snackbar'ı görünür
        expect(
          find.text('Lütfen önce e-posta adresinizi yukarıdaki alana giriniz.'),
          findsOneWidget,
        );
        expect(fakeRepo.resetPasswordCallCount, 0);

        // İlk snackbar'ın kapanmasını bekle
        await tester.pumpAndSettle();

        // E-posta girip tekrar tıkla
        await tester.enterText(
          find.byKey(const ValueKey('login_email_input')),
          'aygen@sparks.fashion',
        );
        await tester.tap(forgotBtn);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(fakeRepo.resetPasswordCallCount, 1);
        expect(fakeRepo.lastResetEmail, 'aygen@sparks.fashion');
        expect(
          find.text(
            'aygen@sparks.fashion adresine parola sıfırlama bağlantısı gönderildi.',
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      '4. LoginScreen yüklenme sırasında (isLoading) çift tıklama ve yinelenen istekleri engeller',
      (tester) async {
        await tester.pumpWidget(buildLoginTestApp());
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byKey(const ValueKey('login_email_input')),
          'aygen@sparks.fashion',
        );
        await tester.enterText(
          find.byKey(const ValueKey('login_password_input')),
          'Pass123!',
        );

        // Cubit durumunu suni olarak loading'e al
        authCubit.emit(const AuthState.loading());
        await tester.pump();

        // Gönder butonuna tıkla
        await tester.tap(find.byKey(const ValueKey('login_submit_button')));
        await tester.pump();

        // Repository signIn çağrılmamalıdır çünkü form kilitlidir
        expect(fakeRepo.signInCallCount, 0);
      },
    );

    testWidgets(
      '5. RegisterScreen yüklenme sırasında (isLoading) çift tıklama ve yinelenen istekleri engeller',
      (tester) async {
        await tester.pumpWidget(buildRegisterTestApp());
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byKey(const ValueKey('register_name_input')),
          'Aygen Yıldırım',
        );
        await tester.enterText(
          find.byKey(const ValueKey('register_email_input')),
          'aygen@sparks.fashion',
        );
        await tester.enterText(
          find.byKey(const ValueKey('register_password_input')),
          'Pass123!',
        );
        await tester.enterText(
          find.byKey(const ValueKey('register_password_repeat_input')),
          'Pass123!',
        );

        final termsFinder = find.byKey(
          const ValueKey('register_terms_checkbox'),
        );
        await tester.ensureVisible(termsFinder);
        await tester.tap(termsFinder);
        await tester.pumpAndSettle();

        // Cubit durumunu loading'e al
        authCubit.emit(const AuthState.loading());
        await tester.pump();

        final submitFinder = find.byKey(
          const ValueKey('register_submit_button'),
        );
        await tester.ensureVisible(submitFinder);
        await tester.tap(submitFinder);
        await tester.pump();

        // Repository signUp çağrılmamalıdır
        expect(fakeRepo.signUpCallCount, 0);
      },
    );

    testWidgets(
      '6. LoginScreen Firebase hata kodlarını (user-not-found, wrong-password, too-many-requests) kullanıcı dostu mesajla sunar',
      (tester) async {
        fakeRepo.shouldFail = true;
        fakeRepo.failureCode = 'user-not-found';
        fakeRepo.failureMessage = AuthErrorMapper.mapErrorCode(
          'user-not-found',
        );

        await tester.pumpWidget(buildLoginTestApp());
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byKey(const ValueKey('login_email_input')),
          'bilinmeyen@sparks.fashion',
        );
        await tester.enterText(
          find.byKey(const ValueKey('login_password_input')),
          'Password123!',
        );
        await tester.tap(find.byKey(const ValueKey('login_submit_button')));
        await tester.pumpAndSettle();

        expect(
          find.text('Bu e-posta adresiyle kayıtlı bir hesap bulunamadı.'),
          findsWidgets,
        );

        // wrong-password testi
        fakeRepo.failureCode = 'wrong-password';
        fakeRepo.failureMessage = AuthErrorMapper.mapErrorCode(
          'wrong-password',
        );
        await tester.tap(find.byKey(const ValueKey('login_submit_button')));
        await tester.pumpAndSettle();

        expect(
          find.text('Hatalı şifre girdiniz. Lütfen tekrar deneyiniz.'),
          findsWidgets,
        );

        // too-many-requests testi
        fakeRepo.failureCode = 'too-many-requests';
        fakeRepo.failureMessage = AuthErrorMapper.mapErrorCode(
          'too-many-requests',
        );
        await tester.tap(find.byKey(const ValueKey('login_submit_button')));
        await tester.pumpAndSettle();

        expect(
          find.text(
            'Çok fazla başarısız deneme yapıldı. Güvenliğiniz için lütfen biraz bekleyip tekrar deneyiniz.',
          ),
          findsWidgets,
        );
      },
    );

    testWidgets(
      '7. RegisterScreen ad soyad 2 karakterden kısa olduğunda hata uyarısı verir',
      (tester) async {
        await tester.pumpWidget(buildRegisterTestApp());
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byKey(const ValueKey('register_name_input')),
          'A',
        );
        await tester.enterText(
          find.byKey(const ValueKey('register_email_input')),
          'aygen@sparks.fashion',
        );
        await tester.enterText(
          find.byKey(const ValueKey('register_password_input')),
          'Password123!',
        );
        await tester.enterText(
          find.byKey(const ValueKey('register_password_repeat_input')),
          'Password123!',
        );
        final checkbox = find.byKey(const ValueKey('register_terms_checkbox'));
        await tester.ensureVisible(checkbox);
        await tester.tap(checkbox);
        await tester.pumpAndSettle();

        final submitBtn = find.byKey(const ValueKey('register_submit_button'));
        await tester.ensureVisible(submitBtn);
        await tester.tap(submitBtn);
        await tester.pumpAndSettle();

        expect(
          find.text('Ad soyad en az 2 karakter olmalıdır.'),
          findsOneWidget,
        );
        expect(fakeRepo.signUpCallCount, 0);
      },
    );

    testWidgets(
      '8. RegisterScreen Firebase hata kodlarını (weak-password, operation-not-allowed, network-request-failed) kullanıcı dostu mesajla sunar',
      (tester) async {
        fakeRepo.shouldFail = true;
        fakeRepo.failureCode = 'weak-password';
        fakeRepo.failureMessage = AuthErrorMapper.mapErrorCode('weak-password');

        await tester.pumpWidget(buildRegisterTestApp());
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byKey(const ValueKey('register_name_input')),
          'Aygen Yıldırım',
        );
        await tester.enterText(
          find.byKey(const ValueKey('register_email_input')),
          'aygen@sparks.fashion',
        );
        await tester.enterText(
          find.byKey(const ValueKey('register_password_input')),
          'WeakPass123!',
        );
        await tester.enterText(
          find.byKey(const ValueKey('register_password_repeat_input')),
          'WeakPass123!',
        );
        final checkbox = find.byKey(const ValueKey('register_terms_checkbox'));
        await tester.ensureVisible(checkbox);
        await tester.tap(checkbox);
        await tester.pumpAndSettle();

        final submitBtn = find.byKey(const ValueKey('register_submit_button'));
        await tester.ensureVisible(submitBtn);
        await tester.tap(submitBtn);
        await tester.pumpAndSettle();

        expect(
          find.text(
            'Şifreniz çok zayıf. Lütfen en az 6 karakterli daha güçlü bir şifre belirleyiniz.',
          ),
          findsOneWidget,
        );

        // operation-not-allowed testi
        fakeRepo.failureCode = 'operation-not-allowed';
        fakeRepo.failureMessage = AuthErrorMapper.mapErrorCode(
          'operation-not-allowed',
        );
        await tester.tap(submitBtn);
        await tester.pumpAndSettle();

        expect(
          find.text(
            'E-posta ve şifre sağlayıcısı Firebase Console üzerinden etkinleştirilmemiştir.',
          ),
          findsOneWidget,
        );

        // network-request-failed testi
        fakeRepo.failureCode = 'network-request-failed';
        fakeRepo.failureMessage = AuthErrorMapper.mapErrorCode(
          'network-request-failed',
        );
        await tester.tap(submitBtn);
        await tester.pumpAndSettle();

        expect(
          find.text('İnternet bağlantınızı kontrol edip tekrar deneyiniz.'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      '9. Login ve Register ekranları arasında çift yönlü geçiş ve kapatma aksiyonları çalışır',
      (tester) async {
        bool registerTappedFromLogin = false;
        bool loginTappedFromRegister = false;
        bool loginClosed = false;
        bool registerClosed = false;

        // Login ekranı geçişleri
        await tester.pumpWidget(
          buildLoginTestApp(
            onClose: () => loginClosed = true,
            onRegisterTap: () => registerTappedFromLogin = true,
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(
          find.byKey(const ValueKey('login_to_register_button')),
        );
        await tester.pumpAndSettle();
        expect(registerTappedFromLogin, isTrue);

        await tester.tap(find.byKey(const ValueKey('login_close_button')));
        await tester.pumpAndSettle();
        expect(loginClosed, isTrue);

        // Register ekranı geçişleri
        await tester.pumpWidget(
          buildRegisterTestApp(
            onClose: () => registerClosed = true,
            onLoginTap: () => loginTappedFromRegister = true,
          ),
        );
        await tester.pumpAndSettle();

        final loginLink = find.byKey(
          const ValueKey('register_to_login_button'),
        );
        await tester.ensureVisible(loginLink);
        await tester.tap(loginLink);
        await tester.pumpAndSettle();
        expect(loginTappedFromRegister, isTrue);

        final closeBtn = find.byKey(const ValueKey('register_close_button'));
        await tester.ensureVisible(closeBtn);
        await tester.tap(closeBtn);
        await tester.pumpAndSettle();
        expect(registerClosed, isTrue);
      },
    );

    test('10. AuthErrorMapper tüm Firebase hata kodlarını doğru Türkçe metinlere eşler', () {
      expect(
        AuthErrorMapper.mapErrorCode('user-not-found'),
        'Bu e-posta adresiyle kayıtlı bir hesap bulunamadı.',
      );
      expect(
        AuthErrorMapper.mapErrorCode('wrong-password'),
        'Hatalı şifre girdiniz. Lütfen tekrar deneyiniz.',
      );
      expect(
        AuthErrorMapper.mapErrorCode('invalid-credential'),
        'E-posta veya şifre hatalı. Lütfen bilgilerinizi kontrol ediniz.',
      );
      expect(
        AuthErrorMapper.mapErrorCode('email-already-in-use'),
        'Bu e-posta adresi zaten başka bir hesap tarafından kullanılıyor.',
      );
      expect(
        AuthErrorMapper.mapErrorCode('invalid-email'),
        'Geçersiz bir e-posta adresi girdiniz.',
      );
      expect(
        AuthErrorMapper.mapErrorCode('weak-password'),
        'Şifreniz çok zayıf. Lütfen en az 6 karakterli daha güçlü bir şifre belirleyiniz.',
      );
      expect(
        AuthErrorMapper.mapErrorCode('user-disabled'),
        'Bu kullanıcı hesabı askıya alınmıştır. Lütfen destek ile iletişime geçiniz.',
      );
      expect(
        AuthErrorMapper.mapErrorCode('too-many-requests'),
        'Çok fazla başarısız deneme yapıldı. Güvenliğiniz için lütfen biraz bekleyip tekrar deneyiniz.',
      );
      expect(
        AuthErrorMapper.mapErrorCode('operation-not-allowed'),
        'E-posta ve şifre sağlayıcısı Firebase Console üzerinden etkinleştirilmemiştir.',
      );
      expect(
        AuthErrorMapper.mapErrorCode('network-request-failed'),
        'İnternet bağlantınızı kontrol edip tekrar deneyiniz.',
      );
      expect(
        AuthErrorMapper.mapErrorCode('channel-error'),
        'Lütfen e-posta ve şifre alanlarını eksiksiz doldurunuz.',
      );
      expect(
        AuthErrorMapper.mapErrorCode('requires-recent-login'),
        'Bu işlem için yakın zamanda oturum açmış olmanız gerekmektedir. Lütfen tekrar giriş yapınız.',
      );
      expect(
        AuthErrorMapper.mapErrorCode('unknown-error', 'Özel hata'),
        'Özel hata',
      );
      expect(
        AuthErrorMapper.mapErrorCode('unknown-error'),
        'Kimlik doğrulama işlemi sırasında bir hata oluştu. Lütfen tekrar deneyiniz.',
      );
    });
  });
}
