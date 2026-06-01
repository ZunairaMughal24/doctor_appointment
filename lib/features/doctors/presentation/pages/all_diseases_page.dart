import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';

class AllDiseasesPage extends StatelessWidget {
  const AllDiseasesPage({super.key});

  static const _diseaseNames = [
    'Typhoid fever',
    'Dengue fever',
    'Gastritis',
    'Kidney stone',
    'Piles',
    'Lungs cancer',
  ];

  // Icons ordered to match _diseaseNames
  static const _diseaseIcons = [
    AppAssets.diseaseTyphoid,
    AppAssets.diseaseDengue,
    AppAssets.diseaseStomach,
    AppAssets.diseaseKidney,
    AppAssets.diseasePiles,
    AppAssets.diseaseLungs,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardBg,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: AppColors.primary,
        title: const Text(
          'All Diseases',
          style: TextStyle(
              color: Colors.white, fontSize: 19, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(14),
        child: ListView.builder(
          itemCount: _diseaseNames.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () => context.push(AppRoutes.allDoctors),
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                color: index.isEven ? AppColors.background : const Color(0xFFEFFAEE),
                elevation: 6,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(10),
                  leading: CircleAvatar(
                    backgroundImage: AssetImage(_diseaseIcons[index]),
                    radius: 30,
                    backgroundColor: Colors.white,
                  ),
                  title: Text(
                    _diseaseNames[index],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  subtitle: const Text(
                    'Tap to find related doctors & specialists',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 18,
                    color: AppColors.textRed,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
