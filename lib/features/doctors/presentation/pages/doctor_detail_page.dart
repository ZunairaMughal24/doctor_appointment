import 'package:flutter/material.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_feedback.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_container.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../domain/entities/doctor_entity.dart';
import '../../domain/entities/weekly_availability.dart';
import '../viewmodels/doctor_detail_viewmodel.dart';
import '../widgets/doctor_reviews.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'doctor_reviews_page.dart';

class DoctorDetailPage extends StatefulWidget {
  final String docId;
  final DoctorEntity? doctor;

  const DoctorDetailPage({
    super.key,
    required this.docId,
    this.doctor,
  });

  @override
  State<DoctorDetailPage> createState() => _DoctorDetailPageState();
}

class _DoctorDetailPageState extends State<DoctorDetailPage> {
  late final DoctorDetailViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = DoctorDetailViewModel(onChange: () {
      if (mounted) setState(() {});
    });
    _vm.loadDoctor(widget.docId);
    _vm.loadReviews(widget.docId);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.doctor == null) {
      return Scaffold(
        appBar: CustomAppBar(
          title: "Detail",
          onBackPressed: () => context.pop(),
        ),
        body: const Center(child: Text("Doctor details not found")),
      );
    }

    final data = _vm.freshDoctor ?? widget.doctor!;

    return Scaffold(
      backgroundColor: AppColors.cardBg,
      appBar: CustomAppBar(
        title: 'Doctor Details',
        onBackPressed: () => context.pop(),
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
                        ClipRRect(
                          borderRadius: BorderRadius.circular(42),
                          child: Container(
                            width: 84,
                            height: 84,
                            color: AppColors.primaryLight,
                            child: (data.imageUrl != null &&
                                    data.imageUrl!.isNotEmpty)
                                ? CachedNetworkImage(
                                    imageUrl: data.imageUrl!,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => const Center(
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        Image.asset(
                                      AppAssets.avatarForDoctor(data.id),
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Image.asset(
                                    AppAssets.avatarForDoctor(data.id),
                                    fit: BoxFit.cover,
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
                  child: AppContainer(
                    borderRadius: 19,
                    padding: const EdgeInsets.all(14.0),
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Contact Number',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Clinic reception line',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            Material(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(12),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () async {
                                  final ok = await _vm.callAssistant();
                                  if (!ok && context.mounted) {
                                    AppFeedback.showError(context,
                                        'Could not open the dialer on this device.');
                                  }
                                },
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.call,
                                          color: Colors.white, size: 16),
                                      SizedBox(width: 6),
                                      Text(
                                        'Call Assistant',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
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
                        const SizedBox(height: 12),
                        const Text(
                          'Weekly Schedule',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 6),
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
                        const SizedBox(height: 16),
                        DoctorReviewsSection(
                          reviews: _vm.reviews,
                          loading: _vm.reviewsLoading,
                          rating: data.rating,
                          limit: 2,
                          onSeeAll: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => DoctorReviewsPage(
                                doctorName: data.name,
                                reviews: _vm.reviews,
                                rating: data.rating,
                              ),
                            ),
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
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: SafeArea(
          child: AppButton(
            icon: Icons.event_available_rounded,
            label: 'Make an Appointment',
            onPressed: () => context.push(
              AppRoutes.scheduleAppointment,
              extra: data,
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
          _ScheduleRow(hours: schedule.forDay(day)),
      ],
    );
  }
}

class _ScheduleRow extends StatelessWidget {
  final DayHours hours;
  const _ScheduleRow({required this.hours});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            hours.day,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          hours.isOpen
              ? Text(
                  '${WeeklyAvailability.to12h(hours.open!)} – '
                  '${WeeklyAvailability.to12h(hours.close!)}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : const Text(
                  'Closed',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textHint,
                  ),
                ),
        ],
      ),
    );
  }
}
