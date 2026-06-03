import 'package:equatable/equatable.dart';

import 'weekly_availability.dart';

class DoctorEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String speciality;
  final String experience;
  final String phoneNumber;
  final String location;

  /// Short free-text summary shown on cards (e.g. 'Mon–Fri: 9am–5pm').
  final String availability;

  /// Structured weekly schedule used to generate bookable slots.
  final WeeklyAvailability schedule;

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
    this.schedule = WeeklyAvailability.standard,
    this.description = '',
    this.rating = 4.5,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [id, name, email, speciality];
}
