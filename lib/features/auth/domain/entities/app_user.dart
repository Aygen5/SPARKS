import 'package:flutter/foundation.dart';

/// SPARKS Kimlik Doğrulama Kullanıcı Modeli (AppUser).
///
/// Firebase `User` nesnesini doğrudan UI katmanına taşımak yerine,
/// Clean Architecture prensiplerine uygun olarak bağımsız bir domain entity olarak tutulur.
@immutable
class AppUser {
  const AppUser({
    required this.id,
    required this.email,
    this.displayName,
    this.isEmailVerified = false,
  });

  /// Kullanıcının benzersiz kimliği (Firebase UID)
  final String id;

  /// Kullanıcının e-posta adresi
  final String email;

  /// Kullanıcının adı veya editoryal takma adı
  final String? displayName;

  /// E-posta doğrulama durumu
  final bool isEmailVerified;

  /// Kullanıcı adının veya e-postanın editoryal gösterim adı
  String get formattedName {
    if (displayName != null && displayName!.trim().isNotEmpty) {
      return displayName!.trim();
    }
    return email.split('@').first.toUpperCase();
  }

  AppUser copyWith({
    String? id,
    String? email,
    String? displayName,
    bool? isEmailVerified,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppUser &&
        other.id == id &&
        other.email == email &&
        other.displayName == displayName &&
        other.isEmailVerified == isEmailVerified;
  }

  @override
  int get hashCode => Object.hash(id, email, displayName, isEmailVerified);

  @override
  String toString() =>
      'AppUser(id: $id, email: $email, displayName: $displayName, isEmailVerified: $isEmailVerified)';
}
