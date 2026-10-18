import 'package:flutter/material.dart';
import 'package:sparks/app/theme/app_colors.dart';

/// SPARKS merkezi ve dayanıklı görsel bileşeni.
///
/// Yerel varlıkları (`assets/...`) ve uzak ağ görsellerini (`http://`, `https://`)
/// tek bir arayüz arkasında birleştirir.
///
/// Özellikler:
/// - Yükleme esnasında editoryal palete uygun minimalist yükleme göstergesi.
/// - Ağ hataları, CORS engelleri veya format sorunlarında çökmeyen editoryal hata geri dönüşü (fallback).
/// - Hem mobil hem de Flutter Web ortamlarında taşma yapmadan tutarlı boyutlandırma.
class SparksImage extends StatelessWidget {
  const SparksImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.alignment = Alignment.center,
    this.fallbackWidget,
    this.loadingWidget,
    this.semanticLabel,
  });

  /// Görsel kaynağı: Yerel asset yolu ('assets/...') ya da HTTP/HTTPS URL'si
  final String imageUrl;

  /// Görsel yerleşim kuralı (varsayılan: [BoxFit.cover])
  final BoxFit fit;

  /// Genişlik
  final double? width;

  /// Yükseklik
  final double? height;

  /// Hizalama
  final AlignmentGeometry alignment;

  /// Görsel yüklenemediğinde veya ağ hatasında gösterilecek özel bileşen
  final Widget? fallbackWidget;

  /// Görsel yüklenirken gösterilecek özel bileşen
  final Widget? loadingWidget;

  /// Erişilebilirlik etiketi
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    if (imageUrl.trim().isEmpty) {
      return _buildErrorPlaceholder(context);
    }

    final isAsset = imageUrl.startsWith('assets/');

    if (isAsset) {
      return Image.asset(
        imageUrl,
        fit: fit,
        width: width,
        height: height,
        alignment: alignment,
        semanticLabel: semanticLabel,
        errorBuilder: (context, error, stackTrace) =>
            fallbackWidget ?? _buildErrorPlaceholder(context),
      );
    }

    return Image.network(
      imageUrl,
      fit: fit,
      width: width,
      height: height,
      alignment: alignment,
      semanticLabel: semanticLabel,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return loadingWidget ?? _buildLoadingPlaceholder(context);
      },
      errorBuilder: (context, error, stackTrace) =>
          fallbackWidget ?? _buildErrorPlaceholder(context),
    );
  }

  Widget _buildLoadingPlaceholder(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: AppColors.editorialAnthracite,
      child: const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryText),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorPlaceholder(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: AppColors.editorialAnthracite,
      alignment: Alignment.center,
      child: const Icon(
        Icons.broken_image_outlined,
        color: AppColors.secondaryText,
        size: 24,
      ),
    );
  }
}
