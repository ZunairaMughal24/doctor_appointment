import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../domain/entities/doctor_entity.dart';

class DoctorCard extends StatelessWidget {
  final DoctorEntity doctor;
  final VoidCallback onTap;
  final bool compact;

  const DoctorCard({
    super.key,
    required this.doctor,
    required this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: compact ? 180 : double.infinity,
        margin: EdgeInsets.only(
          right: compact ? 12 : 0,
          bottom: compact ? 0 : 12,
        ),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: compact ? _compactLayout() : _fullLayout(),
      ),
    );
  }

  Widget _compactLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _avatar(size: 56),
        const SizedBox(height: 10),
        Text(
          doctor.name,
          style: AppTextStyles.h4.copyWith(fontSize: 14),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          doctor.speciality,
          style: AppTextStyles.bodySmall,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),
        _ratingRow(),
      ],
    );
  }

  Widget _fullLayout() {
    return Row(
      children: [
        _avatar(size: 64),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(doctor.name, style: AppTextStyles.h4),
              const SizedBox(height: 2),
              Text(doctor.speciality, style: AppTextStyles.label),
              const SizedBox(height: 6),
              _ratingRow(),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.work_outline,
                      size: 13, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(doctor.experience, style: AppTextStyles.caption),
                  const SizedBox(width: 12),
                  const Icon(Icons.schedule_outlined,
                      size: 13, color: AppColors.success),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      doctor.availability,
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.success),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Icon(Icons.chevron_right, color: AppColors.textHint),
      ],
    );
  }

  Widget _avatar({required double size}) {
    if (doctor.imageUrl != null && doctor.imageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(size / 4),
        child: CachedNetworkImage(
          imageUrl: doctor.imageUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          placeholder: (context, url) => const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
            ),
          ),
          errorWidget: (context, url, error) => _initialsAvatar(size: size),
        ),
      );
    }
    return _initialsAvatar(size: size);
  }

  Widget _initialsAvatar({required double size}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(size / 4),
      ),
      child: Center(
        child: Text(
          doctor.name.isNotEmpty ? doctor.name[0].toUpperCase() : 'D',
          style: AppTextStyles.h4.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: size * 0.35,
          ),
        ),
      ),
    );
  }

  Widget _ratingRow() {
    return Row(
      children: [
        RatingBarIndicator(
          rating: doctor.rating,
          itemBuilder: (_, __) =>
              const Icon(Icons.star, color: Colors.amber),
          itemCount: 5,
          itemSize: 13,
        ),
        const SizedBox(width: 4),
        Text(
          doctor.rating.toStringAsFixed(1),
          style: AppTextStyles.caption
              .copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
