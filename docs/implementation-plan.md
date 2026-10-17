# SPARKS — Yeni Aşamalı Uygulama ve Geliştirme Planı

## Genel Kurallar
1. Her aşama bağımsız, çalışır ve test edilmiş bir teslimat birimidir.
2. Bir aşama tamamlanıp kullanıcıdan onay alınmadan sonraki aşamanın kodlamasına **kesinlikle geçilmez**.
3. Her aşama sonunda:
   - Kod değişiklikleri detaylıca açıklanır.
   - `dart analyze` ve `flutter test` çalıştırılır.
   - İlgili işlevler elle kontrol edilir.
   - Gerçek durum şeffaf bir raporla sunulur.

---

## Aşama 0 — Gereksinimler, Veri Kaynağı ve Mimari Planlama (MEVCUT GÖREV)
- **Amaç:** Projenin yeni Zara editoryal vizyonunu analiz etmek, mimariyi ve veri kaynağını netleştirmek, eski taslak kodları temizlemek ve belgeleri güncellemek.
- **Ön Koşullar:** Yok.
- **Yapılacak İşler:**
  - Görsel URL'lerinin ve referans ekran görüntülerinin incelenmesi.
  - Zara veri kaynağı ve scraping olanaklarının yasal/teknik araştırılması.
  - Eski ekran taslaklarının (`splash_screen.dart`, `home_screen.dart`) temizlenmesi.
  - Tüm `.md` belgelerinin yeni gereksinimlere göre güncellenmesi.
  - Yeni klasör mimarisinin hazırlanması.
- **Oluşturulacak / Değiştirilecek Dosyalar:** `docs/*.md`, `lib/app/theme/*`, `lib/core/*`, `lib/app/router/*`, `test/*`.
- **Test Yöntemi:** `dart analyze`, `flutter test`.
- **Tamamlanma Ölçütü:** Eski geçici kodlar temizlenmiş, belgeler güncellenmiş ve proje hatasız analiz verir durumdadır. Yeni ekran kodlaması yapılmaz.

---

## Aşama 1 — Temel Uygulama ve Tasarım Sistemi (TAMAMLANDI)
- **Amaç:** Çift görünüm paletli (editoryal sıcak tonlar + simsiyah alışveriş arayüzü) Material 3 temasını, Serif (Playfair Display) / Sans-serif (Inter) tipografi sistemini, keskin köşe kurallarını (0 radius) ve GoRouter temelini hazırlamak.
- **Ön Koşullar:** Aşama 0 onayı (Sağlandı).
- **Tamamlanan İşler:**
  - `app_colors.dart`: Editoryal sıcak palet ve simsiyah alışveriş paleti anlamsal adlarla tanımlandı.
  - `app_text_styles.dart`: `Playfair Display` serif ve `Inter` sans-serif tipografi hiyerarşisi oluşturuldu; offline sistem fallback mekanizmaları tanımlandı.
  - `app_spacing.dart`: `lib/app/theme/app_spacing.dart` altında sıfır radius, 1px çizgi ve standart boşluklar tanımlandı.
  - `app_images.dart`: Doğrulanmış 5 editoryal görsel URL'si merkezi sabitlerde toplandı.
  - `app_theme.dart`: Pure black editoryal koyu tema, keskin köşeli butonlar (`ElevatedButton`, `OutlinedButton`, `TextButton`), sıfır gölgeli AppBar ve InputDecoration teması kuruldu.
  - Bağımlılık: `google_fonts: ^9.0.0` eklendi.
- **Oluşturulan / Değiştirilen Dosyalar:** `lib/app/theme/*`, `lib/core/constants/*`, `test/widget_test.dart`, `pubspec.yaml`, `docs/*.md`.
- **Test Yöntemi & Sonucu:** `dart analyze` (0 sorun), `flutter test` (6 testin 6'sı başarılı), `flutter build web` (başarılı).
- **Tamamlanma Ölçütü:** Tasarım sistemi tüm renkleri, tipografiyi, butonları ve boşlukları merkezi olarak yönetir durumdadır. Aşama 2'ye geçiş için kullanıcı onayı beklenmektedir.

---

## Aşama 2 — Tam Ekran Editoryal Açılış Ekranı (Splash Screen) (TAMAMLANDI)
- **Amaç:** Zara ilhamlı tam ekran fotoğraflı, yavaş zoom animasyonlu ve dev serif logolu açılış ekranını oluşturmak.
- **Ön Koşullar:** Aşama 1 onayı (Sağlandı).
- **Tamamlanan İşler:**
  - `lib/features/splash/presentation/splash_screen.dart`: Tam ekran editoryal moda fotoğrafı, alttan koyulaşan degrade katmanı, 1.0'dan 1.06'ya 6 saniyelik yavaş zoom animasyonu, soldan sağa kayan dev Playfair Display `SPARKS` logosu ve buzlu cam (glassmorphic) efektli keskin köşeli "Koleksiyonu Keşfet" butonu geliştirildi.
  - `lib/app/router/app_router.dart`: `AppRoutes.splash` (`/`) başlangıç rotası yapıldı, `AppRoutes.home` (`/home`) rotasına CustomTransitionPage ile yumuşak fade geçiş efekti entegre edildi.
  - `test/widget_test.dart`: Açılış ekranının açılması, logo/buton görünürlüğü, yumuşak geçiş yönlendirmesi ve dar ekran (360x640) taşma denetimi için 8 test yazıldı ve doğrulandı.
  - Git & GitHub: `aygenyildirim27@gmail.com` kimliği yapılandırıldı, `feature/stage-2-editorial-splash` branch'i açıldı.
- **Oluşturulan / Değiştirilen Dosyalar:** `lib/features/splash/presentation/splash_screen.dart`, `lib/app/router/app_router.dart`, `test/widget_test.dart`, `docs/implementation-plan.md`.
- **Test Yöntemi & Sonucu:** `dart analyze` (0 sorun), `flutter test` (8 testin 8'i başarılı).
- **Tamamlanma Ölçütü:** Açılış ekranı tam ekran sorunsuz açılır, animasyonlar akıcı çalışır ve butona basınca yumuşak fade ile ana uygulamaya geçer. Aşama 3'e geçiş için kullanıcı onayı beklenmektedir.

---

## Aşama 3 — Ana İskelet (`MainScaffold`) ve Editoryal Ana Sayfa (TAMAMLANDI)
- **Amaç:** 5 sekmeli sabit alt navigasyonu ve 4 dikey fotoğraflı editoryal lookbook ana sayfasını oluşturmak.
- **Ön Koşullar:** Aşama 2 onayı (Sağlandı).
- **Tamamlanan İşler:**
  - `lib/features/home/presentation/home_screen.dart`: 4 adet editoryal moda fotoğrafı içeren dikey `PageView`, alt kontrast gradyanı ve sayfa kaydırılsa dahi sağ alt köşede sabit kalan `Playfair Display` serif `SPARKS` logosu geliştirildi. Fotoğrafa dokunulduğunda Menü sekmesine yönlendirme sağlandı.
  - `lib/features/navigation/presentation/sparks_bottom_nav_bar.dart`: Tam siyah arka planlı, keskin köşeli (0 radius), üstte 1px ayırıcı çizgili, aktif sekme altında beyaz nokta indikatörü bulunan 5 sekmeli (`Anasayfa`, `MENÜ`, `Arama`, `HESAP`, `Sepet [ 0 ]`) alt navigasyon çubuğu geliştirildi.
  - `lib/features/navigation/presentation/main_scaffold.dart`: `StatefulNavigationShell` ile çalışan kalıcı ana uygulama kabuğu oluşturuldu.
  - `lib/features/{menu,search,account,cart}/presentation/*`: 4 sekme için minimalist geçici hedef ekranları oluşturuldu.
  - `lib/app/router/app_router.dart`: `StatefulShellRoute.indexedStack` mimarisi kurularak 5 dal bağlandı; açılış ekranı alt barlardan izole bağımsız rota olarak korundu.
  - `test/widget_test.dart`: 14 kapsamlı testle Lookbook dikey akışı, sabit logo, 5 sekmeli bar, aktif nokta hareketi, fotoğraftan menüye yönlendirme ve 360x640 dar ekran taşma denetimi doğrulandı.
- **Oluşturulan / Değiştirilen Dosyalar:** `lib/features/home/presentation/home_screen.dart`, `lib/features/navigation/presentation/sparks_bottom_nav_bar.dart`, `lib/features/navigation/presentation/main_scaffold.dart`, `lib/features/{menu,search,account,cart}/presentation/*`, `lib/app/router/app_router.dart`, `lib/core/constants/app_constants.dart`, `test/widget_test.dart`, `docs/implementation-plan.md`.
- **Test Yöntemi & Sonucu:** `dart analyze` (0 sorun), `flutter test` (14 testin 14'ü başarılı), `flutter build web` (başarılı).
- **Tamamlanma Ölçütü:** 5 sekme arasında durum kaybı olmadan geçiş yapılır; alt navigasyon kalıcı kalır, ana sayfa fotoğrafları dikey kayar ve logo sabittir. Aşama 4'e geçiş için kullanıcı onayı beklenmektedir.

---

## Aşama 4 — Ürün Modeli ve Katalog Veri Kaynağı (TAMAMLANDI)
- **Amaç:** 10–15 seçkin üründen oluşan merkezi `products.json` kataloğunu, `Product` entity'sini, `ProductModel` ve `ProductRepository` katmanını hazırlamak.
- **Ön Koşullar:** Aşama 3 onayı (Sağlandı).
- **Tamamlanan İşler:**
  - `lib/features/catalog/domain/entities/product.dart`: Saf domain entity, 12 zorunlu/opsiyonel alan, tam olarak 2 görsel şartı, indirim ve eşitlik kontrolleri yazıldı.
  - `lib/features/catalog/data/models/product_model.dart`: Açıklayıcı `FormatException` fırlatan sıkı JSON doğrulayıcı (`fromJson`), `toJson` ve `fromEntity` metotları geliştirildi.
  - `assets/data/products.json`: 12 seçkin editoryal ürün (8 KADIN, 4 ERKEK), tam olarak 2 görsel URL'si, TL fiyatları, renk kodları, açıklamaları ve malzemeleriyle merkezi varlık olarak oluşturuldu.
  - `lib/core/utils/currency_formatter.dart`: Türkiye standartlarına (`tr_TR`) uygun sayısal TL para birimi biçimlendirici yazıldı (`2.890,00 TL`).
  - `lib/features/catalog/data/datasources/product_local_data_source.dart`: `AssetBundle` üzerinden JSON okuyan test edilebilir veri kaynağı yazıldı.
  - `lib/features/catalog/domain/repositories/product_repository.dart` & `ProductRepositoryImpl`: `getProducts(gender, category)`, `getProductById(id)` ve `searchProducts(query)` işlevlerini sunan repository sözleşmesi ve uygulaması tamamlandı.
  - `test/features/catalog/`: Model, doğrulama, para biçimlendirici, repository filtreleri ve `products.json` dosya şeması için 14 yeni birim test yazıldı; toplam test sayısı 28'e ulaştı.
- **Oluşturulan / Değiştirilen Dosyalar:** `lib/features/catalog/domain/*`, `lib/features/catalog/data/*`, `assets/data/products.json`, `pubspec.yaml`, `lib/core/utils/currency_formatter.dart`, `test/features/catalog/*`, `docs/*`.
- **Test Yöntemi & Sonucu:** `dart analyze` (0 sorun), `flutter test` (28 testin 28'i başarılı), `flutter build web` (başarılı).
- **Tamamlanma Ölçütü:** Katalog verisi merkezi kaynaktan asenkron olarak okunur, repository filtreleri eksiksiz çalışır ve tüm testler yeşildir. Aşama 5'e geçiş için kullanıcı onayı beklenmektedir.

---

## Aşama 5 — Menü ve Kategori Akışı (TAMAMLANDI)
- **Amaç:** İki sütunlu editoryal `KADIN` ve `ERKEK` menü ekranını ve kategori yönlendirmesini oluşturmak.
- **Ön Koşullar:** Aşama 4 onayı.
- **Gerçekleştirilen İşler:**
  - `MenuCategoryItem` ve `MenuSection` domain entity sınıfları geliştirildi (`lib/features/menu/domain/entities/menu_item.dart`).
  - Merkezi `MenuData` veri yapısı hazırlandı; KADIN (10 alt kategori) ve ERKEK (7 alt kategori; `ETEK`, `TOP | BODY` ve `ÇANTA` filtrelenmiş) reyonları tanımlandı (`lib/features/menu/data/menu_data.dart`).
  - `MenuScreen`: Üstte `Playfair Display` serif `KADIN` ve `ERKEK` sekme seçicisi ve aktif alt çizgi göstergesi; sol sütunda %40 genişlikte numaralandırılmış ana gruplar (`|01| YENİ ÜRÜNLER`, `|02| KOLEKSİYON`, `|03| AYAKKABI | AKSESUAR`), sağ sütunda %60 genişlikte alt kategoriler içeren iki sütunlu editoryal ızgara geliştirildi (`lib/features/menu/presentation/menu_screen.dart`).
  - Kategoriye dokunulduğunda GoRouter üzerinden `/catalog?gender=<GENDER>&category=<CATEGORY>` parametreleriyle geçiş bağlandı.
  - Editoryal `CatalogPlaceholderScreen` oluşturuldu; sol üstte geri dönüş butonu ile menüdeki aktif sekme ve scroll konumu korunarak geri dönülebilirlik sağlandı (`lib/features/catalog/presentation/catalog_placeholder_screen.dart`).
  - `AppRouter` yapılandırmasına `/catalog` rotası eklendi (`lib/app/router/app_router.dart`).
  - `test/features/menu/menu_screen_test.dart`: Sekme değişimi, sol ve sağ sütun hiyerarşisi, cinsiyete göre kategori filtreleme, tıklama yönlendirmesi, GoRouter entegrasyonu ve 360x640 dar ekran taşmasızlık kontrollerini kapsayan 8 yeni test yazıldı. Toplam test sayısı 36'ya çıktı.
- **Oluşturulan / Değiştirilen Dosyalar:** `lib/features/menu/*`, `lib/features/catalog/presentation/catalog_placeholder_screen.dart`, `lib/app/router/app_router.dart`, `test/features/menu/*`, `docs/*`.
- **Test Yöntemi & Sonucu:** `dart analyze` (0 sorun), `flutter test` (36 testin 36'sı başarılı), `flutter build web` doğrulaması.
- **Tamamlanma Ölçütü:** İki sütunlu editoryal menü reyon bazında kusursuz çalışır; kategoriye dokunulduğunda doğru cinsiyet ve kategori parametreleriyle geçiş ekranı açılır ve menüye sorunsuz dönülür.

---

## Aşama 6 — Ürün Listeleme Ekranı ve Arama (TAMAMLANDI)
- **Amaç:** 3 farklı görünüm moduna sahip ürün listesini, beden filtresini ve KADIN/ERKEK sekmeli arama ekranını geliştirmek.
- **Ön Koşullar:** Aşama 5 onayı.
- **Gerçekleştirilen İşler:**
  - `CatalogScreen`: `ProductRepository` üzerinden asenkron ürün çekme, yüklenme (`CircularProgressIndicator`), hata (`TEKRAR DENE` butonu) ve boş sonuç durumları geliştirildi (`lib/features/catalog/presentation/catalog_screen.dart`).
  - 3 Farklı Editoryal Görünüm Modu:
    - Görünüm 1: Büyük tek sütun editoryal kartlar (büyük fotoğraf, başlık, fiyat, indirim etiketi).
    - Görünüm 2: Yan yana 2 sütunlu dengeli ızgara (`GridView`).
    - Görünüm 3: 3 sütunlu yoğun katalog (ürün isimleri gizlenir, sadece editoryal görseller ön plandadır).
    - `GÖRÜNÜM 1/2/3` butonu ile `1 -> 2 -> 3 -> 1` döngüsel geçiş mekanizması bağlandı.
  - Yatay Kategori Şeridi: `TÜMÜNÜ GÖR`, `SUNİ KÜRK`, `BOMBER`, `TEKNİK ŞİŞME` ve menüden gelen aktif kategori etiketleri entegre edildi.
  - Beden Filtresi: `XS`, `S`, `M`, `L`, `XL` beden seçenekleri, `products.json` içindeki gerçek `Product.sizes` verisi ile birebir eşleşecek şekilde filtreleme yaptı.
  - `SearchScreen`: KADIN ve ERKEK reyon sekmeleri, alt çizgili minimalist arama alanı (`NE ARIYORSUNUZ?`), başlık, kategori, açıklama ve renk/kodda anlık arama, arama boşken önerilen 2 ürün gösterimi ve boş sonuç mesajı geliştirildi (`lib/features/search/presentation/search_screen.dart`).
  - `ProductDetailPlaceholderScreen`: Ürün kartlarına dokunulduğunda `/product/:id` rotasına ürün kimliği taşınarak Aşama 7'ye hazırlık sağlandı (`lib/features/product_detail/presentation/product_detail_placeholder_screen.dart`).
  - Testler: Katalog ekranı için 11 yeni test (`test/features/catalog/catalog_screen_test.dart`), arama ekranı için 8 yeni test (`test/features/search/search_screen_test.dart`) yazıldı. Toplam test sayısı 55'e çıktı.
- **Oluşturulan / Değiştirilen Dosyalar:** `lib/features/catalog/presentation/*`, `lib/features/search/presentation/*`, `lib/features/product_detail/presentation/*`, `lib/app/router/app_router.dart`, `test/features/catalog/*`, `test/features/search/*`, `docs/*`.
- **Test Yöntemi & Sonucu:** `dart analyze` (0 sorun), `flutter test` (55 testin 55'i başarılı), `flutter build web` doğrulaması.
- **Tamamlanma Ölçütü:** 3 görünüm modu sorunsuz döner; kategori ve beden filtreleri gerçek verilerle çalışır; arama ekranı anlık olarak sonuçları ve önerileri listeler; tüm testler yeşildir.

---

## Aşama 7 — Ürün Detay Sayfası ve Favorilere Ekleme
- **Amaç:** İki büyük editoryal görsel, açıklama/malzeme sekmeleri, renk kodu panoya kopyalama, stok durumu ve merkezi favori sistemini geliştirmek.
- **Ön Koşullar:** Aşama 6 onayı.
- **Gerçekleştirilen İşler:**
  - `ProductDetailScreen`: GoRouter `/product/:id` rotasına tam donanımlı ürün detay sayfası bağlandı (`lib/features/product_detail/presentation/product_detail_screen.dart`).
  - Asenkron Veri Yükleme: `ProductRepository.getProductById(id)` üzerinden veri çekme, editoryal yükleme spinner'ı (`CircularProgressIndicator`), hata ve ürün bulunamadı durumları (`ÜRÜN BULUNAMADI` + `TEKRAR DENE` butonu).
  - Üst Bar: Sol üstte `Icons.arrow_back` geri dönüş butonu, merkezde marka logosu ve sağ üstte reaktif kalp butonu (`Icons.favorite` / `Icons.favorite_border`).
  - İki Görselli Galeri: 3:4 oranlı editoryal `PageView.builder` ve sağ altta keskin siyah zeminli `"1/2"` / `"2/2"` sayfa indikatörü.
  - Fiyat ve İndirim: İndirimli ürünlerde güncel fiyat (kalın beyaz), üstü çizili eski fiyat ve beyaz indirim etiketi (`-%15`); indirimsiz ürünlerde yalnızca güncel fiyat gösterimi.
  - Renk ve Referans Kodu: `product.colorAndCode` yanındaki kopyalama butonu ile `Clipboard.setData` panoya yazma ve kullanıcıya editoryal SnackBar bildirimi (`"Renk ve ürün kodu kopyalandı"`).
  - Editoryal Sekmeler: `AÇIKLAMA` (varsayılan) ve `MALZEMELER` sekmeleri arasında dokunmatik geçiş ve dinamik içerik gösterimi.
  - Stok Aksiyonu: `isOutOfStock == true` olduğunda pasif `TÜKENDİ` butonu; stokta olduğunda keskin beyaz `SEPETE EKLE` butonu (Aşama 8 SnackBar bilgilendirmesi ile).
  - Merkezi Favori Mimarisi:
    - `FavoritesLocalDataSource`: `SharedPreferences` tabanlı kalıcı kimlik saklama ve testler için `InMemoryFavoritesLocalDataSource` (`lib/features/favorites/data/datasources/*`).
    - `FavoritesRepository` ve `FavoritesRepositoryImpl`: `Set<String>` ile duplikasyonu önleyen repository sözleşmesi ve önbellek (`lib/features/favorites/domain/*`, `lib/features/favorites/data/*`).
    - `FavoritesManager`: `ChangeNotifier` tabanlı merkezi durum yöneticisi (`lib/features/favorites/presentation/manager/favorites_manager.dart`).
  - Testler: Favoriler katmanı için 11 birim test (`test/features/favorites/favorites_test.dart`), ürün detay ekranı için 11 widget testi (`test/features/product_detail/product_detail_screen_test.dart`) yazıldı. Toplam test sayısı 77'ye ulaştı.
- **Oluşturulan / Değiştirilen Dosyalar:** `lib/features/product_detail/presentation/product_detail_screen.dart`, `lib/features/favorites/*`, `lib/app/router/app_router.dart`, `test/features/favorites/*`, `test/features/product_detail/*`, `test/features/catalog/catalog_screen_test.dart`, `docs/*`.
- **Test Yöntemi & Sonucu:** `dart analyze` (0 sorun), `flutter test` (77 testin 77'si başarılı), `flutter build web` doğrulaması.
- **Tamamlanma Ölçütü:** Ürün detayları ve görselleri kusursuz yüklenir, sekmeler ve kopyalama çalışır; favori durumu kalıcı olarak senkronize edilir; tüm testler yeşildir.

---

## Aşama 8 — Merkezi Sepet Yönetimi ve Favori Senkronizasyonu
- **Amaç:** Merkezi `CartCubit` ile sepet iş mantığını, kalıcı depolamayı (`SharedPreferences`), dinamik alt navigasyon rozetini (`[ n ]`), gerçek editoryal sepet ekranını ve katalog/arama/detay favori kalp senkronizasyonunu geliştirmek.
- **Ön Koşullar:** Aşama 7 onayı.
- **Gerçekleştirilen İşler:**
  - `CartCubit` & `CartState`: `flutter_bloc` tabanlı durum yönetimi (`lib/features/cart/presentation/cubit/*`).
  - Sepet İş Kuralları: İlk eklemede adet=1, tekrar eklemede `quantity++`, farklı ürünlerde bağımsız satırlar, adet azaltmada minimum 1 (1 iken azaltma ürünü silmez), çöp kutusu ile açık satır silme (`removeProduct`), tükenen ürün koruması (`isOutOfStock == true` reddedilir), tek tıkla sepet temizleme (`clearCart`).
  - Kalıcı Saklama: `CartLocalDataSource` & `CartRepository` ile `sparks_cart_items` JSON String depolaması; testler için `InMemoryCartLocalDataSource` (`lib/features/cart/data/*`, `lib/features/cart/domain/*`).
  - Dinamik Görünüm: `CartItemView` varlığı repository üzerinden güncel ürün bilgileri ve hesaplanan satır toplamı ile birleştirilir.
  - Dinamik Alt Navigasyon Rozeti: `MainScaffold` içindeki `BlocBuilder<CartCubit, CartState>` ile alt navigasyon 5. sekmesindeki rozet anlık güncellenir (`[ 0 ]`, `[ 1 ]`, `[ 2 ]` vb.).
  - Ürün Detay Entegrasyonu: `ProductDetailScreen` üzerindeki `SEPETE EKLE` butonu `CartCubit` ile bağlanarak sepete ekler ve kullanıcıya editoryal SnackBar bildirimi sunar.
  - Gerçek Sepet Ekranı (`CartScreen`): Editoryal kartlar, adet - / + kontrolleri, satır silme, sepeti temizleme butonu, dinamik genel toplam ve boş sepet durumu (`KATALOĞA DÖN` butonu ile).
  - Favori Senkronizasyonu: `CatalogScreen` (tüm 3 görünüm modunda) ve `SearchScreen` ürün kartlarına kalp ikonu eklendi; `FavoritesManager` dinleyicileriyle tüm ekranlarda favori durumu anında senkronize edildi.
  - Testler: `CartCubit` için 14 birim test (`test/features/cart/cart_cubit_test.dart`), `CartScreen` ve entegrasyonlar için 11 widget testi (`test/features/cart/cart_screen_test.dart`) yazıldı. Toplam test sayısı 102'ye ulaştı.
- **Oluşturulan / Değiştirilen Dosyalar:** `lib/features/cart/*`, `lib/features/navigation/presentation/main_scaffold.dart`, `lib/features/product_detail/presentation/product_detail_screen.dart`, `lib/features/catalog/presentation/catalog_screen.dart`, `lib/features/search/presentation/search_screen.dart`, `lib/app/app.dart`, `test/features/cart/*`, `docs/*`.
- **Test Yöntemi & Sonucu:** `dart analyze` (0 sorun), `flutter test` (102 testin 102'si başarılı), `flutter build web` doğrulaması.
- **Tamamlanma Ölçütü:** Sepet ekleme, adet kontrolleri, silme ve genel toplam sorunsuz çalışır; alt bardaki sayaç anında güncellenir; favoriler tüm ekranlarda senkronizedir; tüm testler yeşildir.

---

## Aşama 9 — Favoriler, Hesap ve Alışverişlerim Ekranları (KULLANICI ONAYI BEKLENİYOR)
- **Amaç:** Favoriler listesini, profil/hesap menüsünü ve sipariş geçmişi ekranını geliştirmek.
- **Ön Koşullar:** Aşama 8 onayı.
- **Yapılacak İşler:**
  - Favoriler ekranı: İki sütunlu ürün kartları, favoriden çıkarma, sepete aktarma.
  - Hesap ekranı: SPARKS QR, YARDIM, AYARLAR, 3 ürünlü favori şeridi ve 3 maddelik editoryal liste.
  - Alışverişlerim ekranı: ONLINE ve MAĞAZA sekmeleri, 2 adet referans sipariş kaydı (tarih, tutar, ürün görselleri).
- **Oluşturulacak / Değiştirilecek Dosyalar:** `lib/features/favorites/presentation/*`, `lib/features/account/presentation/*`, `lib/features/orders/presentation/*`.
- **Test Yöntemi:** Navigasyon ve sipariş geçmişi widget testleri.
- **Tamamlanma Ölçütü:** Favoriler listelenir; hesap ve sipariş geçmişi ekranları editoryal estetikle çalışır.

---

## Aşama 10 — Sepet Ekranı ve Tamamlayıcı Etkileşimler
- **Amaç:** Dinamik sepet ekranını, miktar kontrollerini, silme işlemlerini ve sipariş tamamlama akışını hazırlamak.
- **Ön Koşullar:** Aşama 9 onayı.
- **Yapılacak İşler:**
  - Beyaz zeminli ürün fotoğrafları, ürün adı, beden, fiyat ve `- 1 +` miktar butonları.
  - `SİL` ve `Favorilere Ekle` aksiyonları.
  - Altta sabit ödeme çubuğu: Dinamik toplam tutar (TL) ve keskin beyaz `DEVAM ET ({adet})` butonu.
  - Kullanıcı bilgilendirme dialog ve SnackBar geri bildirimleri.
- **Oluşturulacak / Değiştirilecek Dosyalar:** `lib/features/cart/presentation/cart_screen.dart`.
- **Test Yöntemi:** Sepet etkileşimleri ve toplam tutar hesaplama testleri.
- **Tamamlanma Ölçütü:** Ürün miktarları değiştikçe toplam tutar anında güncellenir; boş sepet durumu düzgün gösterilir.

---

## Aşama 11 — Test, Küçük Ekran Uyumu, Erişilebilirlik ve Son Kontrol
- **Amaç:** Tüm uygulamanın analizini, farklı ekran boyutlarında taşma (overflow) kontrollerini ve son kalite testlerini tamamlamak.
- **Ön Koşullar:** Aşama 10 onayı.
- **Yapılacak İşler:**
  - `dart analyze` ile sıfır uyarı denetimi.
  - Dar ekran (360x640), standart (390x844) ve geniş ekranlarda taşma testleri.
  - `flutter build web` derleme doğrulaması.
  - Dokümantasyon ve README güncellemeleri.
- **Oluşturulacak / Değiştirilecek Dosyalar:** Proje genelindeki test ve doküman dosyaları.
- **Test Yöntemi:** `flutter test`, `dart analyze`, `flutter build web`.
- **Tamamlanma Ölçütü:** Tüm testler geçer, hiçbir taşma veya derleme hatası kalmaz.