/// SPARKS doğrulanmış editoryal görsel referans URL'leri.
/// Kaynak: docs/design-system.md
class AppImages {
  const AppImages._();

  /// Açılış ekranı tam ekran arka plan görseli (Sıcak bej/kehribar editoryal moda çekimi)
  /// Boyut: 1200 x 2141 px (9:16 dikey oran)
  static const String splashBackground =
      'https://i.pinimg.com/1200x/74/5d/78/745d78a35a90710fcb3b3b0580ce9c9f.jpg';

  /// Ana sayfa 1. görsel: Siyah vatkalı bluz ve beyaz bol pantolonlu model
  /// Boyut: 956 x 1489 px
  static const String homeLook1 =
      'https://i.pinimg.com/1200x/52/96/87/5296879fc3457d3f3534ddd52e9da382.jpg';

  /// Ana sayfa 2. görsel: Pencere önünde siyah kombinli model
  /// Boyut: 720 x 900 px
  static const String homeLook2 =
      'https://i.pinimg.com/736x/fb/a0/18/fba01891e9a67b1f7c736062a4c89f98.jpg';

  /// Ana sayfa 3. görsel: Loş ortamda krem takım elbiseli model
  /// Boyut: 800 x 1001 px
  static const String homeLook3 =
      'https://i.pinimg.com/1200x/a4/e0/d9/a4e0d91654a00f70c382b94a3660cd59.jpg';

  /// Ana sayfa 4. görsel: Işık ve gölge duvar önünde bej ceketli model
  /// Boyut: 736 x 1313 px
  static const String homeLook4 =
      'https://i.pinimg.com/736x/2f/a1/66/2fa166116fda44667f26c689ef1458a3.jpg';

  /// Ana sayfa için sırayla listelenen editoryal görseller listesi
  static const List<String> homeLookbookImages = [
    homeLook1,
    homeLook2,
    homeLook3,
    homeLook4,
  ];
}
