import 'package:flutter/foundation.dart';
import 'package:sparks/features/auth/domain/entities/app_user.dart';

/// Kimlik doğrulama durum tipleri
enum AuthStatus {
  /// Başlangıç / oturum kontrol ediliyor
  initial,

  /// Oturum açılmamış / misafir kullanıcı
  unauthenticated,

  /// Giriş / kayıt / çıkış işlemi devam ediyor
  loading,

  /// Oturum başarıyla açılmış ve kullanıcı doğrulanmış
  authenticated,

  /// İşlem sırasında hata oluştu
  error,
}

/// SPARKS Merkezi Kimlik Doğrulama Durumu (AuthState).
@immutable
class AuthState {
  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });

  /// Başlangıç durumu fabrika yapıcısı
  const AuthState.initial()
    : status = AuthStatus.initial,
      user = null,
      errorMessage = null;

  /// Oturum açılmamış durum fabrika yapıcısı
  const AuthState.unauthenticated()
    : status = AuthStatus.unauthenticated,
      user = null,
      errorMessage = null;

  /// Yükleniyor durumu fabrika yapıcısı
  const AuthState.loading({AppUser? currentUser})
    : status = AuthStatus.loading,
      user = currentUser,
      errorMessage = null;

  /// Başarılı oturum durumu fabrika yapıcısı
  const AuthState.authenticated(AppUser authenticatedUser)
    : status = AuthStatus.authenticated,
      user = authenticatedUser,
      errorMessage = null;

  /// Hata durumu fabrika yapıcısı
  const AuthState.error(String message, {AppUser? previousUser})
    : status = AuthStatus.error,
      user = previousUser,
      errorMessage = message;

  /// Anlık durum
  final AuthStatus status;

  /// Geçerli oturum açmış kullanıcı nesnesi
  final AppUser? user;

  /// Varsa son hata mesajı (Türkçe)
  final String? errorMessage;

  /// Kullanıcı oturum açmış mı?
  bool get isAuthenticated =>
      status == AuthStatus.authenticated && user != null;

  /// Bir auth işlemi yürütülüyor mu?
  bool get isLoading => status == AuthStatus.loading;

  /// İlk başlangıç veya kontrol aşaması mı?
  bool get isInitial => status == AuthStatus.initial;

  /// Kullanıcı oturumu kapalı mı?
  bool get isUnauthenticated => status == AuthStatus.unauthenticated;

  /// Hata durumu var mı?
  bool get hasError => status == AuthStatus.error && errorMessage != null;

  AuthState copyWith({
    AuthStatus? status,
    AppUser? user,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthState &&
        other.status == status &&
        other.user == user &&
        other.errorMessage == errorMessage;
  }

  @override
  int get hashCode => Object.hash(status, user, errorMessage);

  @override
  String toString() =>
      'AuthState(status: $status, user: $user, errorMessage: $errorMessage)';
}
