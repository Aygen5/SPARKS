/// SPARKS doğrulanmış editoryal görsel referansları.
/// Kaynak: docs/design-system.md
///
/// Açılış ekranı ve ana sayfa editoryal Lookbook görselleri, ağ gecikmesi, CORS kısıtlamaları
/// ve internet kesintilerinde dahi kusursuz editoryal sunum sağlamak üzere yerel varlık (asset)
/// olarak paketlenmiştir. Orijinal Pinterest URL referansları yedek ve referans olarak korunur.
class AppImages {
  const AppImages._();

  /// Açılış ekranı tam ekran arka plan görseli (Sıcak bej/kehribar editoryal moda çekimi)
  /// Boyut: 1200 x 2141 px (9:16 dikey oran)
  static const String splashBackground = 'assets/images/splash.jpg';

  /// Ana sayfa 1. editoryal görsel: Siyah vatkalı bluz ve beyaz bol pantolonlu model
  static const String homeLook1 = 'assets/images/look1.jpg';

  /// Ana sayfa 2. editoryal görsel: Pencere önünde siyah kombinli model
  static const String homeLook2 = 'assets/images/look2.jpg';

  /// Ana sayfa 3. editoryal görsel: Loş ortamda krem takım elbiseli model
  static const String homeLook3 = 'assets/images/look3.jpg';

  /// Ana sayfa 4. editoryal görsel: Işık ve gölge duvar önünde bej ceketli model
  static const String homeLook4 = 'assets/images/look4.jpg';

  /// Ana sayfa için sırayla listelenen editoryal görseller listesi
  static const List<String> homeLookbookImages = [
    homeLook1,
    homeLook2,
    homeLook3,
    homeLook4,
  ];

  // Kullanıcı tarafından iletilen orijinal Pinterest uzak URL referansları:
  static const String splashBackgroundRemote =
      'https://i.pinimg.com/1200x/74/5d/78/745d78a35a90710fcb3b3b0580ce9c9f.jpg';
  static const String homeLook1Remote =
      'https://i.pinimg.com/1200x/52/96/87/5296879fc3457d3f3534ddd52e9da382.jpg';
  static const String homeLook2Remote =
      'https://i.pinimg.com/736x/fb/a0/18/fba01891e9a67b1f7c736062a4c89f98.jpg';
  static const String homeLook3Remote =
      'https://i.pinimg.com/1200x/a4/e0/d9/a4e0d91654a00f70c382b94a3660cd59.jpg';
  static const String homeLook4Remote =
      'https://i.pinimg.com/736x/2f/a1/66/2fa166116fda44667f26c689ef1458a3.jpg';
}
