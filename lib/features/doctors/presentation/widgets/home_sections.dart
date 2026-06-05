import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemUiOverlayStyle;
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../../../notifications/presentation/widgets/notification_bell.dart';
import '../../domain/entities/doctor_entity.dart';
import 'home_doctor_cards.dart';

class HomeHeader extends StatelessWidget {
  final String greeting;
  final String username;
  const HomeHeader({
    super.key,
    required this.greeting,
    required this.username,
  });

  @override
  Widget build(BuildContext context) {
    // No AppBar and no coloured block — a clean, minimal header on the light
    // background. Dark status-bar icons keep the system bar readable.
    final topInset = MediaQuery.of(context).padding.top;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark, // Android
        statusBarBrightness: Brightness.light, // iOS
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, topInset + 14, 16, 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 23,
                  backgroundColor: AppColors.primaryLight,
                  backgroundImage: AssetImage(AppAssets.appLogo),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        greeting,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        username.isNotEmpty ? username : 'Welcome',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 19,
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const NotificationBell(color: AppColors.primary, size: 27),
              ],
            ),
            const SizedBox(height: 14),
            const HomeSearchBar(),
          ],
        ),
      ),
    );
  }
}

// ── 2. Featured doctors ───────────────────────────────────────────────────────

class FeaturedDoctorsSection extends StatelessWidget {
  final List<DoctorEntity> doctors;
  final void Function(DoctorEntity) onTap;

  const FeaturedDoctorsSection({
    super.key,
    required this.doctors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: SizedBox(
        height: 165,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: doctors.length.clamp(0, 4),
          itemBuilder: (context, index) {
            final doctor = doctors[index];
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Material(
                color: AppColors.featuredCard,
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  onTap: () => onTap(doctor),
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    height: 160,
                    width: 255,
                    child: Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 6),
                            child: DoctorCardFeatured(
                              name: doctor.name,
                              speciality: doctor.speciality,
                              rating: doctor.rating,
                              availability: doctor.availability,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 165,
                          width: 110,
                          child: (doctor.imageUrl != null && doctor.imageUrl!.isNotEmpty)
                              ? Image.network(doctor.imageUrl!, fit: BoxFit.cover)
                              : Image.asset(AppAssets.avatarForDoctor(doctor.id), fit: BoxFit.cover),
                        ),
                      ],
                    ),
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

// ── 3. Disease categories ─────────────────────────────────────────────────────

class CategoriesSection extends StatelessWidget {
  const CategoriesSection({super.key});

  static const _diseaseNames = [
    'Dengue fever',
    'Gastritis',
    'Kidney stone',
    'Piles',
    'Lungs cancer',
    'Typhoid fever',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: 'Categories',
          onSeeAll: () => context.push(AppRoutes.allDiseases),
        ),
        SizedBox(
          height: 112,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            itemCount: AppAssets.diseaseIcons.length,
            itemBuilder: (context, index) {
              return _CategoryTile(
                icon: AppAssets.diseaseIcons[index],
                label: _diseaseNames[index],
                // Each category opens the related specialists list.
                onTap: () => context.push(AppRoutes.allDoctors),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Circular, tappable category tile with a label underneath.
class _CategoryTile extends StatelessWidget {
  final String icon;
  final String label;
  final VoidCallback onTap;

  const _CategoryTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Column(
        children: [
          Material(
            color: Colors.white,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: onTap,
              customBorder: const CircleBorder(),
              child: Container(
                height: 66,
                width: 66,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  // Match the app's 3D depth (bottom-right shadow only).
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFFC2D2E1),
                      offset: Offset(3, 4),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Image.asset(icon, fit: BoxFit.contain),
                ),
              ),
            ),
          ),
          const SizedBox(height: 7),
          SizedBox(
            width: 74,
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── 4. Available doctors ──────────────────────────────────────────────────────

class AvailableDoctorsSection extends StatelessWidget {
  final List<DoctorEntity> doctors;
  final void Function(DoctorEntity) onTap;

  const AvailableDoctorsSection({
    super.key,
    required this.doctors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SectionHeader(
          title: 'Available Doctors',
          onSeeAll: () => context.push(AppRoutes.allDoctors),
        ),
        const SizedBox(height: 5),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: doctors.length.clamp(0, 4),
            itemBuilder: (context, index) {
              final doctor = doctors[index];
              return Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Material(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    onTap: () => onTap(doctor),
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      height: 140,
                      width: 230,
                      child: Row(
                        children: [
                          SizedBox(
                            height: 150,
                            width: 90,
                            child: (doctor.imageUrl != null && doctor.imageUrl!.isNotEmpty)
                                ? Image.network(doctor.imageUrl!, fit: BoxFit.cover)
                                : Image.asset(AppAssets.avatarForDoctor(doctor.id), fit: BoxFit.cover),
                          ),
                          Expanded(
                            child: DoctorCardAvailable(
                              name: doctor.name,
                              speciality: doctor.speciality,
                              rating: doctor.rating,
                              availability: doctor.availability,
                              experience: doctor.experience,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ── 5. Recommended doctors ────────────────────────────────────────────────────

class RecommendedDoctorsSection extends StatelessWidget {
  final List<DoctorEntity> doctors;
  final void Function(DoctorEntity) onTap;

  const RecommendedDoctorsSection({
    super.key,
    required this.doctors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SectionHeader(
          title: 'Recommended Doctors',
          onSeeAll: () => context.push(AppRoutes.allDoctors),
        ),
        SizedBox(
          height: 188,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            itemCount: doctors.length.clamp(0, 4),
            itemBuilder: (context, index) {
              final doctor = doctors[index];
              return Padding(
                padding: const EdgeInsets.only(left: 8, top: 2, bottom: 4),
                child: Material(
                  color: AppColors.cardBg,
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    onTap: () => onTap(doctor),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      width: 138,
                      decoration: BoxDecoration(
                        color: AppColors.cardBg,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0xFFC2D2E1),
                            offset: Offset(3, 4),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: (doctor.imageUrl != null && doctor.imageUrl!.isNotEmpty)
                                  ? Image.network(
                                      doctor.imageUrl!,
                                      height: 78,
                                      width: 78,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.asset(
                                      AppAssets.avatarForDoctor(doctor.id),
                                      height: 78,
                                      width: 78,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                            const SizedBox(height: 6),
                            DoctorCardCompact(
                              name: doctor.name,
                              speciality: doctor.speciality,
                              rating: doctor.rating,
                              availability: doctor.availability,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ── Shared section header row ─────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onSeeAll;

  const _SectionHeader({required this.title, required this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          InkWell(
            onTap: onSeeAll,
            borderRadius: BorderRadius.circular(4),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Text(
                'see all',
                style: TextStyle(fontSize: 16, color: AppColors.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
