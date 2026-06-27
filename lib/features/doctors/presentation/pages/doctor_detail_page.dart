import 'package:flutter/material.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_container.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../appointments/domain/entities/appointment_entity.dart';
import '../../domain/entities/doctor_entity.dart';
import '../../domain/entities/weekly_availability.dart';
import '../viewmodels/doctor_detail_viewmodel.dart';

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
        appBar: AppBar(
          title: const Text("Detail"),
          leading: context.canPop()
              ? IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white),
                  onPressed: () => context.pop(),
                )
              : null,
        ),
        body: const Center(child: Text("Doctor details not found")),
      );
    }

    final data = _vm.freshDoctor ?? widget.doctor!;

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
          'Doctor Details',
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
                          backgroundImage: (data.imageUrl != null &&
                                  data.imageUrl!.isNotEmpty)
                              ? NetworkImage(data.imageUrl!)
                              : AssetImage(AppAssets.avatarForDoctor(data.id))
                                  as ImageProvider,
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
                                onTap: () => _vm.callAssistant(context),
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
                        _ReviewsSection(
                          reviews: _vm.reviews,
                          loading: _vm.reviewsLoading,
                          rating: data.rating,
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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

class _ReviewsSection extends StatelessWidget {
  final List<AppointmentEntity> reviews;
  final bool loading;
  final double rating;

  const _ReviewsSection({
    required this.reviews,
    required this.loading,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Patient Reviews',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            if (rating > 0) ...[
              const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
              const SizedBox(width: 2),
              Text(
                rating.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        if (loading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          )
        else if (reviews.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'No reviews yet.',
              style: TextStyle(fontSize: 13, color: AppColors.textHint),
            ),
          )
        else
          ...reviews.map((r) => _ReviewCard(review: r)),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final AppointmentEntity review;
  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    final stars = review.rating ?? 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryLighter,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  review.patientName,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  5,
                  (i) => Icon(
                    Icons.star_rounded,
                    size: 14,
                    color: i < stars ? Colors.amber : AppColors.divider,
                  ),
                ),
              ),
            ],
          ),
          if (review.ratingComment.isNotEmpty) ...[
            const SizedBox(height: 5),
            Text(
              review.ratingComment,
              style: const TextStyle(
                  fontSize: 13, color: AppColors.textSecondary),
            ),
          ],
          if (review.createdAt != null) ...[
            const SizedBox(height: 4),
            Text(
              _formatDate(review.createdAt!),
              style: const TextStyle(fontSize: 11, color: AppColors.textHint),
            ),
          ],
        ],
      ),
    );
  }

  static String _formatDate(DateTime d) =>
      '${d.day}/${d.month}/${d.year}';
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
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            d.day,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          d.isOpen
              ? Text(
                  '${WeeklyAvailability.to12h(d.open!)} – ${WeeklyAvailability.to12h(d.close!)}',
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
