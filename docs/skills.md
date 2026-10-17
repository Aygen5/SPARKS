# SPARKS — Geliştirme, Öğretme ve Kalite Kuralları

## 1. Öğrenme ve İletişim Yaklaşımı
- **Türkçe Açıklamalar:** Tüm açıklamalar, kod içi açıklamalar ve raporlar anlaşılır, duru ve somut bir Türkçe ile yazılır.
- **Kavram Önce, Kod Sonra:** Yeni bir kavram (örneğin `StatefulShellRoute`, `CurvedAnimation`, `Cubit`) eklendiğinde önce ne olduğu ve neden seçildiği açıklanır, ardından koddaki somut kullanımı gösterilir.
- **Gereksiz Soyutlamalardan Kaçınma:** Projenin boyutunu aşan yapay katmanlar, boş use-case sınıfları veya birden fazla durum yönetimi paketi bir arada kullanılmaz.

---

## 2. Tasarım ve Editoryal Estetik Kuralları
- **Zara İlhamlı Estetik:** Yuvarlak köşeli, renkli, hazır e-ticaret şablonu hissi veren bileşenler kullanılmaz.
- **Keskin ve Minimal:** Kartlar, butonlar ve fotoğraflar keskin köşelere (`borderRadius: 0`) ve 1px ince zarif kenarlıklara sahip olmalıdır.
- **Tipografi Ayrımı:** Marka adı ve büyük bölüm başlıkları için zarif serif; ürün detayları, butonlar ve fiyatlar için sade sans-serif kullanılır.
- **Taşma Kontrolü:** Küçük mobil ekranlarda (360x640 vb.) hiçbir ekranda piksel taşması (overflow) olmamalıdır.

---

## 3. Veri Doğruluğu ve Etik İlkeler
- **Uydurma Veri Yok:** Gerçekte var olmayan beden, indirim, marka veya ürün yorumları üretilmez.
- **İzinsiz Veri Kazıma (Scraping) Yok:** Zara'nın veya üçüncü parti sistemlerin telifli sunucularına izinsiz otomatik bot istekleri atılmaz.
- **Para Birimi:** Fiyatlar Türk lirası (`TL`) cinsinden, standart formatta (`3.290,00 TL`) gösterilir.
- **Dürüst Raporlama:** Gerçekleşmeyen bir API entegrasyonu veya çalıştırılmamış bir test çalıştırılmış gibi raporlanamaz.

---

## 4. Kodlama ve Mimari Kuralları
- **`main.dart` Sadeliği:** `main.dart` yalnızca `WidgetsFlutterBinding.ensureInitialized()` ve `runApp()` çağrısını içerir.
- **Deklaratif Navigasyon:** Sayfalar arası geçişlerde `GoRouter` ve 5 sekmeli alt bar için `StatefulShellRoute` kullanılır.
- **Cubit ile Durum Yönetimi:** Sepet ve favoriler merkezi Cubit sınıfları ile tek bir kaynaktan yönetilir.
- **Merkezi Sabitler:** Görsel URL'leri, renkler, metin stilleri ve aralıklar dağınık dosyalara yazılmaz; ilgili merkezi tema ve sabit sınıflarından alınır.

---

## 5. Aşama Tamamlama ve Durma İlkesi
- Her aşama tamamlandığında `dart analyze` ve `flutter test` çalıştırılır.
- Kullanıcıya Türkçe tamamlama raporu sunulur ve **kullanıcı onayı beklenir**.
- Kullanıcı onayı alınmadan bir sonraki aşamanın kodlamasına kendiliğinden **asla başlanmaz**.