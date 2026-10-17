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

## Aşama 2 — Tam Ekran Editoryal Açılış Ekranı (Splash Screen)
- **Amaç:** Zara ilhamlı tam ekran fotoğraflı, yavaş zoom animasyonlu ve dev serif logolu açılış ekranını oluşturmak.
- **Ön Koşullar:** Aşama 1 onayı.
- **Yapılacak İşler:**
  - Arka planda 1200x2141 px sıcak tonlu editoryal moda fotoğrafı ve alttan koyulaşan gradient yerleşimi.
  - 1.0'dan 1.06'ya 6 saniyelik yavaş büyüme animasyonu.
  - Soldan sağa kayarak beliren büyük `SPARKS` serif logosu.
  - İnce çerçeveli yarı saydam / buzlu cam efektli "Koleksiyonu Keşfet" butonu.
  - Butona tıklandığında `MainScaffold`'a yumuşak fade geçişi.
- **Oluşturulacak / Değiştirilecek Dosyalar:** `lib/features/splash/presentation/splash_screen.dart`, `lib/app/router/app_router.dart`.
- **Test Yöntemi:** Animasyon ve navigasyon widget testleri.
- **Tamamlanma Ölçütü:** Açılış ekranı tam ekran sorunsuz açılır, animasyonlar akıcı çalışır ve butona basınca ana iskelete geçer.

---

## Aşama 3 — Ana İskelet (`MainScaffold`) ve Editoryal Ana Sayfa
- **Amaç:** 5 sekmeli sabit alt navigasyonu ve 4 dikey fotoğraflı editoryal lookbook ana sayfasını oluşturmak.
- **Ön Koşullar:** Aşama 2 onayı.
- **Yapılacak İşler:**
  - `StatefulShellRoute` ile 5 sekmeli (`ANASAYFA`, `MENÜ`, `ARAMA`, `HESAP`, `SEPET`) alt navigasyon iskeletinin (`MainScaffold`) kurulması.
  - Aktif sekme altında küçük beyaz nokta indikatörü.
  - Ana sayfada dikey kaydırılabilir 4 tam ekran editoryal moda fotoğrafı (`PageView`).
  - Sabit `SPARKS` logosunun fotoğraflarla kaymadan alt barın üstünde sabit kalması.
  - Fotoğraflara dokunulduğunda `MENÜ` sekmesine yönlendirme.
- **Oluşturulacak / Değiştirilecek Dosyalar:** `lib/app/navigation/main_scaffold.dart`, `lib/features/home/presentation/home_screen.dart`.
- **Test Yöntemi:** Sekme geçişi ve dikey kaydırma widget testleri.
- **Tamamlanma Ölçütü:** 5 sekme arasında durum kaybı olmadan geçiş yapılır; ana sayfa fotoğrafları akıcı kayar.

---

## Aşama 4 — Ürün Modeli ve Katalog Veri Kaynağı
- **Amaç:** 10–15 seçkin üründen oluşan merkezi `products.json` kataloğunu, `Product` entity'sini ve `ProductRepository` katmanını hazırlamak.
- **Ön Koşullar:** Aşama 3 onayı ve veri kaynağı kararının kesinleşmesi.
- **Yapılacak İşler:**
  - `Product` entity ve `ProductModel` (JSON çözümleme) sınıflarının yazılması.
  - `data/catalog/products.json` dosyasının oluşturulması (2 fotoğraf, TL fiyatı, malzeme, renk kodu, stok durumu, bedenler).
  - `ProductRepository` arayüzü ve `LocalJsonProductRepository` uygulamasının yazılması.
  - TL para birimi biçimlendirici (`CurrencyFormatter`) yardımcı fonksiyonunun yazılması.
- **Oluşturulacak / Değiştirilecek Dosyalar:** `lib/features/catalog/domain/*`, `lib/features/catalog/data/*`, `lib/data/catalog/products.json`, `lib/core/utils/currency_formatter.dart`.
- **Test Yöntemi:** JSON çözümleme ve repository birim testleri.
- **Tamamlanma Ölçütü:** Tüm 10-15 ürün eksiksiz çözümlenir, fiyatlar TL olarak doğru formatlanır.

---

## Aşama 5 — Menü ve Kategori Akışı
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