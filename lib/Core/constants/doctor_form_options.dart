/// Predefined option sets for the constrained doctor profile dropdowns
/// (Services, Location, Availability). Shared by doctor sign-up and the profile
/// editor so both offer the exact same choices.
class DoctorFormOptions {
  DoctorFormOptions._();

  /// Common service buckets a doctor can offer.
  static const List<String> services = [
    'General Consultation',
    'Diagnosis & Treatment',
    'Routine Checkup & Screening',
    'Surgery & Procedures',
    'Follow-up Care',
    'Online Video Consultation',
  ];

  /// Major hospitals / clinics used as the clinic location.
  static const List<String> locations = [
    'Shaukat Khanum Hospital, Lahore',
    'Mayo Hospital, Lahore',
    'Jinnah Hospital, Lahore',
    'Aga Khan University Hospital, Karachi',
    'Liaquat National Hospital, Karachi',
    'PIMS, Islamabad',
    'Hayatabad Medical Complex, Peshawar',
    'CMH, Rawalpindi',
  ];

  /// Common weekly availability patterns (the displayed hint format).
  static const List<String> availability = [
    'Mon–Fri: 9am–5pm',
    'Mon–Sat: 10am–6pm',
    'Tue–Sat: 10am–4pm',
    'Mon–Fri: 2pm–8pm',
    'Mon–Sun: 9am–9pm',
    'Sat–Sun: 10am–4pm',
  ];
}
