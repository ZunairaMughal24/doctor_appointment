import 'package:flutter/material.dart';
import 'package:fyp/core/constants/app_colors.dart';
import 'package:fyp/core/utils/app_animations.dart';

/// Composed onboarding/welcome illustration: one large doctor portrait in an
/// oval, with small floating doctor circles arranged around it.
class DoctorHeroIllustration extends StatelessWidget {
  final String mainImage;
  final List<String> floatingImages;

  const DoctorHeroIllustration({
    super.key,
    required this.mainImage,
    required this.floatingImages,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Big oval portrait.
          Container(
            width: 180,
            height: 250,
            decoration: BoxDecoration(
              borderRadius:
                  const BorderRadius.all(Radius.elliptical(180, 250)),
              border: Border.all(color: Colors.white, width: 5),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.25),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
              image: DecorationImage(
                image: AssetImage(mainImage),
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
            ),
          ),

          // Floating mini avatars around the oval — each bobs independently.
          if (floatingImages.isNotEmpty)
            Positioned(
              top: 24,
              left: 28,
              child: FloatingWidget(
                distance: 14,
                child: _FloatingAvatar(image: floatingImages[0], size: 58),
              ),
            ),
          if (floatingImages.length > 1)
            Positioned(
              top: 70,
              right: 22,
              child: FloatingWidget(
                delay: const Duration(milliseconds: 500),
                distance: 18,
                child: _FloatingAvatar(image: floatingImages[1], size: 48),
              ),
            ),
          if (floatingImages.length > 2)
            Positioned(
              bottom: 28,
              left: 18,
              child: FloatingWidget(
                delay: const Duration(milliseconds: 1000),
                distance: 11,
                child: _FloatingAvatar(image: floatingImages[2], size: 50),
              ),
            ),
        ],
      ),
    );
  }
}

class _FloatingAvatar extends StatelessWidget {
  final String image;
  final double size;
  const _FloatingAvatar({required this.image, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        image: DecorationImage(
          image: AssetImage(image),
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
        ),
      ),
    );
  }
}
