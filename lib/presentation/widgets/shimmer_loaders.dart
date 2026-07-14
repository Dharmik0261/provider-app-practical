import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class ProductGridShimmer extends StatelessWidget {
  const ProductGridShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.72,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ShimmerBox(
                width: double.infinity,
                height: double.infinity,
                borderRadius: 16,
              ),
            ),
            const SizedBox(height: 12),
            const ShimmerBox(width: 120, height: 16),
            const SizedBox(height: 6),
            const ShimmerBox(width: 80, height: 12),
            const SizedBox(height: 8),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ShimmerBox(width: 60, height: 16),
                ShimmerBox(width: 24, height: 24, borderRadius: 12),
              ],
            ),
          ],
        );
      },
    );
  }
}

class CategoryListShimmer extends StatelessWidget {
  const CategoryListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 16),
        itemCount: 6,
        itemBuilder: (context, index) {
          return const Padding(
            padding: EdgeInsets.only(right: 10),
            child: ShimmerBox(
              width: 90,
              height: 36,
              borderRadius: 20,
            ),
          );
        },
      ),
    );
  }
}
