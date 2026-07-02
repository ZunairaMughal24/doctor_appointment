import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../../../notifications/presentation/widgets/notification_bell.dart';
import '../../domain/entities/doctor_entity.dart';
import 'home_doctor_cards.dart';

/// Shared horizontal inset for all home screen content.
const double kHomeHorizontalPadding = 16.0;

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
    final topInset = MediaQuery.of(context).viewPadding.top;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // ── Header Background Card ──
        Container(
          margin: const EdgeInsets.only(
              bottom: 27), // Half of the search bar height (54 / 2)
          decoration: const BoxDecoration(
            gradient: AppColors.headerVerticalGradientAlt,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(14),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              kHomeHorizontalPadding,
              topInset + 12,
              kHomeHorizontalPadding,
              35, // Extra bottom padding so elements don't get covered by the overlapping search bar
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.6),
                          width: 2,
                        ),
                      ),
                      child: const CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.white,
                        backgroundImage: AssetImage(AppAssets.appLogo),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            greeting,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withValues(alpha: 0.85),
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            username.isNotEmpty ? username : 'Welcome',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 22,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.3,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 1),
                          const Text(
                            'Your health, our priority.',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w400,
                              color: Color.fromARGB(179, 255, 255, 255),
                              letterSpacing: 0.1,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 44,
                      width: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25),
                          width: 1,
                        ),
                      ),
                      child: const Center(
                        child: NotificationBell(color: Colors.white, size: 24),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        // ── Search Bar positioned half in, half out ──
        Positioned(
          left: kHomeHorizontalPadding,
          right: kHomeHorizontalPadding,
          bottom: 0,
          height: 54,
          child: const HomeSearchBar(),
        ),
      ],
    );
  }
}

class HomeStatsStrip extends StatelessWidget {
  const HomeStatsStrip({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: kHomeHorizontalPadding, vertical: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.06),
              offset: const Offset(0, 2),
              blurRadius: 8,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _StatItem(label: 'Specialists', value: '500+', accent: true),
            _StatDivider(),
            _StatItem(label: 'Specialties', value: '20+'),
            _StatDivider(),
            _StatItem(label: 'Patients Served', value: '10K+', accent: true),
          ],
        ),
      ),
    );
  }
}

// ── Stats helper widgets ───────────────────────────────────────────────────────

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final bool accent;
  const _StatItem(
      {required this.label, required this.value, this.accent = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: accent ? AppColors.textRed : AppColors.primary,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
            color: Color.fromARGB(255, 109, 112, 114),
            letterSpacing: 0.1,
          ),
        ),
      ],
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();
  @override
  Widget build(BuildContext context) => Container(
        height: 28,
        width: 1,
        color: const Color(0xFFD4E5F3),
      );
}

class HomeSectionTitle extends StatelessWidget {
  final String title;
  final String? subtitle;
  const HomeSectionTitle({super.key, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          kHomeHorizontalPadding, 16, kHomeHorizontalPadding, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 17.5,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              letterSpacing: -0.2,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 1),
            Text(
              subtitle!,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w400,
                color: Color.fromARGB(255, 109, 112, 114),
                letterSpacing: 0.1,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Featured doctors ──────────────────────────────────────────────────────────

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
              kHomeHorizontalPadding, 10, kHomeHorizontalPadding, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Top Specialists',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 3),
              const Text(
                'Highly rated, verified medical professionals',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w400,
                  color: Color.fromARGB(255, 109, 112, 114),
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 175,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
                horizontal: kHomeHorizontalPadding, vertical: 6),
            itemCount: doctors.length.clamp(0, 4),
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final doctor = doctors[index];
              return _FeaturedDoctorCard(
                doctor: doctor,
                onTap: () => onTap(doctor),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _FeaturedDoctorCard extends StatelessWidget {
  final DoctorEntity doctor;
  final VoidCallback onTap;

  const _FeaturedDoctorCard({required this.doctor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          width: 255,
          height: 160,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.08),
                offset: const Offset(0, 2),
                blurRadius: 8,
                spreadRadius: -2,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Stack(
              children: [
                Positioned(
                  right: -20,
                  top: -20,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                ),
                Row(
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
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(14),
                        bottomRight: Radius.circular(14),
                      ),
                      child: SizedBox(
                        width: 110,
                        height: 165,
                        child: (doctor.imageUrl != null &&
                                doctor.imageUrl!.isNotEmpty)
                            ? Image.network(doctor.imageUrl!, fit: BoxFit.cover)
                            : Image.asset(
                                AppAssets.avatarForDoctor(doctor.id),
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Disease categories ────────────────────────────────────────────────────────

class CategoriesSection extends StatelessWidget {
  const CategoriesSection({super.key});

  static const _diseaseNames = [
    'Dengue',
    'Gastritis',
    'Kidney ',
    'Piles',
    'Lungs ',
    'Typhoid ',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: 'Browse by Specialty',
          subtitle: 'Find care for your condition',
          onSeeAll: () => context.push(AppRoutes.allDiseases),
        ),
        SizedBox(
          height: 90,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
                horizontal: kHomeHorizontalPadding, vertical: 4),
            itemCount: AppAssets.diseaseIcons.length,
            itemBuilder: (context, index) {
              return _CategoryTile(
                icon: AppAssets.diseaseIcons[index],
                label: _diseaseNames[index],
                onTap: () => context.go(AppRoutes.allDoctors),
              );
            },
          ),
        ),
      ],
    );
  }
}

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
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Material(
            color: Colors.white,
            shape: const CircleBorder(),
            elevation: 2,
            shadowColor: const Color(0xFFC2D2E1),
            child: InkWell(
              onTap: onTap,
              customBorder: const CircleBorder(),
              child: Container(
                height: 50,
                width: 50,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(7),
                  child: Image.asset(icon, fit: BoxFit.contain),
                ),
              ),
            ),
          ),
          const SizedBox(height: 5),
          SizedBox(
            width: 64,
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textRed,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Available doctors ───────────────────────────────────────────────────────

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
          title: 'Available Now',
          subtitle: 'Ready to consult today',
          onSeeAll: () => context.go(AppRoutes.allDoctors),
        ),
        SizedBox(
          height: 160,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
                horizontal: kHomeHorizontalPadding, vertical: 10),
            itemCount: doctors.length.clamp(0, 4),
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final doctor = doctors[index];
              return Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  onTap: () => onTap(doctor),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    height: 140,
                    width: 230,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.07),
                          offset: const Offset(0, 4),
                          blurRadius: 16,
                          spreadRadius: -2,
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          offset: const Offset(0, 1),
                          blurRadius: 4,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          height: 150,
                          width: 90,
                          child: (doctor.imageUrl != null &&
                                  doctor.imageUrl!.isNotEmpty)
                              ? Image.network(doctor.imageUrl!,
                                  fit: BoxFit.cover)
                              : Image.asset(
                                  AppAssets.avatarForDoctor(doctor.id),
                                  fit: BoxFit.cover,
                                ),
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
              );
            },
          ),
        ),
      ],
    );
  }
}

// ── Recommended doctors ─────────────────────────────────────────────────────

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
          title: 'Recommended For You',
          subtitle: 'Personalised picks based on your needs',
          onSeeAll: () => context.go(AppRoutes.allDoctors),
        ),
        SizedBox(
          height: 206,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
                horizontal: kHomeHorizontalPadding, vertical: 8),
            itemCount: doctors.length.clamp(0, 4),
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final doctor = doctors[index];
              return Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 4),
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
                              child: (doctor.imageUrl != null &&
                                      doctor.imageUrl!.isNotEmpty)
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

// ── Shared section header row ───────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback onSeeAll;

  const _SectionHeader({
    required this.title,
    required this.onSeeAll,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          kHomeHorizontalPadding, 12, kHomeHorizontalPadding, 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    letterSpacing: -0.2,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 1),
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                      color: Color.fromARGB(255, 109, 112, 114),
                      letterSpacing: 0.1,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 16),
          InkWell(
            onTap: onSeeAll,
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 8),
              child: const Text(
                'View All',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textRed,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
