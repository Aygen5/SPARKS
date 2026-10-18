import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sparks/app/theme/app_theme.dart';
import 'package:sparks/features/auth/domain/entities/app_user.dart';
import 'package:sparks/features/auth/domain/repositories/auth_repository.dart';
import 'package:sparks/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:sparks/features/auth/presentation/login_screen.dart';
import 'package:sparks/features/home/presentation/home_screen.dart';

class FakeLoginTestAuthRepository implements AuthRepository {
  FakeLoginTestAuthRepository({AppUser? initialUser})
    : _currentUser = initialUser {
    _streamController = StreamController<AppUser?>.broadcast(sync: true);
  }

  AppUser? _currentUser;
  late final StreamController<AppUser?> _streamController;

  bool shouldFail = false;
  String failureCode = 'invalid-credential';
  String failureMessage =
      'E-posta veya şifre hatalı. Lütfen bilgilerinizi kontrol ediniz.';

  @override
  Stream<AppUser?> get authStateChanges => _streamController.stream;

  @override
  AppUser? get currentUser => _currentUser;

  @override
  Future<AppUser> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    if (shouldFail) {
      throw AuthException(failureMessage, code: failureCode);
    }
    final user = AppUser(
      id: 'sparks-uid-test',
      email: email,
      displayName: 'Aygen',
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
    final user = AppUser(
      id: 'sparks-uid-new',
      email: email,
      displayName: displayName,
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
  Future<void> sendPasswordResetEmail({required String email}) async {}

  @override
  Future<void> sendEmailVerification() async {}

  void dispose() {
    _streamController.close();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  Widget createLoginWidget({
    required AuthCubit cubit,
    VoidCallback? onClose,
    VoidCallback? onRegisterTap,
    VoidCallback? onLoginSuccess,
  }) {
    return MaterialApp(
      theme: AppTheme.darkTheme,
      home: BlocProvider<AuthCubit>.value(
        value: cubit,
        child: LoginScreen(
          authCubit: cubit,
          onClose: onClose,
          onRegisterTap: onRegisterTap,
          onLoginSuccess: onLoginSuccess,
        ),
      ),
    );
  }

  group('Aşama 12 — LoginScreen Widget Testleri', () {
    late FakeLoginTestAuthRepository fakeRepo;
    late AuthCubit authCubit;

    setUp(() {
      fakeRepo = FakeLoginTestAuthRepository();
      authCubit = AuthCubit(authRepository: fakeRepo);
    });

    tearDown(() {
      authCubit.close();
      fakeRepo.dispose();
    });

    testWidgets(
      '1. LoginScreen temel bileşenleri ve editoryal başlıkları doğru render eder',
      (tester) async {
        await tester.pumpWidget(createLoginWidget(cubit: authCubit));
        await tester.pumpAndSettle();

        expect(find.byKey(const ValueKey('login_screen')), findsOneWidget);
        expect(
          find.byKey(const ValueKey('login_close_button')),
          findsOneWidget,
        );
        expect(find.text('SPARKS'), findsOneWidget);
        expect(find.text('TEKRAR HOŞ GELDİNİZ'), findsOneWidget);
        expect(find.text('GİRİŞ YAP'), findsWidgets);

        expect(find.byKey(const ValueKey('login_email_input')), findsOneWidget);
        expect(
          find.byKey(const ValueKey('login_password_input')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('login_remember_me_checkbox')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('login_forgot_password_button')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('login_submit_button')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('login_to_register_button')),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      '2. Boş form gönderildiğinde validasyon hata mesajları görüntülenir',
      (tester) async {
        await tester.pumpWidget(createLoginWidget(cubit: authCubit));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const ValueKey('login_submit_button')));
        await tester.pumpAndSettle();

        expect(find.text('Lütfen e-posta adresinizi giriniz.'), findsOneWidget);
        expect(find.text('Lütfen şifrenizi giriniz.'), findsOneWidget);
      },
    );

    testWidgets('3. Geçersiz e-posta formatı girildiğinde uyarı verir', (
      tester,
    ) async {
      await tester.pumpWidget(createLoginWidget(cubit: authCubit));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const ValueKey('login_email_input')),
        'gecersiz-eposta',
      );
      await tester.enterText(
        find.byKey(const ValueKey('login_password_input')),
        '123456',
      );
      await tester.tap(find.byKey(const ValueKey('login_submit_button')));
      await tester.pumpAndSettle();

      expect(find.text('Geçerli bir e-posta adresi giriniz.'), findsOneWidget);
    });

    testWidgets('4. Şifre görünürlüğü butonu obscureText durumunu değiştirir', (
      tester,
    ) async {
      await tester.pumpWidget(createLoginWidget(cubit: authCubit));
      await tester.pumpAndSettle();

      final passFieldFinder = find.byKey(
        const ValueKey('login_password_input'),
      );
      TextField passTextField = tester.widget<TextField>(
        find.descendant(of: passFieldFinder, matching: find.byType(TextField)),
      );
      expect(passTextField.obscureText, isTrue);

      // İkona tıkla
      await tester.tap(find.byKey(const ValueKey('login_password_toggle')));
      await tester.pumpAndSettle();

      passTextField = tester.widget<TextField>(
        find.descendant(of: passFieldFinder, matching: find.byType(TextField)),
      );
      expect(passTextField.obscureText, isFalse);
    });

    testWidgets(
      '5. Başarılı girişte AuthCubit tetiklenir ve onLoginSuccess çağrılır',
      (tester) async {
        bool loginSuccessCalled = false;

        await tester.pumpWidget(
          createLoginWidget(
            cubit: authCubit,
            onLoginSuccess: () => loginSuccessCalled = true,
          ),
        );
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byKey(const ValueKey('login_email_input')),
          'aygen@sparks.fashion',
        );
        await tester.enterText(
          find.byKey(const ValueKey('login_password_input')),
          'Password123!',
        );

        await tester.tap(find.byKey(const ValueKey('login_submit_button')));
        await tester.pumpAndSettle();

        expect(authCubit.state.isAuthenticated, isTrue);
        expect(loginSuccessCalled, isTrue);
      },
    );

    testWidgets('6. Hatalı girişte Türkçe hata mesajı gösterilir', (
      tester,
    ) async {
      fakeRepo.shouldFail = true;

      await tester.pumpWidget(createLoginWidget(cubit: authCubit));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const ValueKey('login_email_input')),
        'yanlis@sparks.fashion',
      );
      await tester.enterText(
        find.byKey(const ValueKey('login_password_input')),
        'wrong',
      );

      await tester.tap(find.byKey(const ValueKey('login_submit_button')));
      await tester.pumpAndSettle();

      expect(authCubit.state.hasError, isTrue);
      expect(find.textContaining('E-posta veya şifre hatalı'), findsWidgets);
    });

    testWidgets(
      '7. Kapatma ve Kayıt Ol bağlantıları doğru geri çağrımları tetikler',
      (tester) async {
        bool closeCalled = false;
        bool registerCalled = false;

        await tester.pumpWidget(
          createLoginWidget(
            cubit: authCubit,
            onClose: () => closeCalled = true,
            onRegisterTap: () => registerCalled = true,
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const ValueKey('login_close_button')));
        await tester.pumpAndSettle();
        expect(closeCalled, isTrue);

        await tester.tap(
          find.byKey(const ValueKey('login_to_register_button')),
        );
        await tester.pumpAndSettle();
        expect(registerCalled, isTrue);
      },
    );

    testWidgets(
      '8. HomeScreen oturum kapalıyken GİRİŞ YAP butonunu gösterir, oturum açılınca gizler',
      (tester) async {
        bool homeLoginTapped = false;

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.darkTheme,
            home: BlocProvider<AuthCubit>.value(
              value: authCubit,
              child: HomeScreen(
                authCubit: authCubit,
                onLoginTap: () => homeLoginTapped = true,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Oturum kapalı -> GİRİŞ YAP butonu var
        final homeLoginBtn = find.byKey(const ValueKey('home_login_button'));
        expect(homeLoginBtn, findsOneWidget);
        expect(find.text('GİRİŞ YAP'), findsOneWidget);

        await tester.tap(homeLoginBtn);
        await tester.pumpAndSettle();
        expect(homeLoginTapped, isTrue);

        // Kullanıcı oturum açar
        await authCubit.signIn(
          email: 'aygen@sparks.fashion',
          password: 'Password123!',
        );
        await tester.pumpAndSettle();

        // Oturum açık -> GİRİŞ YAP butonu gizlenir
        expect(find.byKey(const ValueKey('home_login_button')), findsNothing);
      },
    );
  });
}
