import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sparks/features/favorites/data/datasources/favorites_local_data_source.dart';
import 'package:sparks/features/favorites/data/repositories/favorites_repository_impl.dart';
import 'package:sparks/features/favorites/presentation/manager/favorites_manager.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Aşama 7 — Favoriler Katmanı Birim Testleri', () {
    group('1. FavoritesLocalDataSource Testleri', () {
      test('InMemoryFavoritesLocalDataSource başlangıç değerlerini ve kaydetmeyi yönetir', () async {
        final dataSource = InMemoryFavoritesLocalDataSource({'sparks-w-001'});

        final initial = await dataSource.getFavoriteIds();
        expect(initial, contains('sparks-w-001'));
        expect(initial.length, 1);

        await dataSource.saveFavoriteIds({'sparks-w-001', 'sparks-w-002'});
        final updated = await dataSource.getFavoriteIds();
        expect(updated.length, 2);
        expect(updated, containsAll(['sparks-w-001', 'sparks-w-002']));

        await dataSource.clear();
        final cleared = await dataSource.getFavoriteIds();
        expect(cleared, isEmpty);
      });

      test('FavoritesLocalDataSourceImpl SharedPreferences üzerinde veri okur ve yazar', () async {
        SharedPreferences.setMockInitialValues({
          'sparks_favorite_product_ids': ['sparks-m-001'],
        });

        const dataSource = FavoritesLocalDataSourceImpl();
        final loaded = await dataSource.getFavoriteIds();
        expect(loaded, contains('sparks-m-001'));

        await dataSource.saveFavoriteIds({'sparks-m-001', 'sparks-m-002'});
        final afterSave = await dataSource.getFavoriteIds();
        expect(afterSave, containsAll(['sparks-m-001', 'sparks-m-002']));

        await dataSource.clear();
        final afterClear = await dataSource.getFavoriteIds();
        expect(afterClear, isEmpty);
      });
    });

    group('2. FavoritesRepositoryImpl Testleri', () {
      late InMemoryFavoritesLocalDataSource dataSource;
      late FavoritesRepositoryImpl repository;

      setUp(() {
        dataSource = InMemoryFavoritesLocalDataSource({'sparks-w-001'});
        repository = FavoritesRepositoryImpl(localDataSource: dataSource);
      });

      test('getFavoriteIds ve isFavorite durumları doğru raporlar', () async {
        final ids = await repository.getFavoriteIds();
        expect(ids, contains('sparks-w-001'));

        final isFav = await repository.isFavorite('sparks-w-001');
        expect(isFav, isTrue);

        final notFav = await repository.isFavorite('sparks-w-999');
        expect(notFav, isFalse);
      });

      test(
        'addFavorite yeni ürün ekler ve duplikasyonu engeller (Set özelliği)',
        () async {
          await repository.addFavorite('sparks-w-002');
          var ids = await repository.getFavoriteIds();
          expect(ids.length, 2);
          expect(ids, contains('sparks-w-002'));

          // Aynı ürünü tekrar eklemeyi dene
          await repository.addFavorite('sparks-w-002');
          ids = await repository.getFavoriteIds();
          expect(
            ids.length,
            2,
            reason: 'Aynı ürün tekrar eklenemez, duplikasyon engellenmelidir',
          );
        },
      );

      test('removeFavorite ürünü favorilerden başarıyla siler', () async {
        await repository.removeFavorite('sparks-w-001');
        final ids = await repository.getFavoriteIds();
        expect(ids, isNot(contains('sparks-w-001')));
        expect(ids, isEmpty);
      });

      test(
        'toggleFavorite favori durumunu tersine çevirir ve güncel durumu döner',
        () async {
          // Mevcut olanı toggle yapınca false dönmeli ve silinmeli
          final state1 = await repository.toggleFavorite('sparks-w-001');
          expect(state1, isFalse);
          expect(await repository.isFavorite('sparks-w-001'), isFalse);

          // Olmayanı toggle yapınca true dönmeli ve eklenmeli
          final state2 = await repository.toggleFavorite('sparks-w-001');
          expect(state2, isTrue);
          expect(await repository.isFavorite('sparks-w-001'), isTrue);
        },
      );

      test('clear tüm favorileri sıfırlar', () async {
        await repository.addFavorite('sparks-w-002');
        await repository.clear();
        final ids = await repository.getFavoriteIds();
        expect(ids, isEmpty);
      });
    });

    group('3. FavoritesManager Durum Yönetimi Testleri', () {
      late InMemoryFavoritesLocalDataSource dataSource;
      late FavoritesRepositoryImpl repository;
      late FavoritesManager manager;

      setUp(() {
        dataSource = InMemoryFavoritesLocalDataSource({'sparks-w-001'});
        repository = FavoritesRepositoryImpl(localDataSource: dataSource);
        manager = FavoritesManager(repository: repository);
      });

      test(
        'init() yerel depolamadaki favorileri yükler ve dinleyicileri uyarır',
        () async {
          int notifyCount = 0;
          manager.addListener(() => notifyCount++);

          expect(manager.isInitialized, isFalse);
          await manager.init();

          expect(manager.isInitialized, isTrue);
          expect(manager.count, 1);
          expect(manager.isFavorite('sparks-w-001'), isTrue);
          expect(notifyCount, 1);
        },
      );

      test(
        'toggleFavorite anlık olarak güncellenir ve dinleyicileri uyarır',
        () async {
          await manager.init();

          int notifyCount = 0;
          manager.addListener(() => notifyCount++);

          final isFavNow = await manager.toggleFavorite('sparks-w-002');
          expect(isFavNow, isTrue);
          expect(manager.isFavorite('sparks-w-002'), isTrue);
          expect(manager.count, 2);
          expect(notifyCount, 1);

          final removed = await manager.toggleFavorite('sparks-w-002');
          expect(removed, isFalse);
          expect(manager.isFavorite('sparks-w-002'), isFalse);
          expect(manager.count, 1);
          expect(notifyCount, 2);
        },
      );

      test('addFavorite ve removeFavorite dinleyicileri uyarır', () async {
        int notifyCount = 0;
        manager.addListener(() => notifyCount++);

        await manager.addFavorite('sparks-w-003');
        expect(manager.isFavorite('sparks-w-003'), isTrue);
        expect(notifyCount, 1);

        await manager.removeFavorite('sparks-w-003');
        expect(manager.isFavorite('sparks-w-003'), isFalse);
        expect(notifyCount, 2);
      });

      test('setInitialFavoritesForTesting test senaryolarını hızlandırır', () {
        manager.setInitialFavoritesForTesting({'test-1', 'test-2'});
        expect(manager.count, 2);
        expect(manager.isFavorite('test-1'), isTrue);
        expect(manager.isFavorite('test-2'), isTrue);
      });
    });
  });
}
