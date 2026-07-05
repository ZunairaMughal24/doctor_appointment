import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
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
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.reviews_outlined,
                      size: 64, color: AppColors.textHint),
                  SizedBox(height: 12),
                  Text(
                    'No reviews yet',
                    style: TextStyle(
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
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '${reviews.length} patient review${reviews.length == 1 ? '' : 's'}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        doctorName,
                        style: TextStyle(
                          fontSize: 13,
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
