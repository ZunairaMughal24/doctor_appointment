import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/communication_launcher.dart';
import '../../../../core/utils/app_feedback.dart';

/// Actions for the doctor detail screen, keeping the page pure UI.
///
/// The only outbound contact offered here is the shared clinic assistant line
/// (for booking enquiries) — never the doctor's personal number. Direct contact
/// with a doctor remains gated behind a confirmed, active appointment.
class DoctorDetailViewModel {
  const DoctorDetailViewModel();

  /// The number shown/dialled by the "Call Assistant" button.
  String get assistantPhone => AppConstants.clinicAssistantPhone;

  /// Dials the clinic assistant. Shows a message if no dialer is available.
  Future<void> callAssistant(BuildContext context) async {
    final ok = await CommunicationLauncher.call(assistantPhone);
    if (!ok && context.mounted) {
      AppFeedback.showError(context, 'Could not open the dialer on this device.');
    }
  }
}
