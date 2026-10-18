import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sparks/app/theme/app_theme.dart';
import 'package:sparks/features/auth/domain/entities/app_user.dart';
import 'package:sparks/features/auth/domain/repositories/auth_repository.dart';
import 'package:sparks/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:sparks/features/auth/presentation/register_screen.dart';

class FakeRegisterTestAuthRepository implements AuthRepository {
  FakeRegisterTestAuthRepository({AppUser? initialUser})
    : _currentUser = initialUser {
    _streamController = StreamController<AppUser?>.broadcast(sync: true);
  }

  AppUser? _currentUser;
  late final StreamController<AppUser?> _streamController;

  bool shouldFail = false;
  String failureCode = 'email-already-in-use';
  String failureMessage =
      'Bu e-posta adresi ile zaten kayıtlı bir hesap bulunmaktadır.';

  @override
  Stream<AppUser?> get authStateChanges => _streamController.stream;

  @override
  AppUser? get currentUser => _currentUser;

  @override
  Future<AppUser> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
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
    if (shouldFail) {
      throw AuthException(failureMessage, code: failureCode);
    }
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

  Future<void> pumpRegisterScreen(
    WidgetTester tester, {
    required AuthCubit cubit,
    VoidCallback? onClose,
    VoidCallback? onLoginTap,
    VoidCallback? onRegisterSuccess,
  }) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: BlocProvider<AuthCubit>.value(
          value: cubit,
          child: RegisterScreen(
            authCubit: cubit,
            onClose: onClose,
            onLoginTap: onLoginTap,
            onRegisterSuccess: onRegisterSuccess,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('Aşama 12 — RegisterScreen Widget Testleri', () {
    late FakeRegisterTestAuthRepository fakeRepo;
    late AuthCubit authCubit;

    setUp(() {
      fakeRepo = FakeRegisterTestAuthRepository();
      authCubit = AuthCubit(authRepository: fakeRepo);
    });

    tearDown(() {
      authCubit.close();
      fakeRepo.dispose();
    });

    testWidgets(
      '1. RegisterScreen tüm form alanlarını ve editoryal başlıkları doğru render eder',
      (tester) async {
        await pumpRegisterScreen(tester, cubit: authCubit);

        expect(find.byKey(const ValueKey('register_screen')), findsOneWidget);
        expect(
          find.byKey(const ValueKey('register_close_button')),
          findsOneWidget,
        );
        expect(find.text('SPARKS'), findsOneWidget);
        expect(find.text('HESAP OLUŞTUR'), findsOneWidget);

        // Form alanları
        expect(
          find.byKey(const ValueKey('register_name_input')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('register_email_input')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('register_password_input')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('register_password_repeat_input')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('register_terms_checkbox')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('register_submit_button')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('register_to_login_button')),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      '2. Boş form gönderildiğinde tüm zorunlu alanlar için hata mesajı gösterir',
      (tester) async {
        await pumpRegisterScreen(tester, cubit: authCubit);

        final submitBtn = find.byKey(const ValueKey('register_submit_button'));
        await tester.ensureVisible(submitBtn);
        await tester.tap(submitBtn);
        await tester.pumpAndSettle();

        expect(
          find.text('Lütfen adınızı ve soyadınızı giriniz.'),
          findsOneWidget,
        );
        expect(find.text('Lütfen e-posta adresinizi giriniz.'), findsOneWidget);
        expect(find.text('Lütfen bir şifre belirleyiniz.'), findsOneWidget);
        expect(
          find.text('Devam etmek için kullanım koşullarını kabul etmelisiniz.'),
          findsOneWidget,
        );
      },
    );

    testWidgets('3. Geçersiz e-posta formatı girildiğinde uyarı verir', (
      tester,
    ) async {
      await pumpRegisterScreen(tester, cubit: authCubit);

      await tester.enterText(
        find.byKey(const ValueKey('register_name_input')),
        'Aygen Yıldırım',
      );
      await tester.enterText(
        find.byKey(const ValueKey('register_email_input')),
        'invalid-email-format',
      );
      await tester.enterText(
        find.byKey(const ValueKey('register_password_input')),
        'Secret123!',
      );
      await tester.enterText(
        find.byKey(const ValueKey('register_password_repeat_input')),
        'Secret123!',
      );
      final checkbox = find.byKey(const ValueKey('register_terms_checkbox'));
      await tester.ensureVisible(checkbox);
      await tester.tap(checkbox);
      await tester.pumpAndSettle();

      final submitBtn = find.byKey(const ValueKey('register_submit_button'));
      await tester.ensureVisible(submitBtn);
      await tester.tap(submitBtn);
      await tester.pumpAndSettle();

      expect(find.text('Geçerli bir e-posta adresi giriniz.'), findsOneWidget);
    });

    testWidgets('4. Şifre 6 karakterden az ise uyarı verir', (tester) async {
      await pumpRegisterScreen(tester, cubit: authCubit);

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
        '12345',
      );
      await tester.enterText(
        find.byKey(const ValueKey('register_password_repeat_input')),
        '12345',
      );
      final checkbox = find.byKey(const ValueKey('register_terms_checkbox'));
      await tester.ensureVisible(checkbox);
      await tester.tap(checkbox);
      await tester.pumpAndSettle();

      final submitBtn = find.byKey(const ValueKey('register_submit_button'));
      await tester.ensureVisible(submitBtn);
      await tester.tap(submitBtn);
      await tester.pumpAndSettle();

      expect(find.text('Şifre en az 6 karakter olmalıdır.'), findsOneWidget);
    });

    testWidgets('5. Şifre ve şifre tekrarı uyuşmadığında uyarı verir', (
      tester,
    ) async {
      await pumpRegisterScreen(tester, cubit: authCubit);

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
        'Password123!',
      );
      await tester.enterText(
        find.byKey(const ValueKey('register_password_repeat_input')),
        'DifferentPass456!',
      );
      final checkbox = find.byKey(const ValueKey('register_terms_checkbox'));
      await tester.ensureVisible(checkbox);
      await tester.tap(checkbox);
      await tester.pumpAndSettle();

      final submitBtn = find.byKey(const ValueKey('register_submit_button'));
      await tester.ensureVisible(submitBtn);
      await tester.tap(submitBtn);
      await tester.pumpAndSettle();

      expect(find.text('Şifreler eşleşmiyor.'), findsOneWidget);
    });

    testWidgets(
      '6. Şifre görünürlüğü butonları obscureText durumunu değiştirir',
      (tester) async {
        await pumpRegisterScreen(tester, cubit: authCubit);

        final passFinder = find.byKey(
          const ValueKey('register_password_input'),
        );
        final repeatFinder = find.byKey(
          const ValueKey('register_password_repeat_input'),
        );

        // Başlangıçta gizli
        TextField passField = tester.widget<TextField>(
          find.descendant(of: passFinder, matching: find.byType(TextField)),
        );
        TextField repeatField = tester.widget<TextField>(
          find.descendant(of: repeatFinder, matching: find.byType(TextField)),
        );
        expect(passField.obscureText, isTrue);
        expect(repeatField.obscureText, isTrue);

        // Şifre görünürlüğünü aç
        final passToggle = find.byKey(
          const ValueKey('register_password_toggle'),
        );
        await tester.ensureVisible(passToggle);
        await tester.tap(passToggle);
        await tester.pumpAndSettle();

        passField = tester.widget<TextField>(
          find.descendant(of: passFinder, matching: find.byType(TextField)),
        );
        expect(passField.obscureText, isFalse);

        // Şifre tekrar görünürlüğünü aç
        final repeatToggle = find.byKey(
          const ValueKey('register_password_repeat_toggle'),
        );
        await tester.ensureVisible(repeatToggle);
        await tester.tap(repeatToggle);
        await tester.pumpAndSettle();

        repeatField = tester.widget<TextField>(
          find.descendant(of: repeatFinder, matching: find.byType(TextField)),
        );
        expect(repeatField.obscureText, isFalse);
      },
    );

    testWidgets(
      '7. Başarılı kayıtta AuthCubit tetiklenir ve onRegisterSuccess çağrılır',
      (tester) async {
        bool registerSuccessCalled = false;

        await pumpRegisterScreen(
          tester,
          cubit: authCubit,
          onRegisterSuccess: () => registerSuccessCalled = true,
        );

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

        expect(authCubit.state.isAuthenticated, isTrue);
        expect(authCubit.state.user?.displayName, 'Aygen Yıldırım');
        expect(authCubit.state.user?.email, 'aygen@sparks.fashion');
        expect(registerSuccessCalled, isTrue);
      },
    );

    testWidgets('8. Kayıt sırasında hata oluştuğunda hata bannerı gösterilir', (
      tester,
    ) async {
      fakeRepo.shouldFail = true;

      await pumpRegisterScreen(tester, cubit: authCubit);

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
        find.byKey(const ValueKey('register_error_banner')),
        findsOneWidget,
      );
      expect(
        find.text(
          'Bu e-posta adresi ile zaten kayıtlı bir hesap bulunmaktadır.',
        ),
        findsOneWidget,
      );
    });

    testWidgets(
      '9. Kapatma ve Giriş Yap bağlantıları doğru geri çağrımları tetikler',
      (tester) async {
        bool closeCalled = false;
        bool loginCalled = false;

        await pumpRegisterScreen(
          tester,
          cubit: authCubit,
          onClose: () => closeCalled = true,
          onLoginTap: () => loginCalled = true,
        );

        final closeBtn = find.byKey(const ValueKey('register_close_button'));
        await tester.ensureVisible(closeBtn);
        await tester.tap(closeBtn);
        await tester.pumpAndSettle();
        expect(closeCalled, isTrue);

        final loginLink = find.byKey(
          const ValueKey('register_to_login_button'),
        );
        await tester.ensureVisible(loginLink);
        await tester.tap(loginLink);
        await tester.pumpAndSettle();
        expect(loginCalled, isTrue);
      },
    );
  });
}
