import '../../domain/entities/doctor_entity.dart';
import 'weekly_availability_mapper.dart';

class DoctorModel extends DoctorEntity {
  const DoctorModel({
    required super.id,
    required super.name,
    required super.email,
    required super.speciality,
    required super.experience,
    required super.phoneNumber,
    required super.location,
    required super.availability,
    required super.services,
    super.schedule,
    super.description,
    super.rating,
    super.imageUrl,
  });

  factory DoctorModel.fromFirestore(Map<String, dynamic> data, String id) {
    return DoctorModel(
      id: id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      speciality: data['speciality'] ?? '',
      experience: data['experience'] ?? '',
      phoneNumber: data['number'] ?? '',
      location: data['location'] ?? '',
      availability: data['availability'] ?? '',
      services: data['services'] ?? '',
      schedule: weeklyAvailabilityFromFirestoreMap(
        // 'schedule' is the current key; fall back to the legacy 'weeklySchedule'
        // key that was used before the naming fix.
        ((data['schedule'] ?? data['weeklySchedule']) as Map?)
            ?.cast<String, dynamic>(),
      ),
      description: data['description'] ?? '',
      rating: (data['rating'] ?? 4.5).toDouble(),
      imageUrl: data['imageUrl'],
    );
  }

  Map<String, dynamic> toFirestore() => {
        'name': name,
        'email': email,
        'speciality': speciality,
        'experience': experience,
        'number': phoneNumber,
        'location': location,
        'availability': availability,
        'schedule': schedule.toFirestoreMap(),
        'services': services,
        'description': description,
        'rating': rating,
        'imageUrl': imageUrl,
      };
}
