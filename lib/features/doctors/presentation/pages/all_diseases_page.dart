import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/app_container.dart';

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
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: AppColors.primary,
        titleSpacing: 4,
        leading: context.canPop()
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white),
                onPressed: () => context.pop(),
              )
            : null,
        title: const Text(
          'Browse by Specialty',
          style: TextStyle(
              color: Colors.white, fontSize: 19, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(14),
        child: ListView.builder(
          itemCount: _specialties.length,
          itemBuilder: (context, index) {
            final entry = _specialties[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: AppContainer(
                onTap: () => context.push(
                  '${AppRoutes.allDoctors}?speciality=${entry.specialty}',
                ),
                borderRadius: 14,
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: AssetImage(entry.image),
                      radius: 30,
                      backgroundColor: AppColors.primaryLighter,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            entry.subtitle,
                            style: const TextStyle(
                                fontSize: 13, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 18,
                      color: AppColors.textRed,
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
