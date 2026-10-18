import 'package:sparks/features/auth/domain/entities/app_user.dart';

/// SPARKS Kimlik Doğrulama Hata Nesnesi (Domain Exception).
class AuthException implements Exception {
  const AuthException(this.message, {this.code});

  /// Kullanıcıya gösterilecek Türkçe açıklayıcı hata mesajı
  final String message;

  /// Firebase veya sistem hata kodu (ör: user-not-found, wrong-password vb.)
  final String? code;

  @override
  String toString() => 'AuthException: $message (code: $code)';
}

/// SPARKS Kimlik Doğrulama Sözleşmesi (AuthRepository).
///
/// Clean Architecture prensiplerine uygun olarak domain katmanında yer alır.
/// UI ve Cubit katmanları doğrudan Firebase'e değil bu arayüze bağımlıdır.
abstract class AuthRepository {
  /// Kullanıcının anlık oturum durumunu dinleyen reaktif akış (Stream).
  Stream<AppUser?> get authStateChanges;

  /// Bellekteki geçerli kullanıcı örneği (oturum açık değilse `null`).
  AppUser? get currentUser;

  /// E-posta ve şifre ile sisteme giriş yapar.
  Future<AppUser> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// E-posta, şifre ve isteğe bağlı isim ile yeni kullanıcı hesabı oluşturur.
  Future<AppUser> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  });

  /// Kullanıcının oturumunu güvenle sonlandırır.
  Future<void> signOut();

  /// Belirtilen e-posta adresine parola sıfırlama bağlantısı gönderir.
  Future<void> sendPasswordResetEmail({required String email});

  /// Geçerli oturum açmış kullanıcıya e-posta doğrulama iletisi gönderir.
  Future<void> sendEmailVerification();
}
