import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sparks/app/theme/app_theme.dart';
import 'package:sparks/features/auth/domain/entities/app_user.dart';
import 'package:sparks/features/auth/domain/repositories/auth_repository.dart';
import 'package:sparks/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:sparks/features/auth/presentation/login_screen.dart';
import 'package:sparks/features/auth/presentation/register_screen.dart';
import 'package:sparks/features/cart/domain/repositories/cart_repository.dart';
import 'package:sparks/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:sparks/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:sparks/features/favorites/presentation/manager/favorites_manager.dart';

class MockStage13AuthRepository implements AuthRepository {
  MockStage13AuthRepository({AppUser? initialUser})
    : _currentUser = initialUser {
    _streamController = StreamController<AppUser?>.broadcast(sync: true);
  }

  AppUser? _currentUser;
  late final StreamController<AppUser?> _streamController;
  bool shouldFail = false;

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
      throw const AuthException(
        'E-posta veya şifre hatalı.',
        code: 'invalid-credential',
      );
    }
    final user = AppUser(
      id: 'mock-13-uid',
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
      throw const AuthException(
        'Bu e-posta adresi zaten kullanımda.',
        code: 'email-already-in-use',
      );
    }
    final user = AppUser(
      id: 'mock-13-new',
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

class FakeCartRepository implements CartRepository {
  final Map<String, int> _items = {};

  @override
  Future<Map<String, int>> getCartItems() async => Map.unmodifiable(_items);

  @override
  Future<void> saveCartItems(Map<String, int> items) async {
    _items.clear();
    _items.addAll(items);
  }

  @override
  Future<void> clear() async {
    _items.clear();
  }
}

class FakeFavoritesRepository implements FavoritesRepository {
  final Set<String> _favs = {};

  @override
  Future<Set<String>> getFavoriteIds() async => Set.unmodifiable(_favs);

  @override
  Future<void> addFavorite(String productId) async => _favs.add(productId);

  @override
  Future<void> removeFavorite(String productId) async =>
      _favs.remove(productId);

  @override
  Future<bool> isFavorite(String productId) async => _favs.contains(productId);

  @override
  Future<bool> toggleFavorite(String productId) async {
    if (_favs.contains(productId)) {
      _favs.remove(productId);
      return false;
    } else {
      _favs.add(productId);
      return true;
    }
  }

  @override
  Future<void> clear() async => _favs.clear();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  group('Aşama 13 — Navigasyon ve Ekran Entegrasyonu Testleri', () {
    late MockStage13AuthRepository mockAuthRepo;
    late AuthCubit authCubit;

    setUp(() {
      mockAuthRepo = MockStage13AuthRepository();
      authCubit = AuthCubit(authRepository: mockAuthRepo, autoSubscribe: true);
    });

    tearDown(() {
      authCubit.close();
      mockAuthRepo.dispose();
    });

    testWidgets(
      '1. LoginScreen başarılı girişte onLoginSuccess çağırır ve oturum açılır',
      (tester) async {
        bool loginSuccessCalled = false;

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.darkTheme,
            home: LoginScreen(
              authCubit: authCubit,
              onLoginSuccess: () => loginSuccessCalled = true,
            ),
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

    testWidgets(
      '2. RegisterScreen başarılı kayıtta doğrudan onRegisterSuccess çağırır (Login e düşmez)',
      (tester) async {
        bool registerSuccessCalled = false;
        tester.view.physicalSize = const Size(800, 1400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.darkTheme,
            home: RegisterScreen(
              authCubit: authCubit,
              onRegisterSuccess: () => registerSuccessCalled = true,
            ),
          ),
        );
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

        // Doğrudan oturum açılmış olmalı ve başarı geri çağrımı tetiklenmeli
        expect(authCubit.state.isAuthenticated, isTrue);
        expect(registerSuccessCalled, isTrue);
        // Login ekranı açılmamalı
        expect(find.byKey(const ValueKey('login_screen')), findsNothing);
      },
    );

    testWidgets(
      '3. LoginScreen hata aldığında girilen form verileri kaybolmaz',
      (tester) async {
        mockAuthRepo.shouldFail = true;

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.darkTheme,
            home: LoginScreen(authCubit: authCubit),
          ),
        );
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byKey(const ValueKey('login_email_input')),
          'aygen@sparks.fashion',
        );
        await tester.enterText(
          find.byKey(const ValueKey('login_password_input')),
          'WrongPass!',
        );

        await tester.tap(find.byKey(const ValueKey('login_submit_button')));
        await tester.pumpAndSettle();

        // Hata mesajı görünür
        expect(
          find.byKey(const ValueKey('login_error_banner')),
          findsOneWidget,
        );
        // Girilen e-posta input alanında korunur
        final emailField = tester.widget<TextField>(
          find.descendant(
            of: find.byKey(const ValueKey('login_email_input')),
            matching: find.byType(TextField),
          ),
        );
        expect(emailField.controller?.text, 'aygen@sparks.fashion');
      },
    );

    testWidgets(
      '4. RegisterScreen hata aldığında girilen ad soyad ve e-posta kaybolmaz',
      (tester) async {
        mockAuthRepo.shouldFail = true;
        tester.view.physicalSize = const Size(800, 1400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.darkTheme,
            home: RegisterScreen(authCubit: authCubit),
          ),
        );
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

        // Hata bannerı gösterilir
        expect(
          find.byKey(const ValueKey('register_error_banner')),
          findsOneWidget,
        );

        // Girilen değerler korunur
        final nameField = tester.widget<TextField>(
          find.descendant(
            of: find.byKey(const ValueKey('register_name_input')),
            matching: find.byType(TextField),
          ),
        );
        expect(nameField.controller?.text, 'Aygen Yıldırım');

        final emailField = tester.widget<TextField>(
          find.descendant(
            of: find.byKey(const ValueKey('register_email_input')),
            matching: find.byType(TextField),
          ),
        );
        expect(emailField.controller?.text, 'aygen@sparks.fashion');
      },
    );

    testWidgets(
      '5. Kullanıcı kapat butonu ile Login veya Register ekranından güvenle çıkabilir',
      (tester) async {
        bool loginClosed = false;
        bool registerClosed = false;

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.darkTheme,
            home: LoginScreen(
              authCubit: authCubit,
              onClose: () => loginClosed = true,
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const ValueKey('login_close_button')));
        await tester.pumpAndSettle();
        expect(loginClosed, isTrue);

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.darkTheme,
            home: RegisterScreen(
              authCubit: authCubit,
              onClose: () => registerClosed = true,
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const ValueKey('register_close_button')));
        await tester.pumpAndSettle();
        expect(registerClosed, isTrue);
      },
    );

    test('6. Auth durumu değiştiğinde yerel sepet ve favoriler bozulmadan çalışmaya devam eder', () async {
      final fakeCart = FakeCartRepository();
      final fakeFav = FakeFavoritesRepository();
      final cartCubit = CartCubit(
        cartRepository: fakeCart,
        initialItems: {'sparks-test-item': 1},
      );
      final favManager = FavoritesManager(repository: fakeFav);

      // 1. Misafir durumunda sepette ve favorilerde ürün var
      await favManager.toggleFavorite('sparks-test-item');

      expect(cartCubit.state.totalItemCount, 1);
      expect(favManager.isFavorite('sparks-test-item'), isTrue);

      // 2. Kullanıcı oturum açar
      await authCubit.signIn(
        email: 'aygen@sparks.fashion',
        password: 'Password123!',
      );
      expect(authCubit.state.isAuthenticated, isTrue);

      // Sepet ve favoriler korunmalıdır
      expect(cartCubit.state.totalItemCount, 1);
      expect(favManager.isFavorite('sparks-test-item'), isTrue);

      // 3. Kullanıcı çıkış yapar
      await authCubit.signOut();
      expect(authCubit.state.isAuthenticated, isFalse);

      // Sepet ve favoriler cihazda yerel olarak korunmaya devam eder
      expect(cartCubit.state.totalItemCount, 1);
      expect(favManager.isFavorite('sparks-test-item'), isTrue);

      cartCubit.close();
    });
  });
}
