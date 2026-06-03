import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../../domain/entities/doctor_entity.dart';
import 'home_doctor_cards.dart';

String _imgFor(int index) =>
    AppAssets.doctorAvatars[index % AppAssets.doctorAvatars.length];

// ── 1. Header ─────────────────────────────────────────────────────────────────

/// Greeting strip (avatar, username, notification) with the search bar
/// overlapping its bottom edge.
class HomeHeader extends StatelessWidget {
  final String username;
  const HomeHeader({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 120,
            decoration: BoxDecoration(
              gradient: AppColors.headerGradient,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowLight.withValues(alpha: 0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircleAvatar(
                      radius: 27,
                      backgroundImage: AssetImage(AppAssets.appLogo),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 17),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            username.isNotEmpty ? username : 'Welcome',
                            style: const TextStyle(
                              fontSize: 20,
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            'Find your suitable Doctor here',
                            style: TextStyle(fontSize: 15, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 18, right: 5),
                    child: Icon(Icons.notifications_sharp,
                        size: 30, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          const Positioned(
            bottom: -25,
            left: 16,
            right: 16,
            child: HomeSearchBar(),
          ),
        ],
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
                        Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: DoctorCardFeatured(
                            name: doctor.name,
                            speciality: doctor.speciality,
                            rating: doctor.rating,
                            availability: doctor.availability,
                          ),
                        ),
                        SizedBox(
                          height: 165,
                          width: 110,
                          child: Image.asset(_imgFor(index), fit: BoxFit.cover),
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
          height: 100,
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        children: [
          Material(
            color: Colors.white,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: onTap,
              customBorder: const CircleBorder(),
              child: Container(
                height: 56,
                width: 56,
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
                  padding: const EdgeInsets.all(11),
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
                            child:
                                Image.asset(_imgFor(index), fit: BoxFit.cover),
                          ),
                          DoctorCardAvailable(
                            name: doctor.name,
                            speciality: doctor.speciality,
                            rating: doctor.rating,
                            availability: doctor.availability,
                            experience: doctor.experience,
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
                              child: Image.asset(
                                _imgFor(index),
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
