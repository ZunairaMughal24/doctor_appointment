import 'package:cloud_firestore/cloud_firestore.dart';

/// Seeded once on first launch. These act as the baseline "always present"
/// doctors so the app never looks empty. Real sign-ups appear above them
/// because they get a newer [createdAt] timestamp.
Future<void> seedDoctorsIfNeeded() async {
  try {
    final existing = await FirebaseFirestore.instance
        .collection('doctors')
        .where('isSeed', isEqualTo: true)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) return; // already seeded

    final batch = FirebaseFirestore.instance.batch();
    final col = FirebaseFirestore.instance.collection('doctors');

    // Old timestamp so real sign-ups always sort above these
    final seedDate = Timestamp.fromDate(
      DateTime.now().subtract(const Duration(days: 365)),
    );

    for (final doctor in _seedDoctors) {
      final ref = col.doc();
      batch.set(ref, {
        ...doctor,
        'isSeed': true,
        'createdAt': seedDate,
      });
    }

    await batch.commit();
  } catch (_) {
    // Seeding is best-effort — never crash the app over this
  }
}

const List<Map<String, dynamic>> _seedDoctors = [
  {
    'name': 'Dr. Ahmed Ali',
    'email': 'ahmed.ali@medic.com',
    'role': 'doctor',
    'speciality': 'Cardiologist',
    'experience': '12 years',
    'number': '0300-1234567',
    'location': 'Shaukat Khanum Hospital, Lahore',
    'availability': 'Mon–Fri: 9am–5pm',
    'services': 'ECG, Echo, Stress Test, Angioplasty, Heart Consultation',
    'description':
        'Dr. Ahmed Ali is a highly experienced cardiologist with over 12 years of practice at leading cardiac care centers. He specializes in interventional cardiology and has performed more than 2,000 successful procedures. His patient-first approach and clear communication make him one of the most sought-after heart specialists in the region.',
    'rating': 4.8,
  },
  {
    'name': 'Dr. Sarah Khan',
    'email': 'sarah.khan@medic.com',
    'role': 'doctor',
    'speciality': 'Dermatologist',
    'experience': '8 years',
    'number': '0321-9876543',
    'location': 'Skin Care Clinic, Karachi',
    'availability': 'Tue–Sat: 10am–4pm',
    'services': 'Acne Treatment, Laser Therapy, Chemical Peel, Hair Loss, Skin Cancer Screening',
    'description':
        'Dr. Sarah Khan is a board-certified dermatologist known for her expertise in cosmetic and medical dermatology. She has helped thousands of patients achieve healthier skin with personalized treatment plans. Dr. Khan stays up-to-date with the latest advances in dermatology to provide the best possible care.',
    'rating': 4.9,
  },
  {
    'name': 'Dr. Muhammad Hassan',
    'email': 'hassan.neuro@medic.com',
    'role': 'doctor',
    'speciality': 'Neurologist',
    'experience': '15 years',
    'number': '0333-5556677',
    'location': 'JPMC Hospital, Karachi',
    'availability': 'Mon–Thu: 8am–3pm',
    'services': 'Epilepsy, Migraine, Stroke Management, EEG, Nerve Conduction Studies',
    'description':
        'Dr. Muhammad Hassan is a senior neurologist with 15 years of experience in diagnosing and treating complex neurological conditions. He trained at international institutions and is widely respected for his work in epilepsy management and stroke rehabilitation.',
    'rating': 4.7,
  },
  {
    'name': 'Dr. Ayesha Malik',
    'email': 'ayesha.peds@medic.com',
    'role': 'doctor',
    'speciality': 'Pediatrician',
    'experience': '10 years',
    'number': '0311-4443322',
    'location': 'Children\'s Hospital, Islamabad',
    'availability': 'Mon–Sun: 8am–6pm',
    'services': 'Well-child Visits, Vaccinations, Allergy Testing, Growth Monitoring, Nutrition',
    'description':
        'Dr. Ayesha Malik is a compassionate pediatrician dedicated to the health and well-being of children from newborns to teenagers. With a decade of experience, she is known for her gentle approach that puts both children and parents at ease. She is especially skilled in managing childhood asthma and nutritional disorders.',
    'rating': 4.9,
  },
  {
    'name': 'Dr. Usman Raza',
    'email': 'usman.ortho@medic.com',
    'role': 'doctor',
    'speciality': 'Orthopedist',
    'experience': '14 years',
    'number': '0345-7788990',
    'location': 'Bone & Joint Center, Lahore',
    'availability': 'Mon–Fri: 8am–4pm',
    'services': 'Joint Replacement, Sports Injuries, Fracture Care, Spine Surgery, Arthritis',
    'description':
        'Dr. Usman Raza is a highly skilled orthopedic surgeon with 14 years of expertise in musculoskeletal conditions. He has performed hundreds of successful joint replacement surgeries and is a leading specialist in sports medicine. Patients from across Pakistan seek his care for complex bone and joint problems.',
    'rating': 4.6,
  },
  {
    'name': 'Dr. Fatima Siddiqui',
    'email': 'fatima.gyne@medic.com',
    'role': 'doctor',
    'speciality': 'Gynecologist',
    'experience': '9 years',
    'number': '0312-6655441',
    'location': 'Lady Aitchison Hospital, Lahore',
    'availability': 'Mon–Sat: 9am–5pm',
    'services': 'Prenatal Care, Normal & C-Section Delivery, PCOS, Infertility, Laparoscopy',
    'description':
        'Dr. Fatima Siddiqui is a caring and experienced gynecologist who has dedicated her career to women\'s health. She provides comprehensive obstetric and gynecological care with a focus on patient comfort and safety. Dr. Fatima is particularly well-regarded for her management of high-risk pregnancies and minimally invasive procedures.',
    'rating': 4.8,
  },
];
