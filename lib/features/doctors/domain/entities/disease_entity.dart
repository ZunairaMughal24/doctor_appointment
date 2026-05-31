import 'package:flutter/material.dart';

class DiseaseEntity {
  final String id;
  final String name;
  final String subtitle;
  final String imagePath;
  final Color color;
  final String speciality;

  const DiseaseEntity({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.imagePath,
    required this.color,
    required this.speciality,
  });
}

class Diseases {
  static const List<DiseaseEntity> all = [
    DiseaseEntity(
      id: 'heart',
      name: 'Heart Disease',
      subtitle: 'Cardiologist',
      imagePath: 'assets/images/Diseases/heart.png',
      color: Color(0xFFFFEBEE),
      speciality: 'Cardiologist',
    ),
    DiseaseEntity(
      id: 'dental',
      name: 'Dental Care',
      subtitle: 'Dentist',
      imagePath: 'assets/images/Diseases/dental.png',
      color: Color(0xFFE3F2FD),
      speciality: 'Dentist',
    ),
    DiseaseEntity(
      id: 'brain',
      name: 'Brain & Nerves',
      subtitle: 'Neurologist',
      imagePath: 'assets/images/Diseases/brain.png',
      color: Color(0xFFEDE7F6),
      speciality: 'Neurologist',
    ),
    DiseaseEntity(
      id: 'bones',
      name: 'Bones & Joints',
      subtitle: 'Orthopedist',
      imagePath: 'assets/images/Diseases/bones.png',
      color: Color(0xFFFFF3E0),
      speciality: 'Orthopedist',
    ),
    DiseaseEntity(
      id: 'eye',
      name: 'Eye Care',
      subtitle: 'Ophthalmologist',
      imagePath: 'assets/images/Diseases/eye.png',
      color: Color(0xFFE8F5E9),
      speciality: 'Ophthalmologist',
    ),
    DiseaseEntity(
      id: 'skin',
      name: 'Skin & Hair',
      subtitle: 'Dermatologist',
      imagePath: 'assets/images/Diseases/skin.png',
      color: Color(0xFFFCE4EC),
      speciality: 'Dermatologist',
    ),
  ];
}
