import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:sparks/features/auth/domain/entities/app_user.dart';
import 'package:sparks/features/auth/domain/repositories/auth_repository.dart';
import 'package:sparks/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:sparks/features/auth/presentation/cubit/auth_state.dart';

class MockAuthRepository implements AuthRepository {
  MockAuthRepository({AppUser? initialUser}) : _currentUser = initialUser {
    _streamController = StreamController<AppUser?>.broadcast();
  }

  AppUser? _currentUser;
  late final StreamController<AppUser?> _streamController;

  bool shouldFail = false;
  String failureCode = 'user-not-found';
  String failureMessage = 'Bu e-posta adresiyle kayıtlı bir hesap bulunamadı.';

  void emitAuthState(AppUser? user) {
    _currentUser = user;
    _streamController.add(user);
  }

  @override
  Stream<AppUser?> get authStateChanges => _streamController.stream;

  @override
  AppUser? get currentUser => _currentUser;

  @override
  Future<AppUser> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 10));
    if (shouldFail) {
      throw AuthException(failureMessage, code: failureCode);
    }
    final user = AppUser(
      id: 'mock-uid-1',
      email: email,
      displayName: 'Test Kullanıcı',
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
    await Future<void>.delayed(const Duration(milliseconds: 10));
    if (shouldFail) {
      throw AuthException(failureMessage, code: failureCode);
    }
    final user = AppUser(
      id: 'mock-uid-2',
      email: email,
      displayName: displayName ?? 'Yeni Üye',
      isEmailVerified: false,
    );
    _currentUser = user;
    _streamController.add(user);
    return user;
  }

  @override
  Future<void> signOut() async {
    await Future<void>.delayed(const Duration(milliseconds: 10));
    if (shouldFail) {
      throw AuthException(failureMessage, code: failureCode);
    }
    _currentUser = null;
    _streamController.add(null);
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    if (shouldFail) {
      throw AuthException(failureMessage, code: failureCode);
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    if (shouldFail) {
      throw AuthException(failureMessage, code: failureCode);
    }
  }

  void dispose() {
    _streamController.close();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Aşama 11 — AuthCubit Birim Testleri', () {
    late MockAuthRepository mockRepo;
    late AuthCubit cubit;

    setUp(() {
      mockRepo = MockAuthRepository();
      cubit = AuthCubit(authRepository: mockRepo);
    });

    tearDown(() {
      cubit.close();
      mockRepo.dispose();
    });

    test('1. Başlangıç durumu AuthStatus.initial dır', () {
      expect(cubit.state.status, AuthStatus.initial);
      expect(cubit.state.user, isNull);
      expect(cubit.state.isAuthenticated, isFalse);
      expect(cubit.state.isInitial, isTrue);
    });

    test(
      '2. checkAuthStatus oturum yoksa unauthenticated durumuna geçirir',
      () async {
        await cubit.checkAuthStatus();

        expect(cubit.state.status, AuthStatus.unauthenticated);
        expect(cubit.state.isAuthenticated, isFalse);
        expect(cubit.state.isUnauthenticated, isTrue);
      },
    );

    test(
      '3. checkAuthStatus oturum varsa authenticated durumuna geçirir',
      () async {
        const existingUser = AppUser(
          id: 'existing-id',
          email: 'aygen@sparks.fashion',
          displayName: 'Aygen',
        );
        final repoWithUser = MockAuthRepository(initialUser: existingUser);
        final cubitWithUser = AuthCubit(authRepository: repoWithUser);

        await cubitWithUser.checkAuthStatus();

        expect(cubitWithUser.state.status, AuthStatus.authenticated);
        expect(cubitWithUser.state.isAuthenticated, isTrue);
        expect(cubitWithUser.state.user?.email, 'aygen@sparks.fashion');

        await cubitWithUser.close();
        repoWithUser.dispose();
      },
    );

    test(
      '4. signIn başarılı olduğunda loading ve ardından authenticated yayınlar',
      () async {
        final states = <AuthState>[];
        cubit.stream.listen(states.add);

        final result = await cubit.signIn(
          email: 'aygen@sparks.fashion',
          password: 'Password123!',
        );
        await Future<void>.delayed(const Duration(milliseconds: 10));

        expect(result, isTrue);
        expect(states.length, greaterThanOrEqualTo(2));
        expect(states.first.status, AuthStatus.loading);
        expect(states.last.status, AuthStatus.authenticated);
        expect(cubit.state.isAuthenticated, isTrue);
        expect(cubit.state.user?.email, 'aygen@sparks.fashion');
      },
    );

    test('5. signIn başarısız olduğunda error durumu ve Türkçe hata mesajı yayınlar', () async {
      mockRepo.shouldFail = true;
      mockRepo.failureMessage =
          'E-posta veya şifre hatalı. Lütfen bilgilerinizi kontrol ediniz.';

      final states = <AuthState>[];
      cubit.stream.listen(states.add);

      final result = await cubit.signIn(
        email: 'aygen@sparks.fashion',
        password: 'wrong',
      );

      expect(result, isFalse);
      expect(cubit.state.status, AuthStatus.error);
      expect(cubit.state.hasError, isTrue);
      expect(
        cubit.state.errorMessage,
        'E-posta veya şifre hatalı. Lütfen bilgilerinizi kontrol ediniz.',
      );
    });

    test(
      '6. signUp başarılı olduğunda yeni kullanıcıyı authenticated yapar',
      () async {
        final result = await cubit.signUp(
          email: 'yeni@sparks.fashion',
          password: 'Password123!',
          displayName: 'Yeni Müşteri',
        );

        expect(result, isTrue);
        expect(cubit.state.status, AuthStatus.authenticated);
        expect(cubit.state.user?.displayName, 'Yeni Müşteri');
      },
    );

    test('7. signOut oturumu kapatır ve unauthenticated yapar', () async {
      await cubit.signIn(
        email: 'aygen@sparks.fashion',
        password: 'Password123!',
      );
      expect(cubit.state.isAuthenticated, isTrue);

      await cubit.signOut();

      expect(cubit.state.status, AuthStatus.unauthenticated);
      expect(cubit.state.user, isNull);
    });

    test(
      '8. authStateChanges harici akış değişikliklerine anlık reaksiyon verir',
      () async {
        const externalUser = AppUser(
          id: 'ext-1',
          email: 'harici@sparks.fashion',
        );

        mockRepo.emitAuthState(externalUser);
        // Akışın yayılması için bekle
        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(cubit.state.status, AuthStatus.authenticated);
        expect(cubit.state.user?.email, 'harici@sparks.fashion');

        // Harici çıkış
        mockRepo.emitAuthState(null);
        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(cubit.state.status, AuthStatus.unauthenticated);
        expect(cubit.state.user, isNull);
      },
    );

    test('9. clearError hata mesajını temizler', () async {
      mockRepo.shouldFail = true;
      await cubit.signIn(email: 'fail@sparks.fashion', password: 'fail');
      expect(cubit.state.hasError, isTrue);

      cubit.clearError();

      expect(cubit.state.hasError, isFalse);
      expect(cubit.state.errorMessage, isNull);
      expect(cubit.state.status, AuthStatus.unauthenticated);
    });
  });
}
