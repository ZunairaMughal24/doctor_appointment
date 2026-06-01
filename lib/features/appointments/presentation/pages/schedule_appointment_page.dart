import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';

import 'package:fyp/core/router/app_router.dart';
import 'package:fyp/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fyp/features/auth/presentation/bloc/auth_state.dart';
import 'package:fyp/features/appointments/presentation/bloc/appointment_bloc.dart';
import 'package:fyp/features/appointments/presentation/bloc/appointment_event.dart';
import 'package:fyp/features/appointments/presentation/bloc/appointment_state.dart';
import 'package:fyp/features/appointments/domain/entities/appointment_entity.dart';

class ScheduleAppointmentPage extends StatefulWidget {
  final String docId;
  final String name;

  const ScheduleAppointmentPage({
    super.key,
    required this.docId,
    required this.name,
  });

  @override
  State<ScheduleAppointmentPage> createState() =>
      _ScheduleAppointmentPageState();
}

class _ScheduleAppointmentPageState extends State<ScheduleAppointmentPage> {
  final _appointmentDayController = TextEditingController();
  final _appointmentDateController = TextEditingController();
  final _nameController = TextEditingController();
  final _numberController = TextEditingController();

  @override
  void dispose() {
    _appointmentDayController.dispose();
    _appointmentDateController.dispose();
    _nameController.dispose();
    _numberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardBg,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: AppColors.primary,
        title: Text(
          widget.name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: BlocListener<AppointmentBloc, AppointmentState>(
        listener: (context, state) {
          if (state is AppointmentBooked) {
            context.go(AppRoutes.appointments);
          } else if (state is AppointmentError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: Container(
          color: AppColors.background,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 50),
            child: ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                _buildLabel("Name"),
                _buildInputField(_nameController, "Enter your full name"),
                _buildLabel("Contact number"),
                _buildInputField(_numberController, "Enter number"),
                _buildLabel("Select Appointment day"),
                _buildInputField(_appointmentDayController, "Select day"),
                _buildLabel("Select Appointment date"),
                _buildInputField(_appointmentDateController, "Select date"),
                const SizedBox(height: 50),
                BlocBuilder<AppointmentBloc, AppointmentState>(
                  builder: (context, state) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onTap: state is AppointmentLoading
                            ? null
                            : () {
                                final authState = context.read<AuthBloc>().state;
                                final currentUserId = authState is AuthAuthenticated
                                    ? authState.user.uid
                                    : '';
                                final appointment = AppointmentEntity(
                                  id: '', // Will be set by Firestore
                                  patientId: currentUserId,
                                  patientName: _nameController.text.trim(),
                                  patientPhone: _numberController.text.trim(),
                                  doctorId: widget.docId,
                                  doctorName: widget.name,
                                  appointmentDay:
                                      _appointmentDayController.text.trim(),
                                  appointmentDate:
                                      _appointmentDateController.text.trim(),
                                );
                                context
                                    .read<AppointmentBloc>()
                                    .add(BookAppointment(appointment));
                              },
                        child: Container(
                          height: 53,
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: AppColors.primary,
                                  width: 1.0),
                              borderRadius: BorderRadius.circular(16),
                              color: AppColors.primary,
                              boxShadow: const [
                                BoxShadow(
                                    color: Color.fromARGB(255, 181, 185, 187),
                                    offset: Offset(02, 03),
                                    blurRadius: 0.5,
                                    spreadRadius: 0.1),
                              ]),
                          child: Center(
                            child: state is AppointmentLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white)
                                : const Text(
                                    "Submit",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, top: 5),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 17,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInputField(TextEditingController controller, String hint) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
            border: Border.all(
                color: const Color.fromARGB(255, 238, 235, 235), width: 1.0),
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
            boxShadow: const [
              BoxShadow(
                  color: Color.fromARGB(255, 221, 218, 218),
                  offset: Offset(02, 03),
                  blurRadius: 0.5,
                  spreadRadius: 0.1),
            ]),
        child: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hint,
              hintStyle: const TextStyle(
                  fontSize: 16, color: Color.fromARGB(255, 149, 160, 165)),
            ),
          ),
        ),
      ),
    );
  }
}
