import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../appointments/domain/entities/appointment_entity.dart';

class DoctorReviewsSection extends StatelessWidget {
  final List<AppointmentEntity> reviews;
  final bool loading;
  final double rating;
  final int limit;
  final VoidCallback? onSeeAll;

  const DoctorReviewsSection({
    super.key,
    required this.reviews,
    required this.loading,
    required this.rating,
    this.limit = 3,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    final shown = reviews.take(limit).toList();
    final hasMore = reviews.length > limit;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Patient Reviews',
              style: AppTextStyles.h4.copyWith(
                color: AppColors.primary,
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 8),
            if (rating > 0) ...[
              const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
              const SizedBox(width: 2),
              Text(
                rating.toStringAsFixed(1),
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        if (loading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          )
        else if (reviews.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'No reviews yet.',
              style: AppTextStyles.label
                  .copyWith(fontWeight: FontWeight.normal, color: AppColors.textHint),
            ),
          )
        else
          ...shown.map((r) => DoctorReviewCard(review: r)),

        // ── See All Reviews button ───────────────────────────────────
        if (onSeeAll != null)
          Padding(
            padding: const EdgeInsets.only(top: 2, bottom: 8),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onSeeAll,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary, width: 1.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                icon: const Icon(Icons.reviews_rounded, size: 16),
                label: Text(
                  reviews.isEmpty
                      ? 'View Reviews'
                      : hasMore
                          ? 'See All ${reviews.length} Reviews'
                          : 'See All Reviews',
                  style: AppTextStyles.label.copyWith(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),

        const SizedBox(height: 4),
      ],
    );
  }
}

class DoctorReviewCard extends StatelessWidget {
  final AppointmentEntity review;
  const DoctorReviewCard({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    final stars = review.rating ?? 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryLighter,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  review.patientName,
                  style: AppTextStyles.label.copyWith(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  5,
                  (i) => Icon(
                    Icons.star_rounded,
                    size: 14,
                    color: i < stars ? Colors.amber : AppColors.divider,
                  ),
                ),
              ),
            ],
          ),
          if (review.ratingComment.isNotEmpty) ...[
            const SizedBox(height: 5),
            Text(
              review.ratingComment,
              style: AppTextStyles.label.copyWith(
                  fontWeight: FontWeight.normal, color: AppColors.textSecondary),
            ),
          ],
          if (review.createdAt != null) ...[
            const SizedBox(height: 4),
            Text(
              _formatDate(review.createdAt!),
              style: AppTextStyles.caption,
            ),
          ],
        ],
      ),
    );
  }

  static String _formatDate(DateTime d) => '${d.day}/${d.month}/${d.year}';
}
