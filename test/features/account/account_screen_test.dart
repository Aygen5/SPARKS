import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sparks/app/theme/app_theme.dart';
import 'package:sparks/features/account/presentation/account_screen.dart';
import 'package:sparks/features/auth/domain/entities/app_user.dart';
import 'package:sparks/features/auth/domain/repositories/auth_repository.dart';
import 'package:sparks/features/auth/presentation/cubit/auth_cubit.dart';

class FakeAccountTestAuthRepository implements AuthRepository {
  FakeAccountTestAuthRepository({AppUser? initialUser})
    : _currentUser = initialUser {
    _streamController = StreamController<AppUser?>.broadcast(sync: true);
  }

  AppUser? _currentUser;
  late final StreamController<AppUser?> _streamController;

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
      id: 'acc-user-1',
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
    final user = AppUser(
      id: 'acc-user-2',
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

  Widget createAccountWidget({
    required AuthCubit cubit,
    VoidCallback? onLoginTap,
    VoidCallback? onRegisterTap,
    VoidCallback? onLogoutTap,
    VoidCallback? onNavigateToFavorites,
    VoidCallback? onNavigateToOrders,
    VoidCallback? onNavigateToCart,
  }) {
    return MaterialApp(
      theme: AppTheme.darkTheme,
      home: BlocProvider<AuthCubit>.value(
        value: cubit,
        child: AccountScreen(
          authCubit: cubit,
          onLoginTap: onLoginTap,
          onRegisterTap: onRegisterTap,
          onLogoutTap: onLogoutTap,
          onNavigateToFavorites: onNavigateToFavorites,
          onNavigateToOrders: onNavigateToOrders,
          onNavigateToCart: onNavigateToCart,
        ),
      ),
    );
  }

  group('Aşama 13 — Hesabım Ekranı (AccountScreen) Testleri', () {
    late FakeAccountTestAuthRepository fakeRepo;
    late AuthCubit authCubit;

    setUp(() {
      fakeRepo = FakeAccountTestAuthRepository();
      authCubit = AuthCubit(authRepository: fakeRepo, autoSubscribe: true);
    });

    tearDown(() {
      authCubit.close();
      fakeRepo.dispose();
    });

    testWidgets('1. Hesabım ekranı hatasız açılır ve başlığı gösterir', (
      tester,
    ) async {
      await tester.pumpWidget(createAccountWidget(cubit: authCubit));
      await tester.pumpAndSettle();

      expect(find.text('HESAP'), findsOneWidget);
      expect(find.byKey(const ValueKey('account_screen_list')), findsOneWidget);
    });

    testWidgets(
      '2. Misafir kullanıcı durumunda misafir kartı ve giriş/kayıt butonları gösterilir',
      (tester) async {
        await tester.pumpWidget(createAccountWidget(cubit: authCubit));
        await tester.pumpAndSettle();

        expect(
          find.byKey(const ValueKey('account_guest_card')),
          findsOneWidget,
        );
        expect(find.text('MİSAFİR KULLANICI'), findsOneWidget);
        expect(find.text('Giriş yapılmadı'), findsOneWidget);
        expect(
          find.byKey(const ValueKey('account_login_button')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('account_register_button')),
          findsOneWidget,
        );

        // Giriş yapılmadığında kullanıcı kartı veya sahte e-posta olmamalı
        expect(find.byKey(const ValueKey('account_user_card')), findsNothing);
      },
    );

    testWidgets(
      '3. Misafir durumunda GİRİŞ YAP ve KAYIT OL butonları doğru geri çağrımları tetikler',
      (tester) async {
        bool loginTapped = false;
        bool registerTapped = false;

        await tester.pumpWidget(
          createAccountWidget(
            cubit: authCubit,
            onLoginTap: () => loginTapped = true,
            onRegisterTap: () => registerTapped = true,
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const ValueKey('account_login_button')));
        await tester.pumpAndSettle();
        expect(loginTapped, isTrue);

        await tester.tap(find.byKey(const ValueKey('account_register_button')));
        await tester.pumpAndSettle();
        expect(registerTapped, isTrue);
      },
    );

    testWidgets(
      '4. Oturum açmış kullanıcı durumunda kullanıcı kartı ve gerçek e-posta gösterilir',
      (tester) async {
        await authCubit.signIn(
          email: 'aygen@sparks.fashion',
          password: 'Password123!',
        );

        await tester.pumpWidget(createAccountWidget(cubit: authCubit));
        await tester.pumpAndSettle();

        // Misafir kartı gizlenmeli, kullanıcı kartı açılmalı
        expect(find.byKey(const ValueKey('account_guest_card')), findsNothing);
        expect(find.byKey(const ValueKey('account_user_card')), findsOneWidget);

        // Gerçek kullanıcı bilgileri
        expect(find.text('Aygen Yıldırım'), findsOneWidget);
        expect(find.text('aygen@sparks.fashion'), findsOneWidget);
        expect(
          find.byKey(const ValueKey('account_logout_button')),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      '5. Çıkış Yap tıklandığında onay dialogu açılır, onaylanınca misafir durumuna döner',
      (tester) async {
        await authCubit.signIn(
          email: 'aygen@sparks.fashion',
          password: 'Password123!',
        );

        await tester.pumpWidget(createAccountWidget(cubit: authCubit));
        await tester.pumpAndSettle();

        // ÇIKIŞ YAP butonuna tıkla
        await tester.tap(find.byKey(const ValueKey('account_logout_button')));
        await tester.pumpAndSettle();

        // Onay dialogu görünür
        expect(
          find.byKey(const ValueKey('account_logout_confirm_dialog')),
          findsOneWidget,
        );
        expect(find.text('OTURUMU KAPAT'), findsOneWidget);

        // Çıkış yap butonuna onayla
        await tester.tap(
          find.byKey(const ValueKey('account_logout_confirm_button')),
        );
        await tester.pumpAndSettle();

        // Dialog kapanır ve oturum kapatılır -> Misafir kartına dönülür
        expect(authCubit.state.isAuthenticated, isFalse);
        expect(
          find.byKey(const ValueKey('account_guest_card')),
          findsOneWidget,
        );
        expect(find.text('MİSAFİR KULLANICI'), findsOneWidget);
        expect(find.byKey(const ValueKey('account_user_card')), findsNothing);
      },
    );

    testWidgets(
      '6. Çıkış onay dialogunda VAZGEÇ tıklandığında oturum korunur',
      (tester) async {
        await authCubit.signIn(
          email: 'aygen@sparks.fashion',
          password: 'Password123!',
        );

        await tester.pumpWidget(createAccountWidget(cubit: authCubit));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const ValueKey('account_logout_button')));
        await tester.pumpAndSettle();

        // VAZGEÇ tıkla
        await tester.tap(
          find.byKey(const ValueKey('account_logout_cancel_button')),
        );
        await tester.pumpAndSettle();

        // Oturum hala açık kalmalı
        expect(authCubit.state.isAuthenticated, isTrue);
        expect(find.byKey(const ValueKey('account_user_card')), findsOneWidget);
      },
    );

    testWidgets('7. FAVORİLERİM kısayolu doğru eylemi tetikler', (
      tester,
    ) async {
      bool favoritesTapped = false;

      await tester.pumpWidget(
        createAccountWidget(
          cubit: authCubit,
          onNavigateToFavorites: () => favoritesTapped = true,
        ),
      );
      await tester.pumpAndSettle();

      final favItem = find.byKey(const ValueKey('account_favorites_button'));
      expect(favItem, findsOneWidget);
      expect(find.text('FAVORİLERİM'), findsOneWidget);

      await tester.tap(favItem);
      await tester.pumpAndSettle();

      expect(favoritesTapped, isTrue);
    });

    testWidgets('8. ALIŞVERİŞLERİM kısayolu doğru eylemi tetikler', (
      tester,
    ) async {
      bool ordersTapped = false;

      await tester.pumpWidget(
        createAccountWidget(
          cubit: authCubit,
          onNavigateToOrders: () => ordersTapped = true,
        ),
      );
      await tester.pumpAndSettle();

      final ordersItem = find.byKey(const ValueKey('account_orders_button'));
      expect(ordersItem, findsOneWidget);
      expect(find.text('ALIŞVERİŞLERİM'), findsOneWidget);

      await tester.tap(ordersItem);
      await tester.pumpAndSettle();

      expect(ordersTapped, isTrue);
    });

    testWidgets('9. SEPETİM kısayolu doğru eylemi tetikler', (tester) async {
      bool cartTapped = false;

      await tester.pumpWidget(
        createAccountWidget(
          cubit: authCubit,
          onNavigateToCart: () => cartTapped = true,
        ),
      );
      await tester.pumpAndSettle();

      final cartItem = find.byKey(const ValueKey('account_cart_button'));
      expect(cartItem, findsOneWidget);
      expect(find.text('SEPETİM'), findsOneWidget);

      await tester.tap(cartItem);
      await tester.pumpAndSettle();

      expect(cartTapped, isTrue);
    });

    testWidgets('10. Destek ve sürüm bilgisi bölümü doğru görüntülenir', (
      tester,
    ) async {
      await tester.pumpWidget(createAccountWidget(cubit: authCubit));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('account_support_section')),
        findsOneWidget,
      );
      expect(find.text('SPARKS v1.0.0'), findsOneWidget);
      expect(
        find.text('Müşteri Desteği: destek@sparks.fashion'),
        findsOneWidget,
      );
    });

    testWidgets(
      '11. Dar ekran boyutlarında (360x640) AccountScreen taşma olmadan render edilir',
      (tester) async {
        tester.view.physicalSize = const Size(360, 640);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(createAccountWidget(cubit: authCubit));
        await tester.pumpAndSettle();

        expect(
          find.byKey(const ValueKey('account_guest_card')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('account_favorites_button')),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      },
    );
  });
}
