class AppAssets {
  AppAssets._();

  // ── App images ────────────────────────────────────────────────────────────
  static const String appLogo = 'assets/images/AppImages/applogo.png';
  static const String signInImage = 'assets/images/AppImages/signIn.png';
  static const String signUpImage = 'assets/images/AppImages/signUp.png';

  // ── Doctor avatars ────────────────────────────────────────────────────────
  static const String doctorMale1 = 'assets/images/Doctors/MDryle.png';
  static const String doctorFemale1 = 'assets/images/Doctors/FD3.png';
  static const String doctorFemale2 = 'assets/images/Doctors/FD5.png';
  static const String doctorMale2 = 'assets/images/Doctors/MD2.png';
  static const String doctorMale3 = 'assets/images/Doctors/MD1.png';

  /// Rotating list used to assign avatars to doctor cards by index.
  static const List<String> doctorAvatars = [
    doctorMale1,
    doctorFemale1,
    doctorFemale2,
    doctorMale2,
    doctorMale3,
  ];

  /// A stable avatar for a given doctor id — so the same doctor always shows
  /// the same photo (used on the detail screen, which has no list index).
  static String avatarForDoctor(String id) =>
      doctorAvatars[id.hashCode.abs() % doctorAvatars.length];

  // ── Disease icons ─────────────────────────────────────────────────────────
  static const String diseaseDengue = 'assets/images/Diseases/dengue.png';
  static const String diseaseStomach = 'assets/images/Diseases/stomach.png';
  static const String diseaseKidney = 'assets/images/Diseases/kidneys.png';
  static const String diseasePiles = 'assets/images/Diseases/piles.png';
  static const String diseaseLungs = 'assets/images/Diseases/lungs.png';
  static const String diseaseTyphoid = 'assets/images/Diseases/typhoid.png';

  static const List<String> diseaseIcons = [
    diseaseDengue,
    diseaseStomach,
    diseaseKidney,
    diseasePiles,
    diseaseLungs,
    diseaseTyphoid,
  ];
}
