import 'package:equatable/equatable.dart';

class DoctorEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String speciality;
  final String experience;
  final String phoneNumber;
  final String location;
  final String availability;
  final String services;
  final String description;
  final double rating;
  final String? imageUrl;

  const DoctorEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.speciality,
    required this.experience,
    required this.phoneNumber,
    required this.location,
    required this.availability,
    required this.services,
    this.description = '',
    this.rating = 4.5,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [id, name, email, speciality];
}
