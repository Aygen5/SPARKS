# SPARKS — Proje Hedefi ve Genel Bakış

SPARKS, Zara'nın mobil arayüzünden ilham alan, editoryal moda estetiğini ve modern e-ticaret dinamiklerini Flutter ile hayata geçiren bir mobil alışveriş ve öğrenme projesidir.

---

## 1. Temel Hedefler

1. **Editoryal Tasarım Deneyimi:** Tam ekran moda görselleri, serif marka tipografisi, sıcak toprak tonları ile simsiyah kontrast alışveriş arayüzünü bir arada sunmak.
2. **Kusursuz Mimari:** Özellik bazlı (feature-first) katmanlı mimari (data, domain, presentation) ile temiz kod ve tek sorumluluk prensibini uygulamak.
3. **Reaktif Durum Yönetimi:** `Cubit` (Bloc) ile sepet ve favori durumlarını tüm ekranlar arasında gecikmesiz senkronize etmek.
4. **Merkezi ve Güvenilir Veri Kaynağı:** 10–15 seçilmiş lüks moda ürününü içeren, doğrulanabilir bir JSON ürün kataloğu üzerinden gerçekçi veri akışı sağlamak.
5. **Gelişmiş Navigasyon:** `GoRouter` ile 5 sekmeli sabit alt bar (`StatefulShellRoute`), derin bağlantı ve akıcı geçişler oluşturmak.
6. **Flutter Öğrenme Süreci:** Widget yaşam döngüsü, animasyon denetleyicileri, responsive yerleşimler, form doğrulamaları ve test alışkanlığı kazanmak.

---

## 2. Kullanılan Teknolojiler ve Bağımlılıklar

| Teknoloji | Sürüm / Paket | Kullanım Amacı |
|---|---|---|
| **Flutter SDK** | 3.47.7 (stable) | Mobil ve web arayüz motoru |
| **Dart SDK** | 3.13.5 | Temel programlama dili |
| **Gezinme** | `go_router: ^18.1.0` | Deklaratif rota yönetimi ve StatefulShellRoute |
| **Tipografi** | `google_fonts: ^9.0.0` | Playfair Display serif ve Inter sans-serif fontları |
| **Durum Yönetimi** | `flutter_bloc` / `bloc` | Sepet, favoriler ve katalog filtreleme (Aşama 8) |
| **Tasarım Sistemi** | Material 3 + Custom | Monokrom & Editoryal renk paleti, Keskin köşeler (0 radius) |
| **Veri Depolama** | Yerel JSON + SharedPreferences | Ürün kataloğu ve kullanıcı tercihleri |
| **Test** | `flutter_test` | Widget, birim ve responsive testleri |

---

## 3. Çalıştırma Bilgileri

```bash
# Bağımlılıkları güncelleme
flutter pub get

# Statik kod analizi
dart analyze

# Testleri çalıştırma
flutter test

# Web üzerinde test derlemesi
flutter build web
```