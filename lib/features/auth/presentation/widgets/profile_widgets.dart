import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_dropdown_field.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/weekly_availability_field.dart';
import '../../../doctors/domain/entities/weekly_availability.dart';

class ProfileAvailabilitySection extends StatelessWidget {
  final WeeklyAvailability schedule;
  final bool enabled;
  final ValueChanged<WeeklyAvailability> onChanged;

  const ProfileAvailabilitySection({
    super.key,
    required this.schedule,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 6),
            child: Text(
              'Weekly Availability',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
          WeeklyAvailabilityField(
            value: schedule,
            onChanged: onChanged,
            enabled: enabled,
          ),
        ],
      ),
    );
  }
}

class ProfileLabeledField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final bool enabled;
  final int maxLines;
  final int? maxLength;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final List<String>? options;

  const ProfileLabeledField({
    super.key,
    required this.label,
    required this.controller,
    required this.icon,
    required this.enabled,
    this.maxLines = 1,
    this.maxLength,
    this.keyboardType,
    this.validator,
    this.options,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 6),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
          if (options != null)
            AppDropdownField(
              controller: controller,
              hint: label,
              prefixIcon: icon,
              enabled: enabled,
              options: options!,
              validator: validator,
            )
          else
            AppTextField(
              controller: controller,
              hint: label,
              prefixIcon: icon,
              enabled: enabled,
              maxLines: maxLines,
              maxLength: maxLength,
              keyboardType: keyboardType,
              validator: validator,
            ),
        ],
      ),
    );
  }
}

class ProfileDoctorRatingsSection extends StatelessWidget {
  final List<dynamic> reviews;
  final bool loading;
  final double overallRating;

  const ProfileDoctorRatingsSection({
    super.key,
    required this.reviews,
    required this.loading,
    required this.overallRating,
  });

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (overallRating > 0)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
                const SizedBox(width: 6),
                Text(
                  '${overallRating.toStringAsFixed(1)} overall · ${reviews.length} recent review${reviews.length == 1 ? '' : 's'}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        if (reviews.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 4),
            child: Text(
              'No reviews yet.',
              style: TextStyle(fontSize: 13, color: AppColors.textHint),
            ),
          )
        else
          for (final r in reviews) ProfileReviewCard(review: r),
      ],
    );
  }
}

class ProfileReviewCard extends StatelessWidget {
  final dynamic review;
  const ProfileReviewCard({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    final stars = (review.rating as int?) ?? 0;
    final comment = (review.ratingComment as String?) ?? '';
    final patientName = (review.patientName as String?) ?? '';
    final createdAt = review.createdAt as DateTime?;

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
                  patientName,
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
          if (comment.isNotEmpty) ...[
            const SizedBox(height: 5),
            Text(
              comment,
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ],
          if (createdAt != null) ...[
            const SizedBox(height: 4),
            Text(
              '${createdAt.day}/${createdAt.month}/${createdAt.year}',
              style: const TextStyle(fontSize: 11, color: AppColors.textHint),
            ),
          ],
        ],
      ),
    );
  }
}
