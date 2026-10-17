# SPARKS — Mimari ve Yazılım Tasarımı Rehberi

## 1. Mimari Yaklaşım

SPARKS, özellik bazlı (feature-first) klasörleme ile katmanlı mimariyi (data, domain, presentation) birleştirir.
Temel amaç; kodu gereksiz soyutlamalarla boğmadan, her dosyanın tek bir sorumluluğa sahip olduğu, test edilebilir ve anlaşılır bir yapı kurmaktır.

---

## 2. Hedef Klasör Yapısı

```text
lib/
├── main.dart                          # Başlatıcı ve ortam hazırlığı
├── app/
│   ├── app.dart                       # SparksApp kök widget'ı
│   ├── router/
│   │   ├── app_router.dart            # GoRouter ve StatefulShellRoute yapılandırması
│   │   └── app_routes.dart            # Rota sabitleri ve parametre eşleştirmeleri
│   ├── theme/
│   │   ├── app_theme.dart             # Material 3 tema yapılandırması
│   │   ├── app_colors.dart            # Editoryal ve Alışveriş renk paletleri
│   │   ├── app_text_styles.dart       # Serif ve Sans-serif tipografi stilleri
│   │   └── app_spacing.dart           # Ekran kenar boşlukları ve ölçü sabitleri
│   └── navigation/
│       └── main_scaffold.dart         # 5 sekmeli sabit alt navigasyon iskeleti
├── core/
│   ├── constants/
│   │   ├── app_constants.dart         # Marka ve metinsel sabitler
│   │   └── app_images.dart            # Doğrulanmış editoryal görsel URL'leri
│   ├── errors/
│   │   └── failures.dart              # Hata modellemeleri
│   ├── utils/
│   │   └── currency_formatter.dart    # Türk lirası (TL) biçimlendirici
│   └── widgets/
│       ├── sparks_app_bar.dart        # Ortak minimalist üst bar
│       ├── sparks_network_image.dart  # Hata/yüklenme kontrollü editoryal görsel widget'ı
│       └── sparks_button.dart         # Keskin köşeli editoryal buton bileşeni
├── data/
│   └── catalog/
│       └── products.json              # 10-15 seçilmiş ürünlük merkezi katalog
└── features/
    ├── splash/
    │   └── presentation/              # Tam ekran fotoğraflı animasyonlu açılış ekranı
    ├── home/
    │   └── presentation/              # Dikey PageView editoryal lookbook
    ├── menu/
    │   ├── data/
    │   │   └── menu_data.dart             # KADIN ve ERKEK için merkezi bölüm ve kategori tanımları
    │   ├── domain/
    │   │   └── entities/
    │   │       └── menu_item.dart         # MenuCategoryItem ve MenuSection varlıkları
    │   └── presentation/
    │       └── menu_screen.dart           # İki sütunlu editoryal KADIN/ERKEK menü ekranı
    ├── catalog/
    │   ├── data/
    │   │   ├── datasources/               # ProductLocalDataSource (AssetBundle)
    │   │   ├── models/                    # ProductModel (JSON ayrıştırma, format kontrolü)
    │   │   └── repositories/              # ProductRepositoryImpl (iş kuralları, filtreleme)
    │   ├── domain/
    │   │   ├── entities/                  # Product entity
    │   │   └── repositories/              # ProductRepository arayüzü
    │   └── presentation/
    │       ├── catalog_placeholder_screen.dart # Geriye dönük test uyumluluk wrapper'ı
    │       └── catalog_screen.dart        # 3 görünüm modlu, kategori ve beden filtreli katalog
    ├── product_detail/
    │   └── presentation/
    │       └── product_detail_placeholder_screen.dart # Ürün detay geçiş ekranı (Aşama 6)
    ├── search/
    │   └── presentation/
    │       └── search_screen.dart         # KADIN/ERKEK sekmeli gerçek zamanlı arama ve öneriler
    ├── favorites/
    │   ├── presentation/
    │   │   ├── cubit/                 # FavoritesCubit & FavoritesState
    │   │   └── favorites_screen.dart  # Favori ürünler ekranı
    ├── cart/
    │   ├── presentation/
    │   │   ├── cubit/                 # CartCubit & CartState
    │   │   └── cart_screen.dart       # Dinamik sepet ve ödeme ekranı
    ├── account/
    │   └── presentation/              # SPARKS QR, favori şeridi ve hesap menüsü
    └── orders/
        └── presentation/              # Alışverişlerim ve sipariş geçmişi ekranı
```

---

## 3. Navigasyon Mimarisi (`GoRouter` ve `StatefulShellRoute`)

Uygulamanın navigasyon omurgasını `GoRouter` oluşturur:

1. **Açılış Ekranı (`/splash` veya `/`):**
   - Alt navigasyonun tamamen dışındadır.
   - Tam ekran görsel ve logo animasyonu içerir.
   - "Koleksiyonu Keşfet" butonu `context.go('/home')` çağırır; splash ekranı yığından silinir ve kullanıcı geri tuşuna bastığında uygulamadan çıkar.

2. **Ana Uygulama İskeleti (`MainScaffold`):**
   - `StatefulShellRoute.indexedStack` kullanılır.
   - 5 ana dal (branch) tanımlanır:
     - Dal 0: `/home` (ANASAYFA)
     - Dal 1: `/menu` (MENÜ)
     - Dal 2: `/search` (ARAMA)
     - Dal 3: `/account` (HESAP)
     - Dal 4: `/cart` (SEPET)
   - Sekme geçişlerinde sayfalar yeniden çizilmez; kaydırma pozisyonları korunur.
   - Sabit alt navigasyon (`BottomBar`) her zaman ekranda kalır.

3. **İkincil Sayfaların Navigasyonu:**
   - **Ürün Listeleme (`/catalog?gender=KADIN&category=CEKET`):** Menü dalı altında veya üst yığında açılır, sol üstte geri butonu yer alır.
   - **Ürün Detayı (`/product/:id`):** Herhangi bir ekrandan (arama, katalog, favoriler, sepet) açılabilir. Geri butonuna basıldığında çağrıldığı sayfaya geri döner.
   - **Alışverişlerim (`/account/orders`):** Hesap sekmesinden açılır.

---

## 4. Durum Yönetimi (State Management) — `Cubit`

Farklı ekranlar arasında paylaşılması gereken iki temel durum `flutter_bloc` / `Cubit` ile yönetilir:

### 4.1. `CartCubit` (Sepet Durumu)
- **State İçeriği:** `List<CartItem>`, `totalAmount`, `totalItemCount`.
- **Kurallar:**
  - `addToCart(Product product, String size)`: Aynı ürün ve beden varsa adedi artırılır (`quantity++`), yeni satır eklenmez.
  - `updateQuantity(String productId, int newQuantity)`: Miktar 0 olursa listeden silinir.
  - `removeFromCart(String productId)`: Ürünü sepetten çıkarır.
  - `isOutOfStock` olan ürünler sepete eklenemez.
  - Alt bardaki çanta ikonu dinamik olarak `state.totalItemCount` değerini `[ n ]` şeklinde gösterir.

### 4.2. `FavoritesCubit` (Favoriler Durumu)
- **State İçeriği:** `List<Product>`.
- **Kurallar:**
  - `toggleFavorite(Product product)`: Varsa çıkarır, yoksa ekler.
  - `isFavorite(String productId)`: Kalp ikonunun durumunu anlık olarak belirler.

---

## 5. Veri Katmanı ve Repository Sözleşmesi

- **`Product` Entity:** İş kurallarının kullandığı saf ürün nesnesi (`lib/features/catalog/domain/entities/product.dart`).
- **`ProductModel`:** JSON verisini okuyan, 12 alanı sıkı şekilde doğrulayan ve serileştiren model sınıfı (`lib/features/catalog/data/models/product_model.dart`).
- **`ProductLocalDataSource`:** `assets/data/products.json` varlık dosyasını `AssetBundle` üzerinden okuyan yerel veri kaynağı (`lib/features/catalog/data/datasources/product_local_data_source.dart`).
- **`ProductRepository` (Arayüz):**
  ```dart
  abstract class ProductRepository {
    Future<List<Product>> getProducts({String? gender, String? category});
    Future<Product?> getProductById(String id);
    Future<List<Product>> searchProducts(String query, {String? gender});
  }
  ```
- **`ProductRepositoryImpl`:** `ProductLocalDataSource` üzerinden verileri asenkron çeken, cinsiyet/kategori filtreleme ve metinsel arama iş kurallarını uygulayan repository sınıfı (`lib/features/catalog/data/repositories/product_repository_impl.dart`). İleride gerçek bir API'ye geçilmek istendiğinde UI katmanına dokunmadan `ProductRemoteDataSource` veya `HttpProductRepository` ile değiştirilebilir (Liskov Substitution Principle).

---

## 6. Editoryal Menü Mimarisi ve Kategori Akışı (Aşama 5)

SPARKS iki sütunlu editoryal menüsü, lüks moda dergilerinin editoryal hiyerarşisini yansıtır:

### 6.1. Domain & Veri Yapısı
- **`MenuCategoryItem`:** Tekil alt kategori kimliği (`id`) ve ekranda görünen editoryal başlığını (`title`) tutan domain nesnesi (`lib/features/menu/domain/entities/menu_item.dart`).
- **`MenuSection`:** Numaralandırma hanesi (`number`, örn: "01"), ana bölüm başlığı (`title`, örn: "KOLEKSİYON") ve alt kategori listesini barındıran domain nesnesi. `headerDisplay` getter'ı ile `|01| YENİ ÜRÜNLER` formatını üretir.
- **`MenuData`:** `KADIN` ve `ERKEK` reyonları için statik merkezi kategori verilerini sağlar (`lib/features/menu/data/menu_data.dart`). `ERKEK` reyonunda `ETEK`, `TOP | BODY` ve `ÇANTA` kategorileri bulunmaz.

### 6.2. Sunum Katmanı (`MenuScreen`)
- **Üst Bölüm (`_GenderTabsHeader`):** `Playfair Display` serif tipografi ile `KADIN` ve `ERKEK` sekmeleri, 2px beyaz aktif alt çizgi göstergesi (`AnimatedContainer`).
- **İki Sütunlu Izgara:**
  - **Sol Sütun (%40 genişlik):** `|01| YENİ ÜRÜNLER`, `|02| KOLEKSİYON`, `|03| AYAKKABI | AKSESUAR` şeklinde numaralı ana gruplar (Inter Light, ikincil gri).
  - **Sağ Sütun (%60 genişlik):** Seçili cinsiyete ait alt kategoriler (Inter Regular/Medium, beyaz).
- **Yönlendirme Mekanizması:**
  - Bir kategoriye dokunulduğunda `GoRouter` üzerinden `/catalog?gender=<GENDER>&category=<CATEGORY>` rotasına yönlendirilir (`context.push()`).
  - Aşama 5 kapsamında bu rota editoryal `CatalogPlaceholderScreen` bileşenini açarken Aşama 6'da 3 modlu görünüm ve filtreleri içeren `CatalogScreen` bileşeniyle genişletilmiştir.

---

## 7. Ürün Kataloğu, Üçlü Görünüm Sistemi ve Gerçek Zamanlı Arama (Aşama 6)

### 7.1. Katalog Veri Akışı ve Durum Yönetimi (`CatalogScreen`)
- **Veri Akışı:**
  `CatalogScreen -> ProductRepository -> ProductLocalDataSource -> assets/data/products.json`
- **Asenkron Durumlar:**
  - Yüklenme: Minimalist editoryal daire (`CircularProgressIndicator`).
  - Hata: Kullanıcı dostu mesaj ve `TEKRAR DENE` butonu (`_fetchProducts`).
  - Boş Sonuç: Seçili filtrelere uygun ürün bulunamadığında `FİLTRELERİ TEMİZLE` eylemi.
- **Üçlü Görünüm Sistemi (View Switcher):**
  - `GÖRÜNÜM 1`: Tek sütun büyük editoryal moda fotoğrafları, başlık, fiyat, indirim etiketi.
  - `GÖRÜNÜM 2`: Yan yana iki sütunlu dengeli ızgara (`GridView.builder`, aspect ratio ~0.58).
  - `GÖRÜNÜM 3`: Üç sütunlu yoğun katalog (`GridView.builder`, aspect ratio ~0.65). Ürün başlıkları gizlenir, sadece editoryal görseller ön plana çıkar.
  - Üst bardaki `GÖRÜNÜM 1/2/3` butonu `1 -> 2 -> 3 -> 1` döngüsel sırasıyla görünümü anlık değiştirir.
- **Kategori ve Beden Filtreleri:**
  - Yatay kategori şeridi: `TÜMÜNÜ GÖR`, `SUNİ KÜRK`, `BOMBER`, `TEKNİK ŞİŞME` ve aktif menü kategorisi.
  - Beden filtresi: `XS`, `S`, `M`, `L`, `XL`. `Product.sizes` alanındaki gerçek verilerle filtreleme yapar.

### 7.2. Gerçek Zamanlı Arama Ekranı (`SearchScreen`)
- **Reyon Sekmeleri:** `KADIN` ve `ERKEK` sekmeleri arama sonuçlarını ve önerileri ilgili cinsiyetle kısıtlar.
- **Arama Alanı:** Alt çizgili minimalist `TextField` (`NE ARIYORSUNUZ?`), anlık `_onSearchInputChanged` dinleyicisi.
- **Kapsam:** `ProductRepository.searchProducts` metodu üzerinden başlık, kategori, renk/kod ve açıklamada anlık arama.
- **Önerilen Ürünler:** Arama kutusu boşken `İLGİNİZİ ÇEKEBİLECEK DİĞER ÜRÜNLER` başlığı altında ilgili reyonun ilk 2 ürünü listelenir.
- **Geçiş Noktası:** Katalog veya arama ekranında bir ürüne dokunulduğunda `/product/:id` rotasına gidilir; ürün kimliği GoRouter üzerinden `ProductDetailScreen` bileşenine aktarılır.

---

## 8. Ürün Detay Sayfası ve Merkezi Favoriler Mimarisi (Aşama 7)

### 8.1. Ürün Detay Sayfası (`ProductDetailScreen`)
- **Veri Akışı:**
  `ProductDetailScreen -> ProductRepository.getProductById(id) -> ProductLocalDataSource -> assets/data/products.json`
- **Asenkron Yaşam Döngüsü ve Durumlar:**
  - `initState()`: `_loadProduct()` asenkron çağrısı başlatılır; `FavoritesManager` dinleyicisi (`addListener`) eklenir.
  - `dispose()`: `FavoritesManager` dinleyicisi güvenle temizlenir (`removeListener`).
  - Yüklenme: Editoryal minimalist spinner (`CircularProgressIndicator`).
  - Bulunamadı / Hata: Kullanıcı dostu `ÜRÜN BULUNAMADI` mesajı ve `TEKRAR DENE` aksiyon butonu.
- **Editoryal Görsel Galerisi:**
  - 3:4 aspect ratio editoryal görsel yerleşimi.
  - `PageView.builder` ile iki görsel arasında yatay kaydırma.
  - Sağ altta keskin siyah zeminli `"1/2"` ve `"2/2"` sayfa indikatörü.
- **Fiyat ve İndirim:**
  - İndirimli ürünlerde güncel fiyat (kalın beyaz), eski fiyat (üstü çizili gri) ve beyaz indirim rozeti (örn: `-%15`).
  - İndirimsiz ürünlerde yalnızca güncel satış fiyatı.
- **Renk ve Referans Kodu Kopyalama:**
  - `product.colorAndCode` alanı yanında kopyalama butonu.
  - `Clipboard.setData` ile panoya yazma ve kullanıcıya editoryal SnackBar (`"Renk ve ürün kodu kopyalandı"`) bildirimi.
- **Editoryal Sekmeler (`AÇIKLAMA` / `MALZEMELER`):**
  - Başlangıçta varsayılan olarak `AÇIKLAMA` sekmesi aktiftir (`product.description`).
  - `MALZEMELER` sekmesine basıldığında kumaş/astar bileşimi gösterilir (`product.materials`).
- **Stok Durumu ve Aksiyon Butonu:**
  - `isOutOfStock == true`: Buton pasifleşir, arka plan kararır ve `TÜKENDİ` yazar.
  - `isOutOfStock == false`: Keskin beyaz `SEPETE EKLE` butonu; Aşama 8'e hazırlık olarak bilgilendirici SnackBar sunar.

### 8.2. Merkezi Favori Mimarisi ve Kalıcılık
- **Prensip:** Yalnızca ürün kimlikleri (`Set<String>`) saklanır; ürün varlıkları veya fiyatlar favorilerde çoğaltılmaz.
- **Katmanlar:**
  1. `FavoritesLocalDataSource` (`lib/features/favorites/data/datasources/`): `SharedPreferences` üzerinden JSON/StringList tabanlı yerel okuma ve yazma. Testler için `InMemoryFavoritesLocalDataSource` çifti.
  2. `FavoritesRepository` (`lib/features/favorites/domain/repositories/`): Sözleşme arayüzü; `getFavoriteIds`, `isFavorite`, `addFavorite`, `removeFavorite`, `toggleFavorite`, `clear`.
  3. `FavoritesRepositoryImpl` (`lib/features/favorites/data/repositories/`): Somut repository; `Set<String>` ile duplikasyonu fiziksel olarak önler, önbellekleme yapar ve yerel veri kaynağına yazar.
  4. `FavoritesManager` (`lib/features/favorites/presentation/manager/`): `ChangeNotifier` tabanlı merkezi durum yöneticisi. Ekranlar `addListener` ile favori değişikliklerine abone olur; kalp butonu anlık olarak `Icons.favorite` / `Icons.favorite_border` arasında geçiş yapar.

