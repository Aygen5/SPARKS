import 'package:flutter_test/flutter_test.dart';
import 'package:sparks/core/utils/currency_formatter.dart';
import 'package:sparks/features/catalog/data/models/product_model.dart';

void main() {
  group('ProductModel & Domain Entity Birim Testleri', () {
    final validJson = <String, dynamic>{
      'id': 'test-w-001',
      'title': 'DİK YAKA ÖRGÜ HIRKA',
      'price': 2890.0,
      'oldPrice': 3490.0,
      'discountText': '-%17',
      'gender': 'KADIN',
      'category': 'KAZAK | HIRKA',
      'images': [
        'https://example.com/img1.jpg',
        'https://example.com/img2.jpg',
      ],
      'description': 'Yüksek dik yakalı kalın örgü hırka.',
      'colorAndCode': 'SİYAH | 2753/032',
      'materials': '%85 Yün, %15 Poliamit',
      'isOutOfStock': false,
      'sizes': ['XS', 'S', 'M', 'L'],
    };

    test('1. Geçerli JSON haritasından ProductModel başarıyla oluşturulur', () {
      final product = ProductModel.fromJson(validJson);

      expect(product.id, 'test-w-001');
      expect(product.title, 'DİK YAKA ÖRGÜ HIRKA');
      expect(product.price, 2890.0);
      expect(product.oldPrice, 3490.0);
      expect(product.discountText, '-%17');
      expect(product.gender, 'KADIN');
      expect(product.category, 'KAZAK | HIRKA');
      expect(product.images.length, 2);
      expect(product.images[0], 'https://example.com/img1.jpg');
      expect(product.images[1], 'https://example.com/img2.jpg');
      expect(product.description, 'Yüksek dik yakalı kalın örgü hırka.');
      expect(product.colorAndCode, 'SİYAH | 2753/032');
      expect(product.materials, '%85 Yün, %15 Poliamit');
      expect(product.isOutOfStock, false);
      expect(product.sizes, ['XS', 'S', 'M', 'L']);
      expect(product.isDiscounted, true);
    });

    test('2. toJson() ve fromJson() döngüsü veri kaybı olmadan çalışır', () {
      final original = ProductModel.fromJson(validJson);
      final jsonMap = original.toJson();
      final roundtrip = ProductModel.fromJson(jsonMap);

      expect(roundtrip.id, original.id);
      expect(roundtrip.title, original.title);
      expect(roundtrip.price, original.price);
      expect(roundtrip.oldPrice, original.oldPrice);
      expect(roundtrip.discountText, original.discountText);
      expect(roundtrip.images, original.images);
      expect(roundtrip.colorAndCode, original.colorAndCode);
      expect(roundtrip.materials, original.materials);
      expect(roundtrip.isOutOfStock, original.isOutOfStock);
    });

    test('3. Zorunlu alan (id, title, category, gender) eksikliğinde açıklayıcı hata üretir', () {
      // id eksik
      expect(
        () => ProductModel.fromJson({...validJson}..remove('id')),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            contains('"id" alanı zorunludur'),
          ),
        ),
      );

      // title boş
      expect(
        () => ProductModel.fromJson({...validJson, 'title': '   '}),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            contains('"title" alanı zorunludur'),
          ),
        ),
      );

      // gender geçersiz
      expect(
        () => ProductModel.fromJson({...validJson, 'gender': 'ÇOCUK'}),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            contains('"KADIN" veya "ERKEK" olmalıdır'),
          ),
        ),
      );
    });

    test('4. images alanında tam olarak 2 görsel bulunması zorunludur', () {
      // 1 görsel (yetersiz)
      expect(
        () => ProductModel.fromJson({
          ...validJson,
          'images': ['https://example.com/img1.jpg'],
        }),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            contains('tam olarak 2 görsel adresi içermelidir'),
          ),
        ),
      );

      // 3 görsel (fazla)
      expect(
        () => ProductModel.fromJson({
          ...validJson,
          'images': [
            'https://example.com/img1.jpg',
            'https://example.com/img2.jpg',
            'https://example.com/img3.jpg',
          ],
        }),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            contains('tam olarak 2 görsel adresi içermelidir'),
          ),
        ),
      );

      // Boş URL içeren liste
      expect(
        () => ProductModel.fromJson({
          ...validJson,
          'images': ['https://example.com/img1.jpg', '   '],
        }),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            contains('geçerli bir URL metni olmalıdır'),
          ),
        ),
      );
    });

    test('5. oldPrice ve discountText alanları null olduğunda model sorunsuz oluşur', () {
      final jsonWithoutDiscount = {
        ...validJson,
        'oldPrice': null,
        'discountText': null,
      };

      final product = ProductModel.fromJson(jsonWithoutDiscount);
      expect(product.oldPrice, isNull);
      expect(product.discountText, isNull);
      expect(product.isDiscounted, false);
    });

    test('6. isOutOfStock boolean değeri true olduğunda tükenmiş durum doğru okunur', () {
      final jsonOutOfStock = {...validJson, 'isOutOfStock': true};

      final product = ProductModel.fromJson(jsonOutOfStock);
      expect(product.isOutOfStock, true);
    });

    test('7. CurrencyFormatter sayısal fiyatı Türkiye standartlarında (tr_TR) TL olarak formatlar', () {
      expect(CurrencyFormatter.format(2890.0), '2.890,00 TL');
      expect(CurrencyFormatter.format(6580.5), '6.580,50 TL');
      expect(CurrencyFormatter.format(1990.0), '1.990,00 TL');
      expect(CurrencyFormatter.format(4290.0, showDecimals: false), '4.290 TL');
      expect(CurrencyFormatter.calculateSavings(3490.0, 2890.0), 600.0);
    });
  });
}
