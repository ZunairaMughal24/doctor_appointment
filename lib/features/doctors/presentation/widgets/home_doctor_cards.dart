import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/router/app_router.dart';

// ── Featured doctor card (horizontal carousel, gradient background) ───────────

class DoctorCardFeatured extends StatelessWidget {
  final String name;
  final String speciality;
  final String availability;
  final double rating;

  const DoctorCardFeatured({
    super.key,
    required this.name,
    required this.speciality,
    required this.rating,
    required this.availability,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodyLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold)),
          Text(speciality,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.label.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.white70)),
          const SizedBox(height: 4),
          DoctorAvailabilityBadge(availability: availability, lightText: true),
          _StarRow(
              rating: rating, color: Colors.yellow, textColor: Colors.white70),
          Row(children: [
            const Icon(Icons.call, size: 15, color: Colors.white),
            const SizedBox(width: 5),
            Text('Contact',
                style: AppTextStyles.bodySmall.copyWith(
                    fontStyle: FontStyle.italic,
                    color: Colors.white)),
          ]),
          const SizedBox(height: 7),
          Container(
            height: 25,
            width: 85,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppColors.inputBorder),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Center(
              child: Text('Approach me',
                  style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDark)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Available doctor card (horizontal carousel, white background) ─────────────

class DoctorCardAvailable extends StatelessWidget {
  final String name;
  final String speciality;
  final String availability;
  final String experience;
  final double rating;

  const DoctorCardAvailable({
    super.key,
    required this.name,
    required this.speciality,
    required this.rating,
    required this.availability,
    required this.experience,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      margin: const EdgeInsets.symmetric(vertical: 3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.body.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold)),
                Text(speciality,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textRed)),
                const SizedBox(height: 3),
                SizedBox(
                  width: double.maxFinite,
                  child: DoctorAvailabilityBadge(availability: availability),
                ),
                SizedBox(
                  width: double.maxFinite,
                  child: _StarRow(
                      rating: rating,
                      color: AppColors.primaryDark,
                      textColor: AppColors.primary),
                ),
                SizedBox(
                  width: double.maxFinite,
                  child: Text(experience,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption.copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                          color: AppColors.primary)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 3),
          SizedBox(
            height: 24,
            width: 70,
            child: Material(
              color: AppColors.primaryDark,
              borderRadius: BorderRadius.circular(5),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(5),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Center(
                    child: Text('Book now',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.caption.copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Compact doctor card (vertical grid, recommended section) ──────────────────

class DoctorCardCompact extends StatelessWidget {
  final String name;
  final String speciality;
  final double rating;
  final String availability;

  const DoctorCardCompact({
    super.key,
    required this.name,
    required this.speciality,
    required this.rating,
    required this.availability,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.label.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold)),
        Text(speciality,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textRed)),
        const SizedBox(height: 3),
        _StarRow(
            rating: rating,
            color: AppColors.primary,
            textColor: AppColors.primary),
        const SizedBox(height: 4),
        DoctorAvailabilityBadge(availability: availability),
      ],
    );
  }
}

// ── Shared doctor-availability badge ──────────────────────────────────────────

/// Shows clock icon and general availability text.
/// [lightText] = true for cards with a dark/gradient background.
class DoctorAvailabilityBadge extends StatelessWidget {
  final String availability;
  final bool lightText;

  const DoctorAvailabilityBadge({
    super.key,
    required this.availability,
    this.lightText = false,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = lightText ? Colors.white70 : AppColors.primary;
    final textColor = lightText ? Colors.white70 : AppColors.textSecondary;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.access_time_rounded,
          size: 13,
          color: iconColor,
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            availability.isNotEmpty ? availability : 'Not available',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Search bar ────────────────────────────────────────────────────────────────

class HomeSearchBar extends StatefulWidget {
  const HomeSearchBar({super.key});

  @override
  State<HomeSearchBar> createState() => _HomeSearchBarState();
}

class _HomeSearchBarState extends State<HomeSearchBar> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (_controller.text.trim().isNotEmpty) {
      context.push('${AppRoutes.search}?q=${_controller.text.trim()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.04),
            offset: const Offset(0, 2),
            blurRadius: 6,
            spreadRadius: 0,
          ),
        ],
      ),
      child: TextField(
        controller: _controller,
        onSubmitted: (_) => _submit(),
        style: AppTextStyles.bodyLarge.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: 'Search doctors, specialties...',
          hintStyle: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textHint.withValues(alpha: 0.85),
            fontWeight: FontWeight.w400,
          ),
          filled: true,
          fillColor: Colors.transparent,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 15, horizontal: 4),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.primary,
            size: 28,
          ),
          suffixIcon: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Material(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: _submit,
                borderRadius: BorderRadius.circular(8),
                child: const SizedBox(
                  width: 36,
                  height: 36,
                  child: Icon(
                    Icons.send_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Star row ──────────────────────────────────────────────────────────────────

class _StarRow extends StatelessWidget {
  final double rating;
  final Color color;
  final Color textColor;

  const _StarRow({
    required this.rating,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
              5,
              (i) => Icon(
                    i < rating.round()
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    size: 10,
                    color: color,
                  ))),
      const SizedBox(width: 4),
      Text(rating.toStringAsFixed(1),
          style: AppTextStyles.caption.copyWith(fontSize: 10, color: textColor)),
    ]);
  }
}
