import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sparks/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:sparks/features/auth/domain/entities/app_user.dart';
import 'package:sparks/features/auth/domain/repositories/auth_repository.dart';
import 'package:sparks/features/auth/presentation/cubit/auth_state.dart';

/// SPARKS Merkezi Kimlik Doğrulama Yöneticisi (AuthCubit).
///
/// Bütün ekranlarda kullanıcı oturum durumunu (Single Source of Truth) yönetir.
/// Firebase auth durumunu reaktif bir akış ile dinler ve UI katmanına
/// test edilebilir, saf durumlar aktarır.
class AuthCubit extends Cubit<AuthState> {
  AuthCubit({AuthRepository? authRepository, bool autoSubscribe = true})
    : _authRepository = authRepository ?? AuthRepositoryImpl(),
      super(const AuthState.initial()) {
    if (autoSubscribe) {
      _initAuthSubscription();
    }
  }

  /// Singleton / küresel erişim örneği
  static AuthCubit instance = AuthCubit();

  /// Testler için durumu sıfırlar veya yeni bir örnek enjekte eder
  static void resetForTesting([AuthCubit? newInstance]) {
    instance = newInstance ?? AuthCubit();
  }

  final AuthRepository _authRepository;
  StreamSubscription<AppUser?>? _authSubscription;

  void _initAuthSubscription() {
    _authSubscription = _authRepository.authStateChanges.listen((user) {
      if (user != null) {
        emit(AuthState.authenticated(user));
      } else {
        // İşlem ortasında değilsek oturum kapalı durumuna geç
        if (!state.isLoading) {
          emit(const AuthState.unauthenticated());
        }
      }
    });
  }

  /// Mevcut oturum durumunu başlangıçta kontrol eder
  Future<void> checkAuthStatus() async {
    try {
      final current = _authRepository.currentUser;
      if (current != null) {
        emit(AuthState.authenticated(current));
      } else {
        emit(const AuthState.unauthenticated());
      }
    } catch (_) {
      emit(const AuthState.unauthenticated());
    }
  }

  /// E-posta ve şifre ile giriş yapar
  Future<bool> signIn({required String email, required String password}) async {
    emit(AuthState.loading(currentUser: state.user));

    try {
      final user = await _authRepository.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      emit(AuthState.authenticated(user));
      return true;
    } on AuthException catch (e) {
      emit(AuthState.error(e.message, previousUser: state.user));
      return false;
    } catch (e) {
      emit(
        AuthState.error(
          'Giriş yapılırken beklenmeyen bir hata oluştu: $e',
          previousUser: state.user,
        ),
      );
      return false;
    }
  }

  /// E-posta ve şifre ile yeni hesap oluşturur
  Future<bool> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    emit(AuthState.loading(currentUser: state.user));

    try {
      final user = await _authRepository.signUpWithEmailAndPassword(
        email: email,
        password: password,
        displayName: displayName,
      );
      emit(AuthState.authenticated(user));
      return true;
    } on AuthException catch (e) {
      emit(AuthState.error(e.message, previousUser: state.user));
      return false;
    } catch (e) {
      emit(
        AuthState.error(
          'Kayıt oluşturulurken beklenmeyen bir hata oluştu: $e',
          previousUser: state.user,
        ),
      );
      return false;
    }
  }

  /// Kullanıcı oturumunu sonlandırır
  Future<void> signOut() async {
    emit(AuthState.loading(currentUser: state.user));

    try {
      await _authRepository.signOut();
      emit(const AuthState.unauthenticated());
    } on AuthException catch (e) {
      emit(AuthState.error(e.message, previousUser: state.user));
    } catch (e) {
      emit(
        AuthState.error(
          'Çıkış yapılırken bir hata oluştu: $e',
          previousUser: state.user,
        ),
      );
    }
  }

  /// Parola sıfırlama bağlantısı gönderir
  Future<bool> sendPasswordResetEmail({required String email}) async {
    emit(AuthState.loading(currentUser: state.user));

    try {
      await _authRepository.sendPasswordResetEmail(email: email);
      emit(
        state.user != null
            ? AuthState.authenticated(state.user!)
            : const AuthState.unauthenticated(),
      );
      return true;
    } on AuthException catch (e) {
      emit(AuthState.error(e.message, previousUser: state.user));
      return false;
    } catch (e) {
      emit(
        AuthState.error(
          'Parola sıfırlama e-postası gönderilemedi: $e',
          previousUser: state.user,
        ),
      );
      return false;
    }
  }

  /// Doğrulama e-postası gönderir
  Future<bool> sendEmailVerification() async {
    emit(AuthState.loading(currentUser: state.user));

    try {
      await _authRepository.sendEmailVerification();
      emit(
        state.user != null
            ? AuthState.authenticated(state.user!)
            : const AuthState.unauthenticated(),
      );
      return true;
    } on AuthException catch (e) {
      emit(AuthState.error(e.message, previousUser: state.user));
      return false;
    } catch (e) {
      emit(
        AuthState.error(
          'Doğrulama e-postası gönderilemedi: $e',
          previousUser: state.user,
        ),
      );
      return false;
    }
  }

  /// Hata durumunu temizler ve önceki oturum durumuna döner
  void clearError() {
    emit(
      AuthState(
        status: state.user != null
            ? AuthStatus.authenticated
            : AuthStatus.unauthenticated,
        user: state.user,
        errorMessage: null,
      ),
    );
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
