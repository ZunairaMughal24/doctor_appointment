import 'package:flutter/material.dart';
import '../../domain/entities/appointment_entity.dart';

class AppointmentDetailPage extends StatelessWidget {
  final AppointmentEntity appointment;

  const AppointmentDetailPage({super.key, required this.appointment});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 247, 249, 252),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color.fromARGB(255, 57, 102, 150),
        title: Text(
          'Appointments with ${appointment.doctorName}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: 340,
              decoration: BoxDecoration(
                  border: Border.all(
                      color: const Color.fromARGB(255, 228, 227, 227),
                      width: 1.0),
                  borderRadius: BorderRadius.circular(19),
                  color: Colors.white,
                  boxShadow: const [
                    BoxShadow(
                        color: Color.fromARGB(255, 201, 201, 201),
                        offset: Offset(02, 03),
                        blurRadius: 0.5,
                        spreadRadius: 0.2),
                  ]),
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailItem(
                        "Selected Appointment day", appointment.appointmentDay),
                    const SizedBox(height: 10),
                    _buildDetailItem("Selected Appointment date",
                        appointment.appointmentDate),
                    const SizedBox(height: 10),
                    _buildDetailItem("Full name", appointment.patientName),
                    const SizedBox(height: 10),
                    _buildDetailItem(
                        "Contact number", appointment.patientPhone),
                    const SizedBox(height: 15),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 15),
          child: Text(
            label,
            style: const TextStyle(
              color: Color.fromARGB(255, 57, 102, 150),
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Color.fromARGB(255, 150, 155, 160),
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}
