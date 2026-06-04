/// App-wide business constants that aren't tied to a single feature.
class AppConstants {
  AppConstants._();

  /// Shared clinic reception / assistant line. Patients use this to enquire or
  /// book — it is deliberately NOT any doctor's personal number, so a doctor is
  /// only ever reachable directly through a confirmed, active appointment.
  static const String clinicAssistantPhone = '042-111-222-333';

  /// Friendly display form of [clinicAssistantPhone].
  static const String clinicAssistantLabel = 'Call Assistant';
}
