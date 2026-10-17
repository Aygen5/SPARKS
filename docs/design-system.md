# SPARKS — Tasarım Sistemi ve Görsel Kimlik Rehberi

## 1. Tasarım Yönü ve Felsefesi

SPARKS, Zara'nın mobil arayüzündeki minimalist editoryal yüksek moda dilini benimser. Tasarım sıradan bir e-ticaret şablonundan farklı olarak:
- Tam ekran moda fotoğraflarına ve geniş boşluklara öncelik verir.
- Karakterli, uzun ve zarif serif başlıklar ile nötr sans-serif yardımcı metinleri dengeli kullanır.
- Kartlarda ve butonlarda yuvarlak köşeler yerine keskin/düz hatlar (`borderRadius: 0`) ve ince ayırıcı çizgiler (1px) tercih eder.
- Gölgeler ve renkli vurgular yerine monokrom kontrast ile derinlik sağlar.

---

## 2. Renk Sistemi: İki Farklı Görünüm Ailesi

Tasarım tek tip bir renge indirgenmez; iki farklı görsel dünyayı uyum içinde birleştirir:

### 2.1. Editoryal Görsel Alanları (Giriş & Ana Sayfa)
Sıcak, organik ve moda dergisi fotoğraf tonları:
- **Sıcak Krem:** `#FDFBF7`
- **Yumuşak Bej:** `#E8E1D5`
- **Taş Rengi:** `#D9D2C7`
- **Toprak / Kahverengi:** `#5A3E2B`
- **Antrasit:** `#222222`
- Fotoğrafın kendi doğal zengin tonları

### 2.2. Alışveriş Arayüzü (Menü, Arama, Katalog, Detay, Sepet, Hesap)
Yüksek kontrastlı, net ve şık monokrom zemin:
- **Ana Arka Plan:** `#000000` (Simsiyah)
- **Ana Metinler:** `#FFFFFF` (Saf beyaz)
- **İkincil / Yardımcı Metinler:** `#8E8E8E` (Nötr açık gri)
- **Dekupe Ürün Fotoğraf Zeminleri:** `#FFFFFF` veya `#F5F5F5` (Beyaz / çok açık krem)
- **İnce Ayırıcılar ve Çizgiler:** `#1F1F1F` / `#2A2A2A` (Koyu gri zarif kenarlık)
- **Vurgu Noktası (Aktif Sekme İndikatörü):** `#FFFFFF` (3px küçük beyaz daire)

---

## 3. Tipografi Hiyerarşisi

Aşama 1 kapsamında seçilen fontlar ve teknik uygulama:

| Tipografi Ailesi | Seçilen Font | Kullanım Alanı | Karakter Özellikleri & Fallback |
|---|---|---|---|
| **Zarif Serif (Editoryal)** | **Playfair Display** (`google_fonts`) | Marka Logosu, Büyük Ekran Başlıkları (`KADIN`, `ERKEK`, `FAVORİLER`), Tarihler | Yüksek kontrastlı, zarif editoryal serif. Çevrimdışı/yüklenememe durumunda sistem `Georgia`, `Times New Roman` veya `serif` fontuna düşer. |
| **Nötr Sans-Serif (Modern)** | **Inter** (`google_fonts`) | Kategoriler, Ürün İsimleri, Fiyatlar, Butonlar, Açıklamalar | Nötr, dengeli x-yüksekliği, mükemmel mobil okunabilirlik. Fallback: `Helvetica Neue`, `Arial`, `sans-serif`. |

### Tanımlı Tipografi Boyutları ve Sabitleri (`AppTextStyles`):
- **Brand Logo Large:** `fontSize: 42`, `fontWeight: FontWeight.w400`, `letterSpacing: 6.0`, Playfair Display
- **Brand Logo Medium:** `fontSize: 26`, `fontWeight: FontWeight.w400`, `letterSpacing: 4.0`, Playfair Display
- **Section Heading:** `fontSize: 24`, `fontWeight: FontWeight.w400`, `letterSpacing: 2.0`, Playfair Display
- **Editorial Accent:** `fontSize: 16`, `fontWeight: FontWeight.w500`, `letterSpacing: 1.5`, Playfair Display
- **Menu Group Title (`| 01 | YENİ ÜRÜNLER`):** `fontSize: 11`, `letterSpacing: 1.5`, Inter, Gri
- **Menu Item (`THE NEW`, `CEKET`):** `fontSize: 13`, `letterSpacing: 1.2`, Inter, Beyaz
- **Product Title:** `fontSize: 13`, `letterSpacing: 0.8`, Inter
- **Product Price:** `fontSize: 14`, `fontWeight: FontWeight.w600`, Inter (`3.290,00 TL`)
- **Product Old Price:** `fontSize: 12`, `decoration: lineThrough`, Inter
- **Button Text:** `fontSize: 12`, `fontWeight: FontWeight.w700`, `letterSpacing: 2.0`, Inter, Büyük harf
- **Search Placeholder:** `fontSize: 13`, `letterSpacing: 1.5`, Inter

---

## 4. Fotoğraf Referansları ve Görsel Kullanımı

Uygulamanın editoryal çekirdeğini oluşturan 5 temel görsel URL'si doğrulanmış ve boyutlandırılmıştır:

### 4.1. Açılış Ekranı (Splash) Görseli
- **URL:** `https://i.pinimg.com/1200x/74/5d/78/745d78a35a90710fcb3b3b0580ce9c9f.jpg`
- **Özellik:** 1200x2141 px (tam ekran dikey mobil wallpaper oranı), sıcak bej/kehribar tonları, hareket hissi.
- **Uygulama:** `Stack` + `Positioned.fill` + `BoxFit.cover`. Üzerinde alttan yukarıya doğru koyulaşan siyah degrade (`LinearGradient`). 1.0'dan 1.06'ya 6 saniyelik yavaş büyüme animasyonu.

### 4.2. Ana Sayfa (Lookbook) Görselleri
Dikey kaydırılabilir (`PageView`) 4 adet tam ekran editoryal moda fotoğrafı:
1. **Model 1 (Siyah vatkalı bluz & beyaz bol pantolon):**
   `https://i.pinimg.com/1200x/52/96/87/5296879fc3457d3f3534ddd52e9da382.jpg` (956x1489 px)
2. **Model 2 (Pencere önünde siyah kombin):**
   `https://i.pinimg.com/736x/fb/a0/18/fba01891e9a67b1f7c736062a4c89f98.jpg` (720x900 px)
3. **Model 3 (Loş ortam krem takım elbise):**
   `https://i.pinimg.com/1200x/a4/e0/d9/a4e0d91654a00f70c382b94a3660cd59.jpg` (800x1001 px)
4. **Model 4 (Işık ve gölge duvar önü bej ceket):**
   `https://i.pinimg.com/736x/2f/a1/66/2fa166116fda44667f26c689ef1458a3.jpg` (736x1313 px)

### 4.3. Görsel Kuralları:
- URL'ler tek bir merkezi sınıfta (`AppImages`) tanımlanır.
- Görsel yüklenirken siyah nötr zemin gösterilir; hata durumunda zarif bir yeniden deneme alanı sunulur.
- İlerleyen aşamalarda yerel varlıklara (`assets/images/`) taşınabilirlik korunur.

---

## 5. Buton ve Bileşen İlkeleri

- **Ana Aksiyon Butonu (`ElevatedButton`):**
  - Tam genişlik (`double.infinity`), yükseklik 50-54px.
  - Zemin: `#FFFFFF` (Beyaz), Metin: `#000000` (Siyah, kalın, sans-serif).
  - Köşeler: Keskin (`borderRadius: BorderRadius.zero`).
  - Gölge: Sıfır (`elevation: 0`).
- **Açılış Ekranı Butonu ("Koleksiyonu Keşfet"):**
  - İnce beyaz çerçeve (1px), yarı saydam / buzlu cam efekti (`BackdropFilter`), beyaz metin.
- **Alt Navigasyon Barı:**
  - Simsiyah arka plan (`#000000`), sabit yükseklik (60-70px).
  - 5 sekme: `ANASAYFA` (ev), `MENÜ` (metin), `ARAMA` (büyüteç/daire), `HESAP` (metin), `SEPET` (`[ n ]` çanta).
  - Aktif sekmenin hemen altında 3px beyaz nokta.

---

## 6. Ürün Listeleme 3-Görünüm Modu

Kullanıcı tek tıkla katalog görünümünü değiştirebilir:
1. **Görünüm 1 (Büyük Editoryal):** Tek sütun, dev dikey fotoğraf, altında ürün adı, fiyat ve hızlı sepete ekleme butonu.
2. **Görünüm 2 (İki Sütunlu Izgara):** Dikey ürün fotoğrafları, büyük harfli başlık, fiyat, hızlı ekleme `+` ikonu ve renk kareleri.
3. **Görünüm 3 (Yoğun 3 Sütunlu Katalog):** Beyaz zeminli ürün fotoğrafları, metin yok, yalnızca ortalanmış fiyat ve ekleme butonu.