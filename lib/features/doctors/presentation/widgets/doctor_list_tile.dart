import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_container.dart';
import '../../domain/entities/doctor_entity.dart';
import 'home_doctor_cards.dart';

/// Row-style tile used in AllDoctorsPage list view.
class DoctorListTile extends StatelessWidget {
  final DoctorEntity doctor;
  final Color tileColor;
  final String image;
  final VoidCallback onTap;

  const DoctorListTile({
    super.key,
    required this.doctor,
    required this.tileColor,
    required this.image,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: AppContainer(
        onTap: onTap,
        color: tileColor,
        borderRadius: 12,
        padding: EdgeInsets.zero,
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8, top: 8, bottom: 8),
              child: Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 255, 255, 255),
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  child:
                      (doctor.imageUrl != null && doctor.imageUrl!.isNotEmpty)
                          ? CachedNetworkImage(
                              imageUrl: doctor.imageUrl!,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                              errorWidget: (context, url, error) => Image.asset(
                                image,
                                fit: BoxFit.cover,
                                alignment: const Alignment(0, -0.3),
                              ),
                            )
                          : Image.asset(
                              image,
                              fit: BoxFit.cover,
                              alignment: const Alignment(0, -0.3),
                            ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(doctor.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        )),
                    Text(doctor.speciality,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textRed,
                        )),
                    const SizedBox(height: 4),
                    Text('${doctor.experience} of Experience',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        )),
                    Row(children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text('${doctor.rating}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.primary,
                          )),
                    ]),
                    Text(doctor.location,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.primary)),
                    const SizedBox(height: 2),
                    DoctorAvailabilityBadge(availability: doctor.availability),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(10),
              child: Icon(Icons.arrow_forward_ios,
                  size: 16, color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}
