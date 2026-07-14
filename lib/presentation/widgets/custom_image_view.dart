import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

class CustomImageView extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const CustomImageView({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final Widget imageWidget = CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => Shimmer.fromColors(
        baseColor: Colors.grey.shade200,
        highlightColor: Colors.grey.shade100,
        child: Container(
          width: width ?? double.infinity,
          height: height ?? double.infinity,
          color: Colors.white,
        ),
      ),
      errorWidget: (context, url, error) => Container(
        width: width ?? double.infinity,
        height: height ?? double.infinity,
        color: Colors.grey.shade100,
        child: const Icon(
          Icons.image_not_supported_outlined,
          color: Colors.grey,
          size: 24,
        ),
      ),
    );

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }
}
