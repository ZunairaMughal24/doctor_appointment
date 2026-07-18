import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../appointments/domain/entities/appointment_entity.dart';
import '../widgets/doctor_reviews.dart';

class DoctorReviewsPage extends StatelessWidget {
  final String doctorName;
  final List<AppointmentEntity> reviews;
  final double rating;

  const DoctorReviewsPage({
    super.key,
    required this.doctorName,
    required this.reviews,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardBg,
      appBar: CustomAppBar(
        title: 'Reviews',
        onBackPressed: () => Navigator.of(context).pop(),
      ),
      body: reviews.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.reviews_rounded,
                      size: 64, color: AppColors.textHint),
                  const SizedBox(height: 12),
                  Text(
                    'No reviews yet',
                    style: AppTextStyles.bodyLarge.copyWith(
                        fontSize: 16, color: AppColors.textSecondary),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // ── Rating summary banner ────────────────────────────────
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          color: Colors.amber, size: 32),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            rating > 0
                                ? rating.toStringAsFixed(1)
                                : 'No rating',
                            style: AppTextStyles.h1.copyWith(
                              fontSize: 24,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '${reviews.length} patient review${reviews.length == 1 ? '' : 's'}',
                            style: AppTextStyles.label.copyWith(
                              fontWeight: FontWeight.normal,
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        doctorName,
                        style: AppTextStyles.label.copyWith(
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── All reviews list ─────────────────────────────────────
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                    physics: const BouncingScrollPhysics(),
                    itemCount: reviews.length,
                    itemBuilder: (context, index) =>
                        DoctorReviewCard(review: reviews[index]),
                  ),
                ),
              ],
            ),
    );
  }
}
