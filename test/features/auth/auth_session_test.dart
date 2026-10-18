import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sparks/app/app.dart';
import 'package:sparks/features/auth/domain/entities/app_user.dart';
import 'package:sparks/features/auth/domain/repositories/auth_repository.dart';
import 'package:sparks/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:sparks/features/auth/presentation/cubit/auth_state.dart';
import 'package:sparks/features/cart/presentation/cubit/cart_cubit.dart';

class FakeSessionAuthRepository implements AuthRepository {
  FakeSessionAuthRepository({AppUser? initialUser})
    : _currentUser = initialUser {
    _streamController = StreamController<AppUser?>.broadcast(sync: true);
  }

  AppUser? _currentUser;
  late final StreamController<AppUser?> _streamController;

  @override
  Stream<AppUser?> get authStateChanges => _streamController.stream;

  @override
  AppUser? get currentUser => _currentUser;

  void emitExternalUser(AppUser? user) {
    _currentUser = user;
    _streamController.add(user);
  }

  @override
  Future<AppUser> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final user = AppUser(
      id: 'session-user-1',
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
      id: 'session-user-2',
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

  group('Aşama 13 — Oturum Yönetimi ve Kalıcılık Testleri', () {
    late FakeSessionAuthRepository fakeRepo;
    late AuthCubit authCubit;

    setUp(() {
      fakeRepo = FakeSessionAuthRepository();
      authCubit = AuthCubit(authRepository: fakeRepo, autoSubscribe: true);
    });

    tearDown(() {
      authCubit.close();
      fakeRepo.dispose();
    });

    test('1. Başlangıçta currentUser varsa checkAuthStatus oturumu authenticated yapar', () async {
      final existingUser = AppUser(
        id: 'existing-123',
        email: 'aygen@sparks.fashion',
        displayName: 'Aygen',
        isEmailVerified: true,
      );
      final populatedRepo = FakeSessionAuthRepository(
        initialUser: existingUser,
      );
      final cubitWithUser = AuthCubit(
        authRepository: populatedRepo,
        autoSubscribe: true,
      );

      await cubitWithUser.checkAuthStatus();

      expect(cubitWithUser.state.status, AuthStatus.authenticated);
      expect(cubitWithUser.state.isAuthenticated, isTrue);
      expect(cubitWithUser.state.user?.email, 'aygen@sparks.fashion');

      cubitWithUser.close();
      populatedRepo.dispose();
    });

    test('2. Başlangıçta currentUser null ise checkAuthStatus unauthenticated durumuna geçirir', () async {
      await authCubit.checkAuthStatus();

      expect(authCubit.state.status, AuthStatus.unauthenticated);
      expect(authCubit.state.isAuthenticated, isFalse);
      expect(authCubit.state.user, isNull);
    });

    test('3. signOut çağrıldığında oturum hemen kapatılır ve kullanıcı unauthenticated olur', () async {
      // Önce oturum aç
      await authCubit.signIn(
        email: 'aygen@sparks.fashion',
        password: 'Password123!',
      );
      expect(authCubit.state.isAuthenticated, isTrue);

      // Çıkış yap
      await authCubit.signOut();
      expect(authCubit.state.status, AuthStatus.unauthenticated);
      expect(authCubit.state.isAuthenticated, isFalse);
      expect(authCubit.state.user, isNull);
    });

    test('4. authStateChanges akışı üzerinden harici oturum değişiklikleri reaktif olarak yansır', () async {
      final incomingUser = AppUser(
        id: 'firebase-restore-uid',
        email: 'restored@sparks.fashion',
        displayName: 'Restored User',
        isEmailVerified: true,
      );

      // Harici Firebase geri yüklemesi simülasyonu
      fakeRepo.emitExternalUser(incomingUser);

      expect(authCubit.state.isAuthenticated, isTrue);
      expect(authCubit.state.user?.email, 'restored@sparks.fashion');

      // Harici çıkış simülasyonu
      fakeRepo.emitExternalUser(null);
      expect(authCubit.state.isAuthenticated, isFalse);
      expect(authCubit.state.user, isNull);
    });

    testWidgets(
      '5. SparksApp kök seviyede AuthCubit ve CartCubit i MultiBlocProvider ile sağlar',
      (tester) async {
        await tester.pumpWidget(
          SparksApp(
            authCubit: authCubit,
            cartCubit: CartCubit.instance,
            routerConfig: null,
          ),
        );
        await tester.pumpAndSettle();

        final BuildContext context = tester.element(find.byType(MaterialApp));
        final resolvedAuthCubit = context.read<AuthCubit>();
        final resolvedCartCubit = context.read<CartCubit>();

        expect(resolvedAuthCubit, equals(authCubit));
        expect(resolvedCartCubit, isNotNull);
      },
    );

    testWidgets(
      '6. Oturum kontrolü devam ederken misafir deneyimi korunur ve Login ekranına zorlanmaz',
      (tester) async {
        await tester.pumpWidget(
          SparksApp(
            authCubit: authCubit,
            cartCubit: CartCubit.instance,
            routerConfig: null,
          ),
        );
        await tester.pumpAndSettle();

        // Varsayılan olarak SplashScreen / Lookbook açılır, zorunlu Login açılmaz
        expect(find.byKey(const ValueKey('login_screen')), findsNothing);
      },
    );
  });
}
