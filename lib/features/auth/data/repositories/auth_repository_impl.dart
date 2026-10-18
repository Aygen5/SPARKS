import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sparks/features/auth/data/mappers/auth_error_mapper.dart';
import 'package:sparks/features/auth/domain/entities/app_user.dart';
import 'package:sparks/features/auth/domain/repositories/auth_repository.dart';

/// Firebase Authentication tabanlı AuthRepository uygulaması.
///
/// Firebase yapılandırması henüz yapılmamışsa veya test ortamındaysa
/// uygulamanın çökmesini engeller ve açık bir bilgilendirme hatası fırlatır.
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({FirebaseAuth? firebaseAuth})
    : _customFirebaseAuth = firebaseAuth;

  final FirebaseAuth? _customFirebaseAuth;

  /// Güvenli FirebaseAuth erişimi
  FirebaseAuth get _auth {
    final customAuth = _customFirebaseAuth;
    if (customAuth != null) {
      return customAuth;
    }

    // Firebase henüz initialize edilmemişse kontrollü hata fırlat
    if (Firebase.apps.isEmpty) {
      throw const AuthException(
        'Firebase bağlantısı henüz yapılandırılmamıştır. '
        'Lütfen Firebase Console üzerinden projenizi oluşturup FlutterFire kurulumunu tamamlayınız.',
        code: 'firebase-not-configured',
      );
    }

    return FirebaseAuth.instance;
  }

  bool get isFirebaseAvailable {
    if (_customFirebaseAuth != null) return true;
    try {
      return Firebase.apps.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  AppUser? _mapFirebaseUser(User? user) {
    if (user == null) return null;
    return AppUser(
      id: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
      isEmailVerified: user.emailVerified,
    );
  }

  @override
  Stream<AppUser?> get authStateChanges {
    try {
      if (!isFirebaseAvailable) {
        return Stream.value(null);
      }
      return _auth.authStateChanges().map(_mapFirebaseUser);
    } catch (_) {
      return Stream.value(null);
    }
  }

  @override
  AppUser? get currentUser {
    try {
      if (!isFirebaseAvailable) return null;
      return _mapFirebaseUser(_auth.currentUser);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<AppUser> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw const AuthException(
          'Kullanıcı oturumu doğrulanamadı.',
          code: 'user-null',
        );
      }

      return _mapFirebaseUser(user)!;
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        AuthErrorMapper.mapErrorCode(e.code, e.message),
        code: e.code,
      );
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException(
        'Giriş yapılırken beklenmeyen bir hata oluştu: $e',
        code: 'unknown',
      );
    }
  }

  @override
  Future<AppUser> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw const AuthException(
          'Hesap oluşturuldu ancak kullanıcı verisi alınamadı.',
          code: 'user-null',
        );
      }

      if (displayName != null && displayName.trim().isNotEmpty) {
        await user.updateDisplayName(displayName.trim());
      }

      return _mapFirebaseUser(user)!;
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        AuthErrorMapper.mapErrorCode(e.code, e.message),
        code: e.code,
      );
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException(
        'Kayıt işlemi sırasında beklenmeyen bir hata oluştu: $e',
        code: 'unknown',
      );
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        AuthErrorMapper.mapErrorCode(e.code, e.message),
        code: e.code,
      );
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException(
        'Çıkış yapılırken bir hata oluştu: $e',
        code: 'unknown',
      );
    }
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        AuthErrorMapper.mapErrorCode(e.code, e.message),
        code: e.code,
      );
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException(
        'Parola sıfırlama e-postası gönderilemedi: $e',
        code: 'unknown',
      );
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw const AuthException(
          'Doğrulama e-postası göndermek için oturum açılmış olmalıdır.',
          code: 'no-current-user',
        );
      }
      await user.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        AuthErrorMapper.mapErrorCode(e.code, e.message),
        code: e.code,
      );
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException(
        'E-posta doğrulama gönderilirken bir hata oluştu: $e',
        code: 'unknown',
      );
    }
  }
}
