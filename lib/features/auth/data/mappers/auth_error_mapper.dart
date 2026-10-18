/// Firebase Authentication hata kodlarını kullanıcı dostu Türkçe mesajlara dönüştüren yardımcı sınıf.
class AuthErrorMapper {
  const AuthErrorMapper._();

  /// Verilen Firebase hata koduna (`code`) karşılık gelen Türkçe mesajı döner.
  static String mapErrorCode(String? code, [String? defaultMessage]) {
    switch (code) {
      case 'user-not-found':
        return 'Bu e-posta adresiyle kayıtlı bir hesap bulunamadı.';
      case 'wrong-password':
        return 'Hatalı şifre girdiniz. Lütfen tekrar deneyiniz.';
      case 'invalid-credential':
        return 'E-posta veya şifre hatalı. Lütfen bilgilerinizi kontrol ediniz.';
      case 'email-already-in-use':
        return 'Bu e-posta adresi zaten başka bir hesap tarafından kullanılıyor.';
      case 'invalid-email':
        return 'Geçersiz bir e-posta adresi girdiniz.';
      case 'weak-password':
        return 'Şifreniz çok zayıf. Lütfen en az 6 karakterli daha güçlü bir şifre belirleyiniz.';
      case 'user-disabled':
        return 'Bu kullanıcı hesabı askıya alınmıştır. Lütfen destek ile iletişime geçiniz.';
      case 'too-many-requests':
        return 'Çok fazla başarısız deneme yapıldı. Güvenliğiniz için lütfen biraz bekleyip tekrar deneyiniz.';
      case 'operation-not-allowed':
        return 'E-posta ve şifre sağlayıcısı Firebase Console üzerinden etkinleştirilmemiştir.';
      case 'network-request-failed':
        return 'İnternet bağlantınızı kontrol edip tekrar deneyiniz.';
      case 'channel-error':
        return 'Lütfen e-posta ve şifre alanlarını eksiksiz doldurunuz.';
      case 'requires-recent-login':
        return 'Bu işlem için yakın zamanda oturum açmış olmanız gerekmektedir. Lütfen tekrar giriş yapınız.';
      default:
        return defaultMessage ??
            'Kimlik doğrulama işlemi sırasında bir hata oluştu. Lütfen tekrar deneyiniz.';
    }
  }
}
