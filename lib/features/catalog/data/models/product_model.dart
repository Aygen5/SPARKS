import 'package:sparks/features/catalog/domain/entities/product.dart';

/// SPARKS Ürün Veri Modeli (Data Model).
/// JSON çözümleme, doğrulama ve serileştirme sorumluluğunu üstlenir.
/// Eksik veya hatalı zorunlu alanlarda sessizce devam etmek yerine açıklayıcı FormatException üretir.
class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.title,
    required super.category,
    required super.gender,
    required super.images,
    required super.price,
    super.oldPrice,
    super.discountText,
    required super.isOutOfStock,
    required super.description,
    required super.colorAndCode,
    required super.materials,
    super.sizes = const [],
  });

  /// Ham JSON haritasından doğrulayarak ProductModel nesnesi üretir.
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    // 1. id Alanı Doğrulaması
    final id = json['id'];
    if (id == null || id is! String || id.trim().isEmpty) {
      throw const FormatException('Ürün "id" alanı zorunludur ve boş olamaz.');
    }

    // 2. title Alanı Doğrulaması
    final title = json['title'];
    if (title == null || title is! String || title.trim().isEmpty) {
      throw FormatException(
        'Ürün ($id) için "title" alanı zorunludur ve boş olamaz.',
      );
    }

    // 3. category Alanı Doğrulaması
    final category = json['category'];
    if (category == null || category is! String || category.trim().isEmpty) {
      throw FormatException(
        'Ürün ($id) için "category" alanı zorunludur ve boş olamaz.',
      );
    }

    // 4. gender Alanı Doğrulaması
    final gender = json['gender'];
    if (gender == null ||
        gender is! String ||
        (gender.toUpperCase() != 'KADIN' && gender.toUpperCase() != 'ERKEK')) {
      throw FormatException(
        'Ürün ($id) için "gender" alanı zorunludur ve "KADIN" veya "ERKEK" olmalıdır.',
      );
    }

    // 5. images Alanı Doğrulaması (Tam olarak 2 görsel zorunludur)
    final imagesRaw = json['images'];
    if (imagesRaw == null || imagesRaw is! List) {
      throw FormatException(
        'Ürün ($id) için "images" alanı bir liste olmalıdır.',
      );
    }
    if (imagesRaw.length != 2) {
      throw FormatException(
        'Ürün ($id) için "images" alanı tam olarak 2 görsel adresi içermelidir (Mevcut: ${imagesRaw.length}).',
      );
    }
    final images = <String>[];
    for (var i = 0; i < imagesRaw.length; i++) {
      final img = imagesRaw[i];
      if (img is! String || img.trim().isEmpty) {
        throw FormatException(
          'Ürün ($id) için ${i + 1}. görsel geçerli bir URL metni olmalıdır.',
        );
      }
      images.add(img);
    }

    // 6. price Alanı Doğrulaması (Sayısal ve pozitif olmalıdır)
    final priceRaw = json['price'];
    if (priceRaw == null || priceRaw is! num || priceRaw <= 0) {
      throw FormatException(
        'Ürün ($id) için "price" alanı pozitif sayısal bir değer olmalıdır.',
      );
    }
    final price = priceRaw.toDouble();

    // 7. oldPrice Alanı Doğrulaması (Nullable)
    double? oldPrice;
    if (json['oldPrice'] != null) {
      final oldPriceRaw = json['oldPrice'];
      if (oldPriceRaw is! num || oldPriceRaw <= 0) {
        throw FormatException(
          'Ürün ($id) için "oldPrice" alanı belirtilmişse pozitif bir sayı olmalıdır.',
        );
      }
      oldPrice = oldPriceRaw.toDouble();
    }

    // 8. discountText Alanı (Nullable String)
    final discountText = json['discountText'] as String?;

    // 9. isOutOfStock Alanı Doğrulaması (bool olmalıdır)
    final isOutOfStockRaw = json['isOutOfStock'];
    if (isOutOfStockRaw == null || isOutOfStockRaw is! bool) {
      throw FormatException(
        'Ürün ($id) için "isOutOfStock" alanı boolean (true/false) olmalıdır.',
      );
    }

    // 10. description Alanı Doğrulaması
    final description = json['description'];
    if (description == null ||
        description is! String ||
        description.trim().isEmpty) {
      throw FormatException(
        'Ürün ($id) için "description" alanı zorunludur ve boş olamaz.',
      );
    }

    // 11. colorAndCode Alanı Doğrulaması
    final colorAndCode = json['colorAndCode'];
    if (colorAndCode == null ||
        colorAndCode is! String ||
        colorAndCode.trim().isEmpty) {
      throw FormatException(
        'Ürün ($id) için "colorAndCode" alanı zorunludur ve boş olamaz.',
      );
    }

    // 12. materials Alanı Doğrulaması
    final materials = json['materials'];
    if (materials == null || materials is! String || materials.trim().isEmpty) {
      throw FormatException(
        'Ürün ($id) için "materials" alanı zorunludur ve boş olamaz.',
      );
    }

    // 13. sizes Alanı (Opsiyonel beden listesi)
    final sizes = <String>[];
    if (json['sizes'] != null && json['sizes'] is List) {
      for (final s in json['sizes'] as List) {
        if (s is String && s.isNotEmpty) {
          sizes.add(s);
        }
      }
    }

    return ProductModel(
      id: id,
      title: title,
      category: category,
      gender: gender.toUpperCase(),
      images: images,
      price: price,
      oldPrice: oldPrice,
      discountText: discountText,
      isOutOfStock: isOutOfStockRaw,
      description: description,
      colorAndCode: colorAndCode,
      materials: materials,
      sizes: sizes,
    );
  }

  /// Model nesnesini JSON haritasına dönüştürür.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'gender': gender,
      'images': images,
      'price': price,
      'oldPrice': oldPrice,
      'discountText': discountText,
      'isOutOfStock': isOutOfStock,
      'description': description,
      'colorAndCode': colorAndCode,
      'materials': materials,
      if (sizes.isNotEmpty) 'sizes': sizes,
    };
  }

  /// Saf domain Product varlığından ProductModel kopyası oluşturur.
  factory ProductModel.fromEntity(Product product) {
    return ProductModel(
      id: product.id,
      title: product.title,
      category: product.category,
      gender: product.gender,
      images: product.images,
      price: product.price,
      oldPrice: product.oldPrice,
      discountText: product.discountText,
      isOutOfStock: product.isOutOfStock,
      description: product.description,
      colorAndCode: product.colorAndCode,
      materials: product.materials,
      sizes: product.sizes,
    );
  }
}
