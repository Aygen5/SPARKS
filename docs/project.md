# SPARKS — Proje Tanımı ve Ürün Vizyonu

## 1. Ürün Vizyonu ve Amacı

SPARKS, Zara'nın mobil uygulamasındaki yüksek moda ve editoryal dergi estetiğinden ilham alan, premium bir mobil moda ve e-ticaret uygulamasıdır.

Uygulamanın amacı yalnızca siyah bir arka plan üzerine beyaz yazılar koymak değildir; kullanıcıya yüksek moda kataloğu, editoryal dergi kapağı ve modern bir lüks moda markasının alışveriş deneyimini hissettirmektir.

SPARKS kendi markası, kendi ürün seçkisi ve özgün editoryal arayüzü olan bağımsız bir projedir. Zara görsel referans olarak alınmakla birlikte, Zara'nın tescilli marka varlıkları doğrudan kullanılmaz.

---

## 2. Temel Tasarım ve Deneyim İlkeleri

1. **Tam Ekran Moda Fotoğrafları:** Giriş ve ana sayfada ekranı bütünüyle kaplayan, güçlü editoryal kompozisyonlar.
2. **Yüksek Kontrastlı Serif Başlıklar:** Marka adı, büyük bölüm başlıkları ve tarihler için zarif, uzun ve yüksek kontrastlı serif tipografi (Bodoni Moda / Playfair / Cormorant Garamond tarzı).
3. **Sade Sans-Serif Yardımcı Metinler:** Kategoriler, ürün bilgileri, butonlar ve fiyatlar için nötr, okunaklı, ince sans-serif tipografi.
4. **İki Renk Dünyasının Uyumu:**
   - *Editoryal Alanlar:* Sıcak krem, yumuşak bej, taş, kahve ve antrasit tonları.
   - *Alışveriş Arayüzü:* Simsiyah arka plan (`#000000`), beyaz ana metinler, açık gri ikincil metinler, dekupe beyaz ürün fotoğraf alanları ve ince ayırıcılar.
5. **Keskin Köşeler ve İnce Çizgiler:** Yuvarlak, kabarık buton ve kartlar yerine monokrom editoryal kimliğe uygun keskin/düz köşeler (`borderRadius: 0`) ve 1px zarif çizgiler.
6. **Bilinçli Boşluk ve Minimalizm:** Kalabalık hazır şablon görüntüsünden uzak, nefes alan editoryal yerleşimler.
7. **Kontrollü ve Yavaş Animasyonlar:** Göz yormayan, moda podyumu hissi veren akıcı ve zarif mikro-geçişler.

---

## 3. Uygulama Ekranları ve Kullanıcı Akışları

Uygulama bir giriş (splash) ekranı ve beş sekmeli sabit alt navigasyona sahip ana iskeletten (`MainScaffold`) oluşur.

### 3.1. Açılış Ekranı (Splash Screen)
- Alt navigasyonun dışındadır.
- Sıcak bej/kehribar tonlarında dikey tam ekran editoryal moda fotoğrafı arka plandadır.
- 1.0'dan 1.06'ya yavaş büyüyen (6 saniyelik) yumuşak zoom efekti.
- Ekranın alt bölgesinde devasa, zarif, soldan sağa kayarak beliren beyaz `SPARKS` serif marka logosu.
- Orta-alt bölümde ince beyaz çerçeveli, yarı saydam buzlu cam efektli “Koleksiyonu Keşfet” butonu.
- Butona basıldığında yumuşak bir fade geçişiyle ana uygulamaya (`MainScaffold`) yönlendirilir.

### 3.2. Ana Sayfa (Lookbook)
- 4 dikey tam ekran editoryal moda fotoğrafından oluşan dikey kaydırılabilir yapı (`PageView`).
- Sabit `SPARKS` logosu: Fotoğraflarla birlikte kaymaz; ekranın alt bölümünde, sabit alt navigasyonun hemen üzerinde konumlanır.
- Herhangi bir fotoğrafa dokunulduğunda doğrudan `MENÜ` sekmesine geçiş yapılır.

### 3.3. Menü ve Kategoriler
- Simsiyah arka plan, beyaz metinler.
- Üstte büyük serif başlıklarla `KADIN` ve `ERKEK` sekmeleri (seçili olanın altında beyaz nokta).
- İki sütunlu editoryal yerleşim:
  - *Sol sütun:* Numaralı ana gruplar (`| 01 | YENİ ÜRÜNLER`, `| 02 | KOLEKSİYON`, vb.).
  - *Sağ sütun:* İlgili alt kategoriler (`THE NEW`, `KABAN | MONT`, `CEKET`, `PANTOLON`, `JEAN`, `TOP | BODY`, `KAZAK | HIRKA`, `ETEK`, `AYAKKABI`, `ÇANTA`).
  - *Erkek menüsü:* Kadın menüsüyle aynı yapıda olup `ETEK` ve `ÇANTA` yer almaz.
- Kategoriye tıklandığında seçilen cinsiyet ve kategori bilgisiyle ürün listeleme ekranına geçilir (`KADIN → CEKET → ProductListPage`).

### 3.4. Ürün Listeleme Ekranı (Catalog Page)
- Başlık alanı: Geri butonu, 3 modlu dinamik görünüm seçici (1 → 2 → 3 → 1) ve `FİLTRELER` (XS, S, M, L, XL beden filtresi).
  - *Görünüm 1:* Tek sütunlu büyük editoryal ürün fotoğrafları, ürün adı, fiyat ve hızlı ekleme butonu.
  - *Görünüm 2:* İki sütunlu ızgara, dikey fotoğraflar, büyük harfli ürün adı, fiyat, hızlı ekleme (`+`) ikonu, renk kareleri.
  - *Görünüm 3:* Üç sütunlu yoğun katalog görünümü, beyaz zeminli ürün fotoğrafları, isim yok, yalnızca ortalanmış fiyat ve ekleme ikonu.
- Ürüne tıklandığında `ProductDetailPage` açılır; hızlı ekleme ikonuna basıldığında stok kontrolüyle sepete eklenir.

### 3.5. Ürün Detay Sayfası (Product Detail)
- Simsiyah arka plan, beyaz tipografi.
- Üstte geri butonu, sağ üstte favori (kalp) ikonu.
- Büyük 1. ürün fotoğrafı.
- Ürün adı, güncel fiyat, varsa eski fiyat ve indirim bilgisi.
- `SEPETE EKLE` butonu (stokta yoksa `TÜKENDİ`).
- `AÇIKLAMA` ve `MALZEMELER` sekmeleri (dokununca içerik açılır).
- Renk ve referans kodu (kopyalama özellikli).
- Büyük 2. ürün fotoğrafı.

### 3.6. Arama Ekranı (Search)
- Simsiyah minimalist zemin, `KADIN` / `ERKEK` sekmeleri.
- Çerçevesiz, yalnızca alt çizgili minimalist arama inputu (`NE ARIYORSUNUZ?`).
- `İLGİNİZİ ÇEKEBİLECEK DİĞER ÜRÜNLER` başlığı ve katalogdan iki sütunlu öneri kartları.
- Arama metnine göre anlık gerçek katalog filtrelemesi.

### 3.7. Hesap ve Alışverişlerim (Account & Orders)
- Üstte `SPARKS QR`, `YARDIM`, `AYARLAR`.
- `FAVORİLER` başlığı ve 3 ürün görselinden oluşan yatay şerit.
- Sade 3 maddelik editoryal liste:
  - `01 — ALIŞVERİŞLER` (Sipariş geçmişine yönlendirir)
  - `02 — FAVORİLER` (Favoriler ekranına yönlendirir)
  - `03 — BİLGİLERİM` (Açıklama: "Sana en uygun bedeni önerebilmemiz için ölçülerini tamamla")
- Alışverişlerim Ekranı: `ONLINE` ve `MAĞAZA` sekmeleri, tasarım doğrulaması için 2 adet referans sipariş kaydı (teslim edildi bilgisi, tarih, tutar, ürün görselleri).

### 3.8. Sepet Ekranı (Cart Page)
- Simsiyah arka plan.
- Sol üstte kapatma ikonu (X), sağda yardım/mesaj ikonu.
- Başlık: `ALIŞVERİŞ SEPETİ | {adet} |` ve `FAVORİLER` sekmesi.
- Her ürün satırında: Seçim kutusu (checkbox), beyaz zeminli ürün görseli, ürün adı, beden/renk, fiyat, miktar kontrolleri (`- 1 +`), `SİL` ve `Favorilere Ekle`.
- Altta sabit ödeme çubuğu: `TOPLAM`, dinamik tutar (TL, vergiler dahil), tam genişlikte beyaz `DEVAM ET ({adet})` butonu.

---

## 4. Ortak Durum Yönetimi (State Management)

- **Cubit (Bloc):** Sepet (`CartCubit`) ve Favoriler (`FavoritesCubit`) tüm ekranlar arasında reaktif ve senkronize olarak paylaşılır.
- Aynı ürün sepete ikinci kez eklendiğinde yeni satır açılmaz; mevcut ürünün adedi artar.
- Alt navigasyondaki sepet ikonu (`[ n ]`) sepetteki toplam ürün miktarını anlık olarak yansıtır.
- Stokta tükenmiş ürünler sepete eklenemez.

---

## 5. Proje Kapsamı ve Kapsam Dışında Kalanlar

### Kapsam Dahilinde Olanlar:
- 10–15 seçilmiş lüks moda ürününden oluşan merkezi JSON ürün kataloğu.
- Tam ekran editoryal görseller, mikro animasyonlar ve sayfa geçişleri.
- 5 sekmeli sabit alt navigasyon (`StatefulShellRoute`).
- 3 farklı ürün listeleme görünümü ve beden filtrelemesi.
- Sepet ve favorilerin tam durum yönetimi (ekleme, silme, miktar, toplam tutar).
- Sipariş geçmişi ve hesap ekranı sunumu.
- Bütünleşik açık/koyu tema altyapısı ve editoryal tasarım sistemi.

### Kapsam Dışında Kalanlar:
- Gerçek banka / ödeme ağ geçidi entegrasyonu (DEVAM ET butonu temsili işlem yapar).
- Canlı sunucu taraflı kullanıcı hesabı ve oturum açma (login/register).
- Canlı mağaza envanteri senkronizasyonu.
- Zara'nın veya üçüncü parti sistemlerin izinsiz taranması (scraping).
