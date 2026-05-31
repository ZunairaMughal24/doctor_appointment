import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fyp/Screens/doctorDetail.dart';

// Hardcoded fallback (same doctors as home screen)
final List<Map<String, dynamic>> _fallbackDoctors = [
  {
    'id': 'fallback_1',
    'name': 'Dr. Ahmed Ali',
    'speciality': 'Cardiologist',
    'experience': '12 years',
    'number': '0300-1234567',
    'location': 'Shaukat Khanum Hospital, Lahore',
    'availability': 'Mon–Fri: 9am–5pm',
    'services': 'ECG, Echo, Stress Test, Angioplasty',
    'description':
        'Dr. Ahmed Ali is a highly experienced cardiologist with over 12 years of practice at leading cardiac care centers.',
    'rating': 4.8,
    'tileColor': Color.fromARGB(255, 248, 238, 238),
  },
  {
    'id': 'fallback_2',
    'name': 'Dr. Sarah Khan',
    'speciality': 'Dermatologist',
    'experience': '8 years',
    'number': '0321-9876543',
    'location': 'Skin Care Clinic, Karachi',
    'availability': 'Tue–Sat: 10am–4pm',
    'services': 'Acne Treatment, Laser Therapy, Chemical Peel',
    'description':
        'Dr. Sarah Khan is a board-certified dermatologist known for her expertise in cosmetic and medical dermatology.',
    'rating': 4.9,
    'tileColor': Color.fromARGB(255, 243, 253, 244),
  },
  {
    'id': 'fallback_3',
    'name': 'Dr. Muhammad Hassan',
    'speciality': 'Neurologist',
    'experience': '15 years',
    'number': '0333-5556677',
    'location': 'JPMC Hospital, Karachi',
    'availability': 'Mon–Thu: 8am–3pm',
    'services': 'Epilepsy, Migraine, Stroke Management, EEG',
    'description':
        'Dr. Muhammad Hassan is a senior neurologist with 15 years of experience in complex neurological conditions.',
    'rating': 4.7,
    'tileColor': Color.fromARGB(255, 237, 247, 255),
  },
  {
    'id': 'fallback_4',
    'name': 'Dr. Ayesha Malik',
    'speciality': 'Pediatrician',
    'experience': '10 years',
    'number': '0311-4443322',
    'location': "Children's Hospital, Islamabad",
    'availability': 'Mon–Sun: 8am–6pm',
    'services': 'Well-child Visits, Vaccinations, Allergy Testing',
    'description':
        'Dr. Ayesha Malik is a compassionate pediatrician dedicated to the health of children from newborns to teenagers.',
    'rating': 4.9,
    'tileColor': Color.fromARGB(255, 247, 241, 248),
  },
  {
    'id': 'fallback_5',
    'name': 'Dr. Usman Raza',
    'speciality': 'Orthopedist',
    'experience': '14 years',
    'number': '0345-7788990',
    'location': 'Bone & Joint Center, Lahore',
    'availability': 'Mon–Fri: 8am–4pm',
    'services': 'Joint Replacement, Sports Injuries, Fracture Care',
    'description':
        'Dr. Usman Raza is a highly skilled orthopedic surgeon with 14 years of expertise in musculoskeletal conditions.',
    'rating': 4.6,
    'tileColor': Color.fromARGB(255, 248, 247, 236),
  },
  {
    'id': 'fallback_6',
    'name': 'Dr. Fatima Siddiqui',
    'speciality': 'Gynecologist',
    'experience': '9 years',
    'number': '0312-6655441',
    'location': 'Lady Aitchison Hospital, Lahore',
    'availability': 'Mon–Sat: 9am–5pm',
    'services': 'Prenatal Care, Normal & C-Section Delivery, PCOS',
    'description':
        'Dr. Fatima Siddiqui provides comprehensive obstetric and gynecological care with a focus on patient comfort and safety.',
    'rating': 4.8,
    'tileColor': Color.fromARGB(255, 248, 238, 238),
  },
];

final List<Color> _tileColors = const [
  Color.fromARGB(255, 248, 238, 238),
  Color.fromARGB(255, 243, 253, 244),
  Color.fromARGB(255, 237, 247, 255),
  Color.fromARGB(255, 247, 241, 248),
  Color.fromARGB(255, 248, 247, 236),
  Color.fromARGB(255, 243, 253, 244),
];

final List<String> _images = const [
  'assets/images/Doctors/MDryle.png',
  'assets/images/Doctors/FD3.png',
  'assets/images/Doctors/FD5.png',
  'assets/images/Doctors/MD2.png',
  'assets/images/Doctors/MD1.png',
];

class AllSpecialistScreen extends StatefulWidget {
  const AllSpecialistScreen({super.key});

  @override
  State<AllSpecialistScreen> createState() => _AllSpecialistScreenState();
}

class _AllSpecialistScreenState extends State<AllSpecialistScreen> {
  List<Map<String, dynamic>> doctors = List.from(_fallbackDoctors);

  @override
  void initState() {
    super.initState();
    _loadFromFirestore();
  }

  Future<void> _loadFromFirestore() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('doctors')
          .orderBy('createdAt', descending: true)
          .get();
      final list = snapshot.docs.map((doc) {
        final d = doc.data();
        d['id'] = doc.id;
        return d;
      }).toList();
      if (list.isNotEmpty && mounted) setState(() => doctors = list);
    } catch (_) {
      try {
        final snapshot =
            await FirebaseFirestore.instance.collection('doctors').get();
        final list = snapshot.docs.map((doc) {
          final d = doc.data();
          d['id'] = doc.id;
          return d;
        }).toList();
        if (list.isNotEmpty && mounted) setState(() => doctors = list);
      } catch (_) {}
    }
  }

  void _openDetail(Map<String, dynamic> item) {
    final id = item['id'] as String? ?? '';
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DoctorDetailScreen(
          docId: id,
          doctorData: id.startsWith('fallback_') ? item : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 249, 253, 255),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 11, 77, 105),
        title: const Text(
          'All Specialist',
          style: TextStyle(color: Colors.white, fontSize: 17),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(14.0),
        child: ListView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: doctors.length,
          itemBuilder: (context, index) {
            final doctor = doctors[index];
            final tileColor = (doctor['tileColor'] as Color?) ??
                _tileColors[index % _tileColors.length];
            final image = _images[index % _images.length];

            return GestureDetector(
              onTap: () => _openDetail(doctor),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: tileColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Padding(
                        padding:
                            const EdgeInsets.only(left: 8, top: 6, bottom: 6),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            image,
                            width: 80,
                            height: 110,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                doctor['name'] ?? '',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 11, 77, 105),
                                ),
                              ),
                              Text(
                                doctor['speciality'] ?? '',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color.fromARGB(255, 109, 4, 4),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${doctor['experience'] ?? ''} of Experience',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color.fromARGB(255, 123, 123, 123),
                                ),
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.star,
                                      color: Colors.amber, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${(doctor['rating'] as num? ?? 4.5)}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color.fromARGB(255, 11, 77, 105),
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                doctor['location'] ?? '',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color.fromARGB(255, 11, 77, 105),
                                ),
                              ),
                              Text(
                                doctor['availability'] ?? '',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color.fromARGB(255, 11, 77, 105),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Color.fromARGB(255, 11, 77, 105),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
