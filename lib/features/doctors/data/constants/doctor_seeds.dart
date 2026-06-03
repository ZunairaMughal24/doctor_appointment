import '../../domain/entities/weekly_availability.dart';
import '../models/doctor_model.dart';

DayHours _open(String day, String open, String close) =>
    DayHours(day: day, open: open, close: close);
DayHours _closed(String day) => DayHours(day: day);

/// Mon–Fri open at the given hours; weekend closed.
WeeklyAvailability _weekdays(String open, String close) => WeeklyAvailability([
      _open('Monday', open, close),
      _open('Tuesday', open, close),
      _open('Wednesday', open, close),
      _open('Thursday', open, close),
      _open('Friday', open, close),
      _closed('Saturday'),
      _closed('Sunday'),
    ]);

/// Hardcoded seed doctors shown when Firestore is unavailable or empty.
/// Lives in the data layer — presentation never imports this directly.
final List<DoctorModel> kDoctorSeeds = [
  DoctorModel(
    id: 'seed_1',
    name: 'Dr. Ahmed Ali',
    email: '',
    speciality: 'Cardiologist',
    experience: '12 years',
    phoneNumber: '0300-1234567',
    location: 'Shaukat Khanum Hospital, Lahore',
    availability: 'Mon–Fri: 9am–5pm',
    schedule: _weekdays('09:00', '17:00'),
    services: 'ECG, Echo, Stress Test, Angioplasty',
    description:
        'Dr. Ahmed Ali is a highly experienced cardiologist with over 12 years of practice at leading cardiac care centers.',
    rating: 4.8,
  ),
  DoctorModel(
    id: 'seed_2',
    name: 'Dr. Sarah Khan',
    email: '',
    speciality: 'Dermatologist',
    experience: '8 years',
    phoneNumber: '0321-9876543',
    location: 'Skin Care Clinic, Karachi',
    availability: 'Tue–Sat: 10am–4pm',
    schedule: WeeklyAvailability([
      _closed('Monday'),
      _open('Tuesday', '10:00', '16:00'),
      _open('Wednesday', '10:00', '16:00'),
      _open('Thursday', '10:00', '16:00'),
      _open('Friday', '10:00', '16:00'),
      _open('Saturday', '10:00', '16:00'),
      _closed('Sunday'),
    ]),
    services: 'Acne Treatment, Laser Therapy, Chemical Peel',
    description:
        'Dr. Sarah Khan is a board-certified dermatologist known for her expertise in cosmetic and medical dermatology.',
    rating: 4.9,
  ),
  DoctorModel(
    id: 'seed_3',
    name: 'Dr. Muhammad Hassan',
    email: '',
    speciality: 'Neurologist',
    experience: '15 years',
    phoneNumber: '0333-5556677',
    location: 'JPMC Hospital, Karachi',
    availability: 'Mon–Thu: 8am–3pm',
    schedule: WeeklyAvailability([
      _open('Monday', '08:00', '15:00'),
      _open('Tuesday', '08:00', '15:00'),
      _open('Wednesday', '08:00', '15:00'),
      _open('Thursday', '08:00', '15:00'),
      _closed('Friday'),
      _closed('Saturday'),
      _closed('Sunday'),
    ]),
    services: 'Epilepsy, Migraine, Stroke Management, EEG',
    description:
        'Dr. Muhammad Hassan is a senior neurologist with 15 years of experience in complex neurological conditions.',
    rating: 4.7,
  ),
  DoctorModel(
    id: 'seed_4',
    name: 'Dr. Ayesha Malik',
    email: '',
    speciality: 'Pediatrician',
    experience: '10 years',
    phoneNumber: '0311-4443322',
    location: "Children's Hospital, Islamabad",
    availability: 'Mon–Sun: 8am–6pm',
    schedule: WeeklyAvailability([
      _open('Monday', '08:00', '18:00'),
      _open('Tuesday', '08:00', '18:00'),
      _open('Wednesday', '08:00', '18:00'),
      _open('Thursday', '08:00', '18:00'),
      _open('Friday', '08:00', '18:00'),
      _open('Saturday', '08:00', '18:00'),
      _open('Sunday', '08:00', '18:00'),
    ]),
    services: 'Well-child Visits, Vaccinations, Allergy Testing',
    description:
        'Dr. Ayesha Malik is a compassionate pediatrician dedicated to the health of children from newborns to teenagers.',
    rating: 4.9,
  ),
  DoctorModel(
    id: 'seed_5',
    name: 'Dr. Usman Raza',
    email: '',
    speciality: 'Orthopedist',
    experience: '14 years',
    phoneNumber: '0345-7788990',
    location: 'Bone & Joint Center, Lahore',
    availability: 'Mon–Fri: 8am–4pm',
    schedule: _weekdays('08:00', '16:00'),
    services: 'Joint Replacement, Sports Injuries, Fracture Care',
    description:
        'Dr. Usman Raza is a highly skilled orthopedic surgeon with 14 years of expertise in musculoskeletal conditions.',
    rating: 4.6,
  ),
  DoctorModel(
    id: 'seed_6',
    name: 'Dr. Fatima Siddiqui',
    email: '',
    speciality: 'Gynecologist',
    experience: '9 years',
    phoneNumber: '0312-6655441',
    location: 'Lady Aitchison Hospital, Lahore',
    availability: 'Mon–Sat: 9am–5pm',
    schedule: WeeklyAvailability([
      _open('Monday', '09:00', '17:00'),
      _open('Tuesday', '09:00', '17:00'),
      _open('Wednesday', '09:00', '17:00'),
      _open('Thursday', '09:00', '17:00'),
      _open('Friday', '09:00', '17:00'),
      _open('Saturday', '09:00', '17:00'),
      _closed('Sunday'),
    ]),
    services: 'Prenatal Care, Normal & C-Section Delivery, PCOS',
    description:
        'Dr. Fatima Siddiqui provides comprehensive obstetric and gynecological care with a focus on patient comfort and safety.',
    rating: 4.8,
  ),
];
