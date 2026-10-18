import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:sparks/features/auth/data/mappers/auth_error_mapper.dart';
import 'package:sparks/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:sparks/features/auth/domain/entities/app_user.dart';
import 'package:sparks/features/auth/domain/repositories/auth_repository.dart';

/// Test amaçlı sahte AuthRepository uygulaması
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({AppUser? initialUser}) : _currentUser = initialUser {
    _controller = StreamController<AppUser?>.broadcast();
    if (initialUser != null) {
      _controller.add(initialUser);
    }
  }

  AppUser? _currentUser;
  late final StreamController<AppUser?> _controller;

  bool shouldThrowError = false;
  String errorCode = 'unknown';

  @override
  Stream<AppUser?> get authStateChanges => _controller.stream;

  @override
  AppUser? get currentUser => _currentUser;

  @override
  Future<AppUser> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    if (shouldThrowError) {
      throw AuthException(
        AuthErrorMapper.mapErrorCode(errorCode),
        code: errorCode,
      );
    }
    final user = AppUser(
      id: 'sparks-uid-123',
      email: email,
      displayName: 'Aygen',
      isEmailVerified: true,
    );
    _currentUser = user;
    _controller.add(user);
    return user;
  }

  @override
  Future<AppUser> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    if (shouldThrowError) {
      throw AuthException(
        AuthErrorMapper.mapErrorCode(errorCode),
        code: errorCode,
      );
    }
    final user = AppUser(
      id: 'sparks-uid-new',
      email: email,
      displayName: displayName ?? 'Yeni Kullanıcı',
      isEmailVerified: false,
    );
    _currentUser = user;
    _controller.add(user);
    return user;
  }

  @override
  Future<void> signOut() async {
    if (shouldThrowError) {
      throw AuthException(
        AuthErrorMapper.mapErrorCode(errorCode),
        code: errorCode,
      );
    }
    _currentUser = null;
    _controller.add(null);
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    if (shouldThrowError) {
      throw AuthException(
        AuthErrorMapper.mapErrorCode(errorCode),
        code: errorCode,
      );
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    if (shouldThrowError) {
      throw AuthException(
        AuthErrorMapper.mapErrorCode(errorCode),
        code: errorCode,
      );
    }
  }

  void dispose() {
    _controller.close();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Aşama 11 — AppUser Entity Birim Testleri', () {
    test('1. AppUser alanları, formattedName ve copyWith doğru çalışır', () {
      const user1 = AppUser(
        id: 'u-1',
        email: 'aygen@sparks.fashion',
        displayName: 'Aygen Yıldırım',
        isEmailVerified: true,
      );

      expect(user1.id, 'u-1');
      expect(user1.email, 'aygen@sparks.fashion');
      expect(user1.displayName, 'Aygen Yıldırım');
      expect(user1.formattedName, 'Aygen Yıldırım');
      expect(user1.isEmailVerified, isTrue);

      // Display name yoksa e-posta başı döner
      const userNoName = AppUser(id: 'u-2', email: 'aygen@sparks.fashion');
      expect(userNoName.formattedName, 'AYGEN');

      // copyWith
      final updated = user1.copyWith(displayName: 'Aygen Y.');
      expect(updated.displayName, 'Aygen Y.');
      expect(updated.id, 'u-1');

      // equality
      const userDuplicate = AppUser(
        id: 'u-1',
        email: 'aygen@sparks.fashion',
        displayName: 'Aygen Yıldırım',
        isEmailVerified: true,
      );
      expect(user1, equals(userDuplicate));
    });
  });

  group('Aşama 11 — AuthErrorMapper Türkçe Çeviri Testleri', () {
    test(
      '2. Firebase hata kodları açıklayıcı Türkçe mesajlara dönüştürülür',
      () {
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
          contains('Çok fazla başarısız deneme yapıldı'),
        );
        expect(
          AuthErrorMapper.mapErrorCode('operation-not-allowed'),
          contains('Firebase Console üzerinden etkinleştirilmemiştir'),
        );
        expect(
          AuthErrorMapper.mapErrorCode('network-request-failed'),
          'İnternet bağlantınızı kontrol edip tekrar deneyiniz.',
        );
        expect(
          AuthErrorMapper.mapErrorCode('unknown-random-code'),
          contains('Kimlik doğrulama işlemi sırasında bir hata oluştu'),
        );
      },
    );
  });

  group('Aşama 11 — AuthRepositoryImpl Güvenli Başlatma Testleri', () {
    test('3. Firebase yapılandırılmamışken repository çökmez ve kontrollü davranır', () async {
      final repo = AuthRepositoryImpl();

      // authStateChanges çökmeden boş/null akış döner
      final firstState = await repo.authStateChanges.first;
      expect(firstState, isNull);

      // currentUser çökmeden null döner
      expect(repo.currentUser, isNull);

      // İşlem yapılmak istendiğinde açık bir AuthException fırlatır
      expect(
        () => repo.signInWithEmailAndPassword(
          email: 'test@sparks.fashion',
          password: 'password123',
        ),
        throwsA(
          isA<AuthException>().having(
            (e) => e.code,
            'code',
            'firebase-not-configured',
          ),
        ),
      );
    });
  });

  group('Aşama 11 — FakeAuthRepository Sözleşme Testleri', () {
    late FakeAuthRepository fakeRepo;

    setUp(() {
      fakeRepo = FakeAuthRepository();
    });

    tearDown(() {
      fakeRepo.dispose();
    });

    test(
      '4. FakeAuthRepository ile kayıt ve giriş akışı başarılı çalışır',
      () async {
        expect(fakeRepo.currentUser, isNull);

        final user = await fakeRepo.signUpWithEmailAndPassword(
          email: 'aygen@sparks.fashion',
          password: 'Password123!',
          displayName: 'Aygen',
        );

        expect(user.email, 'aygen@sparks.fashion');
        expect(user.displayName, 'Aygen');
        expect(fakeRepo.currentUser, equals(user));

        // Çıkış
        await fakeRepo.signOut();
        expect(fakeRepo.currentUser, isNull);

        // Yeniden Giriş
        final loggedIn = await fakeRepo.signInWithEmailAndPassword(
          email: 'aygen@sparks.fashion',
          password: 'Password123!',
        );
        expect(loggedIn.email, 'aygen@sparks.fashion');
        expect(fakeRepo.currentUser, isNotNull);
      },
    );

    test('5. Hata durumunda uygun Türkçe AuthException fırlatılır', () async {
      fakeRepo.shouldThrowError = true;
      fakeRepo.errorCode = 'wrong-password';

      expect(
        () => fakeRepo.signInWithEmailAndPassword(
          email: 'aygen@sparks.fashion',
          password: 'wrong',
        ),
        throwsA(
          isA<AuthException>().having(
            (e) => e.message,
            'message',
            'Hatalı şifre girdiniz. Lütfen tekrar deneyiniz.',
          ),
        ),
      );
    });
  });
}
