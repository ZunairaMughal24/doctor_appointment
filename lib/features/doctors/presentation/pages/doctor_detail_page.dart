import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/router/app_router.dart';
import '../../domain/entities/doctor_entity.dart';

class DoctorDetailPage extends StatelessWidget {
  final String docId;
  final DoctorEntity? doctor;

  const DoctorDetailPage({
    super.key,
    required this.docId,
    this.doctor,
  });

  @override
  Widget build(BuildContext context) {
    if (doctor == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Detail")),
        body: const Center(child: Text("Doctor details not found")),
      );
    }

    final data = doctor!;

    return Scaffold(
      backgroundColor: AppColors.cardBg,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: AppColors.primary,
        title: const Text(
          'Dr. Detail',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              // Doctor header card
              Container(
                height: 110,
                width: 340,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.inputBorder, width: 1.0),
                  borderRadius: BorderRadius.circular(19),
                  color: AppColors.surface,
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.shadowCard,
                      offset: Offset(2, 3),
                      blurRadius: 0.5,
                      spreadRadius: 0.2,
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 42,
                        backgroundColor: AppColors.primary,
                        child: Image.asset(
                          'assets/images/Doctors/MDryle.png',
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data.name,
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              data.speciality,
                              style: const TextStyle(
                                color: AppColors.textRed,
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              '${data.experience} of experience',
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontStyle: FontStyle.italic,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Doctor details card
              Expanded(
                child: Container(
                  width: 340,
                  decoration: BoxDecoration(
                    border:
                        Border.all(color: AppColors.inputBorder, width: 1.0),
                    borderRadius: BorderRadius.circular(19),
                    color: Colors.white,
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.shadowCard,
                        offset: Offset(2, 3),
                        blurRadius: 0.5,
                        spreadRadius: 0.2,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(9.0),
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Contact Number',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  data.phoneNumber,
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              height: 55,
                              width: 55,
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: AppColors.primary, width: 1.0),
                                borderRadius: BorderRadius.circular(16),
                                color: AppColors.primary,
                                boxShadow: const [
                                  BoxShadow(
                                    color: AppColors.shadowCard,
                                    offset: Offset(2, 3),
                                    blurRadius: 0.5,
                                    spreadRadius: 0.1,
                                  ),
                                ],
                              ),
                              child: IconButton(
                                onPressed: () async {
                                  final phone =
                                      Uri.parse('tel:${data.phoneNumber}');
                                  if (await canLaunchUrl(phone)) {
                                    await launchUrl(phone);
                                  }
                                },
                                icon:
                                    const Icon(Icons.call, color: Colors.white),
                                iconSize: 30,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 2),

                        const Text(
                          'Description',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          data.description.isNotEmpty
                              ? data.description
                              : 'No description available.',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),

                        const SizedBox(height: 2),
                        const IconButton(
                          alignment: Alignment.centerLeft,
                          onPressed: null,
                          icon: Icon(
                            Icons.location_on,
                            color: AppColors.primary,
                          ),
                        ),
                        Text(
                          data.location,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textRed,
                          ),
                        ),

                        const SizedBox(height: 5),
                        const Text(
                          'Availability',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          data.availability,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),

                        const SizedBox(height: 6),
                        const Text(
                          'Services',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          data.services,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),

                        const SizedBox(height: 19),

                        // Make an Appointment button
                        GestureDetector(
                          onTap: () => context.push(
                            AppRoutes.scheduleAppointment,
                            extra: {'docId': docId, 'name': data.name},
                          ),
                          child: Container(
                            height: 55,
                            width: 340,
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: AppColors.primary, width: 1.0),
                              borderRadius: BorderRadius.circular(16),
                              color: AppColors.primary,
                              boxShadow: const [
                                BoxShadow(
                                  color: AppColors.shadowCard,
                                  offset: Offset(2, 3),
                                  blurRadius: 0.5,
                                  spreadRadius: 0.1,
                                ),
                              ],
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(15.0),
                              child: Text(
                                'Make an Appointment',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
