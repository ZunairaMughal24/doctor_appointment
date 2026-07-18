import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/app_container.dart';
import '../../../../core/widgets/custom_app_bar.dart';

class AllDiseasesPage extends StatelessWidget {
  const AllDiseasesPage({super.key});

  static const _specialties = [
    (
      name: 'Cardiology',
      subtitle: 'Heart disease, blood pressure & chest pain',
      image: AppAssets.diseaseLungs,
      specialty: 'Cardiologist',
    ),
    (
      name: 'Dermatology',
      subtitle: 'Skin conditions, rashes & infections',
      image: AppAssets.diseasePiles,
      specialty: 'Dermatologist',
    ),
    (
      name: 'Neurology',
      subtitle: 'Migraines, seizures & nerve disorders',
      image: AppAssets.diseaseTyphoid,
      specialty: 'Neurologist',
    ),
    (
      name: 'Paediatrics',
      subtitle: 'Children\'s health, fever & dengue',
      image: AppAssets.diseaseDengue,
      specialty: 'Pediatrician',
    ),
    (
      name: 'Orthopaedics',
      subtitle: 'Bone pain, fractures & joint issues',
      image: AppAssets.diseaseKidney,
      specialty: 'Orthopedist',
    ),
    (
      name: 'Gynaecology',
      subtitle: 'Women\'s health, pregnancy & hormones',
      image: AppAssets.diseaseStomach,
      specialty: 'Gynecologist',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardBg,
      appBar: CustomAppBar(
        title: 'Browse by Specialty',
        onBackPressed: () => context.pop(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(14),
        child: ListView.builder(
          itemCount: _specialties.length,
          itemBuilder: (context, index) {
            final entry = _specialties[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AppContainer(
                onTap: () => context.push(
                  '${AppRoutes.specialists}?speciality=${entry.specialty}',
                ),
                borderRadius: 14,
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: AssetImage(entry.image),
                      radius: 25,
                      backgroundColor: AppColors.primaryLighter,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.name,
                            style: AppTextStyles.h4.copyWith(
                              fontSize: 16,
                              color: AppColors.textRed,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            entry.subtitle,
                            style: AppTextStyles.label.copyWith(
                              fontWeight: FontWeight.w400,
                              color: AppColors.textMuted,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Industry-level chevron indicator with a round background
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLighter,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 13,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
