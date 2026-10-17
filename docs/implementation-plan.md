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

## Aşama 5 — Menü ve Kategori Akışı (KULLANICI ONAYI BEKLENİYOR)
- **Amaç:** İki sütunlu editoryal `KADIN` ve `ERKEK` menü ekranını ve kategori yönlendirmesini oluşturmak.
- **Ön Koşullar:** Aşama 4 onayı.
- **Yapılacak İşler:**
  - Üstte serif tipografiyle `KADIN` ve `ERKEK` sekmeleri.
  - Sol sütun: Numaralı ana gruplar (`| 01 | YENİ ÜRÜNLER`, `| 02 | KOLEKSİYON`, vb.).
  - Sağ sütun: İlgili kategoriler (Erkek menüsünde etek ve çanta filtrelenir).
  - Kategoriye tıklanınca `ProductListPage`'e seçilen cinsiyet ve kategori parametreleriyle geçiş.
- **Oluşturulacak / Değiştirilecek Dosyalar:** `lib/features/menu/*`.
- **Test Yöntemi:** Menü kategorileri ve navigasyon testleri.
- **Tamamlanma Ölçütü:** Seçilen kategoriye göre doğru parametrelerle katalog ekranı açılır.

---

## Aşama 6 — Ürün Listeleme Ekranı ve Arama
- **Amaç:** 3 farklı görünüm moduna sahip ürün listesini, beden filtresini ve KADIN/ERKEK sekmeli arama ekranını geliştirmek.
- **Ön Koşullar:** Aşama 5 onayı.
- **Yapılacak İşler:**
  - 3 modlu görünüm seçici döngüsü (Tek sütun büyük editoryal → 2 sütunlu ızgara → 3 sütunlu yoğun katalog).
  - Beden filtresi (XS, S, M, L, XL).
  - Arama ekranı: `NE ARIYORSUNUZ?` alt çizgili input ve anlık katalog araması.
  - Ürün kartına tıklandığında `ProductDetailPage`'e geçiş.
- **Oluşturulacak / Değiştirilecek Dosyalar:** `lib/features/catalog/presentation/*`, `lib/features/search/presentation/*`.
- **Test Yöntemi:** Görünüm değiştirme, filtreleme ve arama widget testleri.
- **Tamamlanma Ölçütü:** 3 görünüm sorunsuz değişir, beden filtresi doğru çalışır, arama katalogla eşleşir.

---

## Aşama 7 — Ürün Detay Sayfası
- **Amaç:** İki büyük görsel, açıklama/malzeme sekmeleri, renk kodu ve stok durumu içeren detay ekranını geliştirmek.
- **Ön Koşullar:** Aşama 6 onayı.
- **Yapılacak İşler:**
  - Sol üstte geri butonu, sağ üstte favori (kalp) ikonu.
  - İki büyük editoryal fotoğraf yerleşimi.
  - Fiyat, eski fiyat ve indirim gösterimi.
  - `AÇIKLAMA` ve `MALZEMELER` sekme içeriği.
  - Renk ve referans kodu kopyalama.
  - Stokta olan ürünlerde `SEPETE EKLE`, tükenenlerde `TÜKENDİ` butonu.
- **Oluşturulacak / Değiştirilecek Dosyalar:** `lib/features/product_detail/presentation/*`.
- **Test Yöntemi:** Detay ekranı ve stok durumu testleri.
- **Tamamlanma Ölçütü:** Ürün bilgileri eksiksiz gösterilir, kopyalama ve sekmeler çalışır.

---

## Aşama 8 — Ortak Durum Yönetimi (Sepet & Favoriler Cubit)
- **Amaç:** Sepet ve favori durumlarını reaktif Cubit sınıflarıyla tüm ekranlar arasında senkronize etmek.
- **Ön Koşullar:** Aşama 7 onayı.
- **Yapılacak İşler:**
  - `CartCubit` ve `FavoritesCubit` sınıflarının geliştirilmesi.
  - Sepete ekleme mantığı: Aynı ürün eklendiğinde miktarın artırılması (`quantity++`).
  - Alt bardaki sepet sayacının (`[ n ]`) anlık güncellenmesi.
  - Favori kalp ikonunun katalog ve detay sayfalarında senkronize çalışması.
- **Oluşturulacak / Değiştirilecek Dosyalar:** `lib/features/cart/presentation/cubit/*`, `lib/features/favorites/presentation/cubit/*`.
- **Test Yöntemi:** Cubit durum birim testleri (bloc_test).
- **Tamamlanma Ölçütü:** Sepet miktarı ve favori durumu tüm ekranlarda anında güncellenir.

---

## Aşama 9 — Favoriler, Hesap ve Alışverişlerim Ekranları
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