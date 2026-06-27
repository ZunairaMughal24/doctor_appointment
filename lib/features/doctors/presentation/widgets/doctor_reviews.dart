import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../appointments/domain/entities/appointment_entity.dart';

class DoctorReviewsSection extends StatelessWidget {
  final List<AppointmentEntity> reviews;
  final bool loading;
  final double rating;

  const DoctorReviewsSection({
    super.key,
    required this.reviews,
    required this.loading,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Patient Reviews',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            if (rating > 0) ...[
              const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
              const SizedBox(width: 2),
              Text(
                rating.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 14,
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
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'No reviews yet.',
              style: TextStyle(fontSize: 13, color: AppColors.textHint),
            ),
          )
        else
          ...reviews.map((r) => DoctorReviewCard(review: r)),
        const SizedBox(height: 8),
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
                  style: const TextStyle(
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
              style:
                  const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ],
          if (review.createdAt != null) ...[
            const SizedBox(height: 4),
            Text(
              _formatDate(review.createdAt!),
              style:
                  const TextStyle(fontSize: 11, color: AppColors.textHint),
            ),
          ],
        ],
      ),
    );
  }

  static String _formatDate(DateTime d) => '${d.day}/${d.month}/${d.year}';
}
