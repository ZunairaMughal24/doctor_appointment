import '../../domain/entities/doctor_entity.dart';

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
        'services': services,
        'description': description,
        'rating': rating,
        'imageUrl': imageUrl,
      };
}
