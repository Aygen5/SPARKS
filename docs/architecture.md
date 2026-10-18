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

---

## 9. Merkezi Sepet Yönetimi ve Favori Senkronizasyonu (Aşama 8)

### 9.1. Mimari Prensipler ve Durum Yönetimi
- **State Management:** `flutter_bloc` (`CartCubit` ve `CartState`).
- **Veri Saklama Prensibi:**
  - Sepet kalıcılığında yalnızca ürün kimlikleri ve adetleri saklanır: `Map<String, int>` (örn. `{"sparks-w-001": 2}`).
  - Fiyatlar, ürün adları ve görseller sepet kalıcılığına yazılmaz; repository üzerinden güncel ürün varlıkları ile birleştirilerek dinamik `CartItemView` varlığı oluşturulur.
  - Böylece fiyat değişiklikleri anında sepete yansır ve veri tutarsızlığı önlenir.
- **İş Mantığı ve Kurallar:**
  1. **İlk Ekleme:** Ürün sepette yoksa adedi `1` olarak listeye eklenir.
  2. **Tekrar Ekleme:** Aynı ürün tekrar eklendiğinde yeni satır oluşturulmaz; mevcut satırın adedi `+1` artırılır (`quantity++`).
  3. **Farklı Ürünler:** Farklı ürün kimlikleri bağımsız satırlar olarak sepette yer alır.
  4. **Minimum Adet:** Adet azaltma (`decrementQuantity`) minimum `1` adede kadar indirilebilir; adet 1 iken eksiye basıldığında ürün sepetten silinmez.
  5. **Silme İşlemi:** Ürün yalnızca çöp kutusu/silme aksiyonu ile sepetten tamamen çıkartılır (`removeProduct`).
  6. **Tükenen Ürün Koruması:** `product.isOutOfStock == true` olan ürünler sepete eklenemez; reddedilir ve kullanıcıya hata mesajı gösterilir.
  7. **Tümünü Temizleme:** `clearCart()` tek çağrıyla tüm sepeti sıfırlar ve boş duruma geçirir.

### 9.2. Kalıcılık Katmanı (`CartLocalDataSource` & `CartRepository`)
- **Depolama Anahtarı:** `sparks_cart_items` (SharedPreferences JSON String).
- Favori anahtarı (`sparks_favorite_product_ids`) ile sepet anahtarı tamamen ayrı tutulur; birbirlerinin verisini etkilemez.
- Test ortamı için `InMemoryCartLocalDataSource` çifti mevcuttur.

### 9.3. Ekran ve Navigasyon Entegrasyonu
- **Dinamik Alt Navigasyon Rozeti:**
  - `SparksBottomNavBar` sepet sekmesi üzerinde `state.totalItemCount` değerini editoryal formatta gösterir: `[ 0 ]`, `[ 1 ]`, `[ 2 ]` vb.
  - `MainScaffold` içerisindeki `BlocBuilder<CartCubit, CartState>` ile sepet sayacı anlık olarak güncellenir.
- **Ürün Detay Entegrasyonu (`ProductDetailScreen`):**
  - `SEPETE EKLE` butonu `CartCubit.addProduct(product)` fonksiyonunu tetikler ve başarı durumunda `"Ürün sepete eklendi"` bildirimini (SnackBar) gösterir.
- **Gerçek Sepet Ekranı (`CartScreen`):**
  - Ürün fotoğrafları, başlıkları, renk/kod bilgileri, birim ve toplam fiyatları.
  - Adet artırma (+) ve azaltma (-) butonları, çöp kutusu ile satır silme ve üst barda "SEPETİ TEMİZLE" aksiyonu.
  - Boş sepet durumunda editoryal mesaj ve "KATALOĞA DÖN" yönlendirme butonu.
- **Katalog ve Arama Favori Senkronizasyonu:**
  - `CatalogScreen` (tüm 3 görünüm modunda) ve `SearchScreen` ürün kartları üzerine kalp ikonu eklendi.
  - Tümü `FavoritesManager` dinleyicisine bağlıdır; bir ekranda kalbe basıldığında tüm ekranlardaki kalp ikonu anında senkronize olur.

---

## 10. Favoriler, Hesabım ve Alışverişlerim Mimarisi (Aşama 9)

### 10.1. Gerçek Favoriler Ekranı (`FavoritesScreen`)
- **Veri Akışı:**
  `FavoritesScreen` -> `FavoritesManager` (kayıtlı kimlikler kümesi) -> `ProductRepository.getProductById(id)` -> Gerçek ürün varlıkları.
- **Senkronizasyon:**
  - `FavoritesManager`'a doğrudan `ChangeNotifier` dinleyicisi (`addListener`) ile bağlanır.
  - Başka bir ekrandan (katalog, arama, detay) favori eklendiğinde veya çıkarıldığında anında ekrana yansır.
  - `FavoritesScreen` üzerinde kalp ikonuna basıldığında ürün anında listeden silinir (`_favoritesManager.removeFavorite(id)`).
- **Durum Yönetimi:**
  - Yüklenme: Editoryal minimalist yükleme spinner'ı.
  - Hata: Kullanıcı dostu hata bildirimi ve `TEKRAR DENE` aksiyon butonu.
  - Boş Durum: Minimalist kalp ikonu, `FAVORİ LİSTENİZ BOŞ` başlığı ve `KATALOĞA DÖN` eylem butonu.
- **Navigasyon:** Ürün kartına dokunulduğunda doğrudan `/product/:id` rotasına gidilir; geri dönüldüğünde liste senkronize kalır.

### 10.2. Hesabım Ekranı (`AccountScreen`) ve Misafir Kullanıcı Deneyimi
- **Kimlik Doğrulama Sınırları ve Dürüstlük:**
  - Projede henüz gerçek bir backend, oturum yönetimi veya auth servisi bulunmamaktadır.
  - Sahte profil, uydurma kullanıcı adı veya çalışmayan butonlar üretilmemiştir.
  - Misafir kullanıcı deneyimi (`MİSAFİR KULLANICI`) açık ve şeffaf bir dille sunulur; giriş/üyelik servisinin henüz aktif olmadığı belirtilir.
- **Fonksiyonel Editoryal Kısayollar:**
  - `FAVORİLERİM` -> `/favorites` (`FavoritesScreen`)
  - `ALIŞVERİŞLERİM` -> `/account/orders` (`OrdersScreen`)
  - `SEPETİM` -> `/cart` (`CartScreen`)
- **Doğrulanabilir Destek Alanı:** Sürüm bilgisi (`SPARKS v1.0.0`), marka sloganı ve müşteri destek e-postası (`destek@sparks.fashion`).

### 10.3. Alışverişlerim Ekranı (`OrdersScreen`)
- **Sipariş Altyapısı Sınırları:**
  - Gerçek sipariş/ödeme API'si bulunmadığından sahte sipariş veya uydurma sipariş numaraları kesinlikle üretilmez; sepetteki ürünler sipariş gibi gösterilmez.
  - Kullanıcıya tamamlanmış bir sipariş kaydı bulunmadığı ve sipariş geçmişi için sipariş altyapısının gerektiği net bir dille aktarılır (`HENÜZ BİR SİPARİŞİNİZ YOK`).
- **Aksiyonlar:** `KATALOĞA DÖN` (`/menu`) ve `SEPETE GİT` (`/cart`) yönlendirmeleri.

---

## 11. Sepet Etkileşimleri, Sipariş Öncesi Kontroller ve Checkout Mimarisi (Aşama 10)

### 11.1. Sepet İyileştirmeleri ve Alışveriş Öncesi Kontroller (`CartScreen`)
- **Sepeti Temizleme Onay Dialogu:**
  - "SEPETİ TEMİZLE" eylemi kazara dokunmaları önlemek adına editoryal onay dialogu (`cart_clear_confirm_dialog`) ile korunur.
  - VAZGEÇ (`cart_clear_cancel_button`) dialogu kapatır; TEMİZLE (`cart_clear_confirm_button`) sepeti kalıcı olarak sıfırlar.
- **Tükenen Ürün ve Stok Doğrulaması:**
  - Sepetteki ürün `Product.isOutOfStock == true` olduğunda editoryal `STOKTA YOK` rozeti gösterilir.
  - Adet artırma butonu (+) devre dışı bırakılır; `CartCubit.incrementQuantity` metodu da repository doğrulaması yaparak tükenen ürünün adedinin artırılmasını engeller.
- **Tıklanabilir Ürün Kartları:**
  - Sepetteki ürün görseli ve başlığı üzerinden ilgili ürünün detayına (`/product/:id`) hızlı ve kesintisiz geçiş sağlanır.

### 11.2. Sipariş Özeti ve İnceleme Ekranı (`CheckoutScreen`)
- **Rota Tanımı:** `/checkout` (`AppRoutes.checkout`), `CartScreen` üzerindeki "DEVAM ET" butonu ile tetiklenir.
- **Tek Merkezli Durum (Single Source of Truth):**
  - Fiyatlar ve ürün kalemleri ayrı bir state veya cubit oluşturulmadan doğrudan `CartCubit` üzerinden okunur (`getCartItemViews()`).
  - Ara toplam, ücretsiz standart kargo (`ÜCRETSİZ`) ve genel toplam `CurrencyFormatter` ile standartlaştırılmış editoryal formatta gösterilir.
- **Reaktif Senkronizasyon ve Boş Durum:**
  - Sepet boşaldığında veya ekran doğrudan boş sepetle açıldığında `SEPETİNİZDE ÜRÜN BULUNMUYOR` boş durumu gösterilir ve `SEPETE DÖN` butonu sunulur.
- **Dürüstlük ve Altyapı Sınırları:**
  - Sahte ödeme formları, kredi kartı girişleri, uydurma kupon kodları veya sahte sipariş onayları kesinlikle üretilmez.
  - "ÖNEMLİ BİLGİLENDİRME" kutusu ile SPARKS ödeme ve canlı sipariş altyapısının henüz aktif olmadığı şeffafça ifade edilir.
  - "SİPARİŞİ TAMAMLA" butonu kullanıcıya ödeme altyapısının geliştirilme aşamasında olduğunu dürüstçe bildirir.

---

## 12. Kimlik Doğrulama Altyapısı ve Oturum Yönetimi (Aşama 11)

### 12.1. Mimari Prensipler ve Bağımlılık İzolasyonu
- **Domain Katmanı:**
  - `AppUser`: Firebase'in `User` nesnesini izole eden, UI ve iş mantığı için temiz entity modeli (`id`, `email`, `displayName`, `isEmailVerified`, `formattedName`).
  - `AuthRepository`: Oturum akışını (`authStateChanges`), geçerli kullanıcıyı (`currentUser`), kayıt, giriş, çıkış, parola sıfırlama ve e-posta doğrulama sözleşmelerini tanımlar.
  - `AuthException`: Kullanıcıya sunulacak açıklayıcı Türkçe hata mesajı (`message`) ve sistem kodunu (`code`) taşır.
- **Data Katmanı:**
  - `AuthErrorMapper`: Firebase hata kodlarını (`user-not-found`, `wrong-password`, `invalid-credential`, `email-already-in-use`, `weak-password` vb.) kullanıcı dostu Türkçe metinlere dönüştürür.
  - `AuthRepositoryImpl`: `FirebaseAuth` ile konuşur. Firebase henüz initialize edilmemişse veya test ortamındaysa uygulamanın çökmesini engeller, güvenli fallback ve açıklayıcı hata yönetimi sunar.
- **Presentation Katmanı:**
  - `AuthState`: Tek merkezli durum modeli (`AuthStatus.initial`, `unauthenticated`, `loading`, `authenticated`, `error`), `user` ve `errorMessage`.
  - `AuthCubit`: `authStateChanges` akışını otomatik dinler, tek doğruluk kaynağı (Single Source of Truth) olarak kayıt, giriş ve çıkış durumlarını yönetir.

### 12.2. Firebase Yapılandırması ve Kurulum Gereksinimi
- Uygulamada sahte oturum açmış gibi yanıltıcı davranışlar engellenmiştir.
- Gerçek Firebase bağlantısı için:
  1. Firebase Console üzerinden `SPARKS` projesinin oluşturulması,
  2. `Authentication -> Sign-in method` sekmesinde `Email/Password` sağlayıcısının etkinleştirilmesi,
  3. `flutterfire configure` komutuyla platform yapılandırmalarının (`firebase_options.dart`) projeye dahil edilmesi gerekmektedir.




