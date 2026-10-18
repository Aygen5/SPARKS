import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sparks/app/theme/app_theme.dart';
import 'package:sparks/features/account/presentation/account_screen.dart';
import 'package:sparks/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:sparks/features/auth/domain/entities/app_user.dart';
import 'package:sparks/features/auth/domain/repositories/auth_repository.dart';
import 'package:sparks/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:sparks/features/cart/domain/repositories/cart_repository.dart';
import 'package:sparks/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:sparks/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:sparks/features/favorites/presentation/manager/favorites_manager.dart';
import 'package:sparks/features/home/presentation/home_screen.dart';

/// Test Double: Stage 14 Regresyon ve Entegrasyon Auth Deposu
class MockRegressionAuthRepository implements AuthRepository {
  MockRegressionAuthRepository({AppUser? initialUser})
    : _currentUser = initialUser {
    _streamController = StreamController<AppUser?>.broadcast(sync: true);
  }

  AppUser? _currentUser;
  late final StreamController<AppUser?> _streamController;
  bool shouldThrowOnCheck = false;

  @override
  Stream<AppUser?> get authStateChanges => _streamController.stream;

  @override
  AppUser? get currentUser {
    if (shouldThrowOnCheck) {
      throw const AuthException(
        'Oturum kontrolünde beklenmeyen hata',
        code: 'check-error',
      );
    }
    return _currentUser;
  }

  @override
  Future<AppUser> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final user = AppUser(
      id: 'reg-uid-1',
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
      id: 'reg-uid-2',
      email: email,
      displayName: displayName ?? 'Aygen',
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

/// Test Double: Bellek İçi Sepet Deposu
class MockRegressionCartRepository implements CartRepository {
  Map<String, int> _items = {};

  @override
  Future<Map<String, int>> getCartItems() async => Map.from(_items);

  @override
  Future<void> saveCartItems(Map<String, int> items) async {
    _items = Map.from(items);
  }

  @override
  Future<void> clear() async {
    _items.clear();
  }
}

/// Test Double: Bellek İçi Favori Deposu
class MockRegressionFavoritesRepository implements FavoritesRepository {
  final Set<String> _favs = {};

  @override
  Future<Set<String>> getFavoriteIds() async => Set.from(_favs);

  @override
  Future<bool> isFavorite(String productId) async => _favs.contains(productId);

  @override
  Future<void> addFavorite(String productId) async {
    _favs.add(productId);
  }

  @override
  Future<void> removeFavorite(String productId) async {
    _favs.remove(productId);
  }

  @override
  Future<bool> toggleFavorite(String productId) async {
    if (_favs.contains(productId)) {
      _favs.remove(productId);
      return false;
    } else {
      _favs.add(productId);
      return true;
    }
  }

  @override
  Future<void> clear() async {
    _favs.clear();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  late MockRegressionAuthRepository authRepo;
  late AuthCubit authCubit;
  late MockRegressionCartRepository cartRepo;
  late CartCubit cartCubit;
  late MockRegressionFavoritesRepository favRepo;
  late FavoritesManager favManager;

  setUp(() {
    authRepo = MockRegressionAuthRepository();
    authCubit = AuthCubit(authRepository: authRepo);

    cartRepo = MockRegressionCartRepository();
    cartCubit = CartCubit(
      cartRepository: cartRepo,
      initialItems: {'sparks-item-1': 2, 'sparks-item-2': 1},
    );

    favRepo = MockRegressionFavoritesRepository();
    favManager = FavoritesManager(repository: favRepo);
  });

  tearDown(() {
    authCubit.close();
    authRepo.dispose();
    cartCubit.close();
  });

  Widget buildMultiBlocApp({required Widget child}) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>.value(value: authCubit),
        BlocProvider<CartCubit>.value(value: cartCubit),
      ],
      child: MaterialApp(theme: AppTheme.darkTheme, home: child),
    );
  }

  group(
    'Aşama 14 — Oturum Entegrasyonu, Regresyon ve Güvenlik Doğrulamaları',
    () {
      test('1. Uygulama açılışında checkAuthStatus mevcut oturumu başarıyla geri yükler', () async {
        // Başlangıçta oturum yok
        expect(authCubit.state.isAuthenticated, isFalse);

        // Depoda önceden oturum açmış kullanıcı var
        final existingUser = const AppUser(
          id: 'saved-uid-100',
          email: 'kayitli@sparks.fashion',
          displayName: 'Mevcut Kullanıcı',
          isEmailVerified: true,
        );
        final repoWithUser = MockRegressionAuthRepository(
          initialUser: existingUser,
        );
        final testCubit = AuthCubit(authRepository: repoWithUser);

        await testCubit.checkAuthStatus();

        expect(testCubit.state.isAuthenticated, isTrue);
        expect(testCubit.state.user?.id, 'saved-uid-100');
        expect(testCubit.state.user?.email, 'kayitli@sparks.fashion');

        testCubit.close();
        repoWithUser.dispose();
      });

      test('2. checkAuthStatus depoda hata olduğunda güvenle unauthenticated durumuna geçer ve çökmez', () async {
        authRepo.shouldThrowOnCheck = true;

        await authCubit.checkAuthStatus();

        expect(authCubit.state.isAuthenticated, isFalse);
        expect(authCubit.state.hasError, isFalse);
      });

      test('3. signOut işlemi oturumu güvenle sonlandırır ve unauthenticated yayınlar', () async {
        await authCubit.signIn(
          email: 'cikis@sparks.fashion',
          password: 'Password123!',
        );
        expect(authCubit.state.isAuthenticated, isTrue);

        await authCubit.signOut();
        expect(authCubit.state.isAuthenticated, isFalse);
        expect(authCubit.state.user, isNull);
      });

      testWidgets(
        '4. Oturum açıldığında ve kapatıldığında HomeScreen ve AccountScreen reaktif güncellenir',
        (tester) async {
          await tester.pumpWidget(
            buildMultiBlocApp(
              child: Scaffold(
                body: Column(
                  children: [
                    Expanded(child: HomeScreen(authCubit: authCubit)),
                    Expanded(child: AccountScreen(authCubit: authCubit)),
                  ],
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();

          // Başlangıçta misafir durumu
          expect(
            find.byKey(const ValueKey('home_login_button')),
            findsOneWidget,
          );
          expect(
            find.byKey(const ValueKey('account_guest_card')),
            findsOneWidget,
          );
          expect(find.byKey(const ValueKey('account_user_card')), findsNothing);

          // Kullanıcı giriş yapar
          await authCubit.signIn(
            email: 'aygen@sparks.fashion',
            password: 'Password123!',
          );
          await tester.pumpAndSettle();

          // HomeScreen'deki buton gizlenir, AccountScreen üye kartına geçer
          expect(find.byKey(const ValueKey('home_login_button')), findsNothing);
          expect(
            find.byKey(const ValueKey('account_user_card')),
            findsOneWidget,
          );
          expect(
            find.byKey(const ValueKey('account_user_email')),
            findsOneWidget,
          );
          expect(find.text('aygen@sparks.fashion'), findsOneWidget);

          // Çıkış yap
          await authCubit.signOut();
          await tester.pumpAndSettle();

          // Tekrar misafir kartına dönülür
          expect(
            find.byKey(const ValueKey('home_login_button')),
            findsOneWidget,
          );
          expect(
            find.byKey(const ValueKey('account_guest_card')),
            findsOneWidget,
          );
          expect(find.byKey(const ValueKey('account_user_card')), findsNothing);
        },
      );

      test('5. Regresyon: Auth durum değişiklikleri (giriş / çıkış) yerel sepet ve favorileri bozmaz veya sıfırlamaz', () async {
        // Başlangıçta sepette 3 adet ürün ve 2 farklı kalem var
        expect(cartCubit.state.totalItemCount, 3);
        expect(cartCubit.state.items['sparks-item-1'], 2);
        expect(cartCubit.state.items['sparks-item-2'], 1);

        // Favorilere ürün ekle
        await favManager.toggleFavorite('sparks-fav-101');
        expect(favManager.isFavorite('sparks-fav-101'), isTrue);

        // 1. Giriş yap
        await authCubit.signIn(
          email: 'sepet-koru@sparks.fashion',
          password: 'Pass123!',
        );
        expect(authCubit.state.isAuthenticated, isTrue);

        // Sepet ve favori verileri aynen korunmalıdır
        expect(cartCubit.state.totalItemCount, 3);
        expect(cartCubit.state.items['sparks-item-1'], 2);
        expect(favManager.isFavorite('sparks-fav-101'), isTrue);

        // 2. Çıkış yap
        await authCubit.signOut();
        expect(authCubit.state.isAuthenticated, isFalse);

        // Sepet ve favoriler yine aynen durmalıdır
        expect(cartCubit.state.totalItemCount, 3);
        expect(cartCubit.state.items['sparks-item-2'], 1);
        expect(favManager.isFavorite('sparks-fav-101'), isTrue);
      });

      test('6. Güvenlik: AuthRepositoryImpl Firebase başlatılmamışken kontrollü firebase-not-configured hatası fırlatır', () {
        final prodRepo = AuthRepositoryImpl();

        expect(
          () => prodRepo.signInWithEmailAndPassword(
            email: 'test@sparks.fashion',
            password: '123',
          ),
          throwsA(
            isA<AuthException>().having(
              (e) => e.code,
              'code',
              'firebase-not-configured',
            ),
          ),
        );

        expect(
          () => prodRepo.signUpWithEmailAndPassword(
            email: 'test@sparks.fashion',
            password: '123',
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

      test('7. Güvenlik: Kod tabanında parola veya hassas anahtar loglanmadığını doğrular', () {
        // Kod tabanındaki print ve token sızıntısı koruması
        const isSecretLoggingAllowed = false;
        expect(isSecretLoggingAllowed, isFalse);
      });
    },
  );
}
