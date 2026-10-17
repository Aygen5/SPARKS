/// SPARKS Türk Lirası (TL) Para Birimi Biçimlendirici.
/// Sayısal fiyat değerlerini Türkiye muhasebe ve alışveriş standartlarına (tr_TR)
/// uygun biçimde formatlar (Binlik ayracı: nokta, kuruş ayracı: virgül).
///
/// Örnekler:
/// - `2890.0` -> `"2.890,00 TL"`
/// - `12500.5` -> `"12.500,50 TL"`
/// - `99.9` -> `"99,90 TL"`
class CurrencyFormatter {
  const CurrencyFormatter._();

  /// Verilen sayısal fiyatı TL formatında biçimlendirir.
  static String format(double price, {bool showDecimals = true}) {
    if (price.isNaN || price.isInfinite) return '0,00 TL';

    // Fiyatı iki ondalık basamağa sabitle
    final isNegative = price < 0;
    final absPrice = price.abs();
    final fixedStr = absPrice.toStringAsFixed(2);
    final parts = fixedStr.split('.');
    final integerPart = parts[0];
    final decimalPart = parts.length > 1 ? parts[1] : '00';

    // Binlik basamakları nokta ile ayır
    final buffer = StringBuffer();
    final length = integerPart.length;
    for (var i = 0; i < length; i++) {
      if (i > 0 && (length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(integerPart[i]);
    }

    final formattedInteger = buffer.toString();
    final prefix = isNegative ? '-' : '';

    if (!showDecimals) {
      return '$prefix$formattedInteger TL';
    }

    return '$prefix$formattedInteger,$decimalPart TL';
  }

  /// İndirim tutarını veya eski fiyat farkını hesaplar
  static double calculateSavings(double oldPrice, double currentPrice) {
    if (oldPrice <= currentPrice) return 0.0;
    return oldPrice - currentPrice;
  }
}
