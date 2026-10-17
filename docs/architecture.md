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
    │       └── catalog_placeholder_screen.dart # Aşama 5 editoryal kategori geçiş ekranı
    ├── product_detail/
    │   └── presentation/              # İki görselli, açıklamalı, stok kontrollü detay ekranı
    ├── search/
    │   └── presentation/              # KADIN/ERKEK sekmeli gerçek zamanlı arama
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
  - Aşama 5 kapsamında bu rota editoryal `CatalogPlaceholderScreen` bileşenini açar; sol üstteki geri butonu ile kullanıcı menü ekranına (seçili sekme ve kaydırma konumu korunarak) geri döner.
  - Aşama 6'da bu rota 3 modlu görünüm ve filtreleri içeren `CatalogScreen` bileşeniyle genişletilecektir.