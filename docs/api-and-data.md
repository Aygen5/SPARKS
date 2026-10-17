# SPARKS — API, Veri Yönetimi ve Katalog Stratejisi

## 1. Ürün Veri Modeli ve Gerekli Alanlar

SPARKS projesinde rastgele yüzlerce ürün içeren genel API'ler (DummyJSON vb.) kullanılmayacaktır.
Uygulama, editoryal moda estetiğine uygun olarak seçilmiş 10–15 adet ürünle çalışacaktır.

Her ürün nesnesi aşağıdaki alanları eksiksiz veya opsiyonel olarak destekler:

| Alan Adı | Tip | Zorunlu mu? | Açıklama / Örnek |
|---|---|---|---|
| `id` | `String` | Evet | Benzersiz ürün kimliği (`sparks-w-001`) |
| `title` | `String` | Evet | Ürün adı (`DİK YAKA ÖRGÜ HIRKA`) |
| `price` | `double` | Evet | Güncel satış fiyatı (TL cinsinden, örn. `2890.0`) |
| `oldPrice` | `double?` | Hayır | Varsa indirim öncesi eski fiyat (`3490.0`) |
| `discountText` | `String?` | Hayır | Varsa indirim oranı veya etiketi (`-%17`) |
| `gender` | `String` | Evet | `KADIN` veya `ERKEK` |
| `category` | `String` | Evet | Kategori adı (`CEKET`, `KABAN \| MONT`, `PANTOLON`, `TRIKO`, vb.) |
| `images` | `List<String>` | Evet | Tam olarak 2 adet yüksek çözünürlüklü dikey görsel adresi |
| `description` | `String` | Evet | Ürünün kalıp, yaka, kumaş ve kesim açıklaması |
| `colorAndCode` | `String` | Evet | Renk ve ürün referans kodu (`SİYAH \| 2753/032`) |
| `materials` | `String` | Evet | Kumaş ve astar içeriği (`%100 Yün, Astar: %100 Viskon`) |
| `isOutOfStock` | `bool` | Evet | Stok tükenme durumu (`true`/`false`) |
| `sizes` | `List<String>` | Evet | Mevcut bedenler (`["XS", "S", "M", "L", "XL"]`) |

---

## 2. Para Birimi ve Fiyat Gösterimi

- Tüm fiyatlar **Türk lirası (TL)** üzerinden tanımlanır ve gösterilir.
- Para formatı Türkiye standartlarına uygun olmalıdır:
  - Binlik ayracı nokta (`.`), kuruş ayracı virgül (`,`) ve sonda ` TL`.
  - Örnek: `2.890,00 TL`, `3.290,00 TL`.
- Gerçek olmayan döviz dönüşümleri veya kaynağı belirsiz fiyatlar kesinlikle kullanılmayacaktır.

---

## 3. Zara Ürünlerini Otomatik Alma Konusunda Araştırma ve Bulgular

Kullanıcının 10–15 ürünü elle tek tek girmek istememesi ve otomatik/yarı otomatik bir yöntem araştırması talebi üzerine yapılan teknik ve yasal araştırma sonuçları şunlardır:

### 3.1. Resmî API Durumu
- Zara ve Inditex Grubu'nun kamuya açık, belgelenmiş veya üçüncü parti geliştiricilerin kullanımına izin verdiği herhangi bir **resmî REST / GraphQL ürün API'si bulunmamaktadır**.

### 3.2. robots.txt ve Site Kullanım Koşulları
- Zara Türkiye web sitesinin `robots.txt` dosyası incelenmiş; tüm katalog, arama, sepet ve dahili veri uç noktalarının (`/itxrest/`, `/shop/`, `/c4/` vb.) otomatik robotlara ve botlara karşı **Disallow (yasaklı)** olduğu doğrulanmıştır.
- Zara "Kullanım ve Satış Koşulları" uyarınca site üzerindeki verilerin, fiyatların, açıklamaların ve fotoğrafların izinsiz otomatik toplanması (scraping / crawling), tersine mühendisliği veya ticari amaçla kullanılması yasal olarak yasaklanmıştır.

### 3.3. Teknik Güvenlik ve Bot Koruması
- Zara web altyapısı Cloudflare / Akamai Bot Manager ile korunmaktadır. Python, cURL veya headless tarayıcılarla gönderilen otomatik istekler IP bazlı captcha / 403 Forbidden ile engellenmektedir.
- Bu nedenle uygulamanın doğrudan Zara sunucularına otomatik istek atarak canlı veri çekmesi hem teknik olarak kırılgandır hem de kullanım koşullarına aykırıdır.

---

## 4. Uygulanabilir Çözüm Seçenekleri

### Tercih Edilen Çözüm A (Özenle Doğrulanmış Merkezi JSON Kataloğu):
- 10–15 seçkin ürün, projenin `assets/data/products.json` dosyasında yapılandırılmış olarak yer alır.
- Bu JSON dosyasında her ürünün adı, 2 fotoğrafı, TL fiyatı, malzeme bilgisi, renk kodu ve bedenleri eksiksiz ve doğrulanmış biçimde tutulur.
- **Avantajı:** Sıfır ağ bağımlılığı, anında yüklenme hızı, hata riskinin olmaması, görsel teliflerinin kontrollü seçilebilmesi ve Flutter kodlarının içine ürün gömülmemesi.
- Kullanıcı dilediği zaman bu JSON dosyasını açıp tek bir yerden ürünleri düzenleyebilir veya yeni ürün ekleyebilir.

### Alternatif Çözüm B (Kullanıcı Tarafından İçe Aktarma — Bookmarklet / Script):
- Kullanıcı tarayıcısında beğendiği bir Zara ürün sayfasını açtığında, tarayıcı konsolunda çalışan veya sayfanın açık JSON-LD (`schema.org/Product`) meta etiketini kopyalayan küçük bir JavaScript aracı (`bookmarklet`) kullanır.
- Bu araç, açık olan sayfadaki başlık, fiyat, görsel URL'leri ve ürün kodunu tek tıkla panoya JSON formatında kopyalar.
- Kullanıcı bu JSON çıktısını `assets/data/products.json` dosyasına yapıştırır.
- **Avantajı:** Hiçbir izinsiz bot/scraping yapılmaz; kullanıcı tarayıcısında gördüğü veriyi zahmetsizce JSON formatında panoya alır.

---

## 5. Servis ve Repository Mimarisi

- `ProductApiService`: Ağ üzerinden JSON verisi çekecekse HTTP GET isteği yapar; yerel dosyadan okuyacaksa `rootBundle.loadString` servisini çağırır. Sahte ağ simülasyonu (yapay gecikmeler veya sahte hata kodları) eklenmez.
- `ProductRepository`: Verinin nereden geldiğini (`products.json` veya ileride gerçek bir backend) UI katmanından tamamen gizler. `Future<List<Product>>` döndürür.
- UI katmanı (Ekranlar ve Cubit'ler) verinin yerel JSON'dan mı yoksa REST API'den mi geldiğiyle ilgilenmez; yalnızca `ProductRepository` ile haberleşir.