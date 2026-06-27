import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/services/communication_launcher.dart';
import '../../../../core/utils/app_feedback.dart';
import '../../../appointments/domain/entities/appointment_entity.dart';
import '../../../appointments/domain/usecases/get_doctor_reviews_usecase.dart';

class DoctorDetailViewModel {
  DoctorDetailViewModel({required this.onChange});

  final VoidCallback onChange;

  List<AppointmentEntity> _reviews = const [];
  bool _reviewsLoading = false;

  List<AppointmentEntity> get reviews => _reviews;
  bool get reviewsLoading => _reviewsLoading;

  String get assistantPhone => AppConstants.clinicAssistantPhone;

  void _set(VoidCallback fn) {
    fn();
    onChange();
  }

  Future<void> loadReviews(String doctorId) async {
    _set(() => _reviewsLoading = true);
    final result = await sl<GetDoctorReviewsUseCase>()(doctorId);
    result.fold(
      (failure) => _set(() => _reviewsLoading = false),
      (reviews) => _set(() {
        _reviews = reviews;
        _reviewsLoading = false;
      }),
    );
  }

  Future<void> callAssistant(BuildContext context) async {
    final ok = await CommunicationLauncher.call(assistantPhone);
    if (!ok && context.mounted) {
      AppFeedback.showError(context, 'Could not open the dialer on this device.');
    }
  }
}
