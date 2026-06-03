import 'package:flutter/material.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/communication_launcher.dart';
import '../../../../core/utils/app_feedback.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_container.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../domain/entities/doctor_entity.dart';
import '../../domain/entities/weekly_availability.dart';

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
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              children: [
                // Doctor header card
                SizedBox(
                  height: 110,
                  child: AppContainer(
                    borderRadius: 19,
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 42,
                          backgroundColor: AppColors.primaryLight,
                          backgroundImage:
                              AssetImage(AppAssets.avatarForDoctor(data.id)),
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
                  child: AppContainer(
                    borderRadius: 19,
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
                                onPressed: () => CommunicationLauncher.call(
                                    data.phoneNumber),
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

                        const SizedBox(height: 8),
                        const Text(
                          'Weekly Availability',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _WeeklyScheduleTable(schedule: data.schedule),

                        const SizedBox(height: 12),
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

                        // Video consultation (WhatsApp)
                        AppButton.outlined(
                          icon: Icons.videocam_rounded,
                          label: 'Video Consultation',
                          onPressed: () async {
                            final ok = await CommunicationLauncher.whatsApp(
                              data.phoneNumber,
                              message:
                                  'Hello Dr. ${data.name.replaceFirst('Dr. ', '')}, '
                                  "I'd like to book a video consultation.",
                            );
                            if (!ok && context.mounted) {
                              AppFeedback.showError(context,
                                  'Could not open WhatsApp. Make sure it is installed.');
                            }
                          },
                        ),
                        const SizedBox(height: 12),

                        // Make an Appointment
                        AppButton(
                          icon: Icons.event_available_rounded,
                          label: 'Make an Appointment',
                          onPressed: () => context.push(
                            AppRoutes.scheduleAppointment,
                            extra: data,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WeeklyScheduleTable extends StatelessWidget {
  final WeeklyAvailability schedule;
  const _WeeklyScheduleTable({required this.schedule});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final day in WeeklyAvailability.weekdayNames)
          _row(schedule.forDay(day)),
      ],
    );
  }

  Widget _row(DayHours d) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            d.day,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          d.isOpen
              ? Text(
                  '${WeeklyAvailability.to12h(d.open!)} - '
                  '${WeeklyAvailability.to12h(d.close!)}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                )
              : const Text(
                  'Closed',
                  style: TextStyle(fontSize: 13, color: AppColors.textHint),
                ),
        ],
      ),
    );
  }
}

